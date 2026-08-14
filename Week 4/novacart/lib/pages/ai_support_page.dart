import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../services/ai_support_service.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ChatMessage {
  ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class AiSupportPage extends StatefulWidget {
  const AiSupportPage({super.key});

  @override
  State<AiSupportPage> createState() => _AiSupportPageState();
}

class _AiSupportPageState extends State<AiSupportPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitializing = true;

  final List<String> _suggestedPrompts = [
    "Find me products under ₹5,000",
    "Which headphones are best?",
    "What's the status of my latest order?",
    "How do I return an order?",
    "Help me with checkout",
    "What is in my cart?",
  ];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      final cartProvider = context.read<CartProvider>();
      await AiSupportService.instance.startChat(cartProvider);
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    // Keep session alive if wanted, or clear it. We'll leave it alive for the session.
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMsg = text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userMsg, isUser: true));
      _messages.add(ChatMessage(text: "", isUser: false)); // AI placeholder
      _isLoading = true;
      _textController.clear();
    });
    _scrollToBottom();

    try {
      final stream = AiSupportService.instance.sendMessageStream(userMsg);
      await for (final chunk in stream) {
        if (mounted) {
          setState(() {
            final lastMsg = _messages.last;
            _messages[_messages.length - 1] = ChatMessage(
              text: lastMsg.text + chunk,
              isUser: false,
            );
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
        if (_messages.isNotEmpty && _messages.last.text.isEmpty) {
          setState(() {
            _messages.removeLast();
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear the conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              _initChat(); // Restart context
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('NovaCart AI', style: TextStyle(fontSize: 18)),
            Text(
              'Your shopping assistant',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: _messages.isEmpty ? null : _clearChat,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isInitializing
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? _buildWelcomeState(theme)
                      : _buildMessageList(theme),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.smart_toy_rounded, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text('NovaCart AI is thinking...', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
            _buildComposer(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(Icons.auto_awesome_rounded, size: 40, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 24),
          Text(
            'How can I help you today?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me about products, your orders, or your cart.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestedPrompts.map((prompt) {
              return ActionChip(
                label: Text(prompt, style: const TextStyle(fontSize: 13)),
                onPressed: () => _sendMessage(prompt),
                backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message.isUser;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.smart_toy_rounded, size: 18, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                      bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                  ),
                  child: isUser
                      ? Text(
                          message.text,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: theme.colorScheme.onSurface, height: 1.4),
                            strong: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, height: 1.4),
                            listBullet: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                        ),
                ),
              ),
              if (isUser) const SizedBox(width: 32) else const SizedBox(width: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComposer(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Ask NovaCart AI...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isLoading,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textController,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return Container(
                decoration: BoxDecoration(
                  color: hasText && !_isLoading ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: hasText && !_isLoading ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: hasText && !_isLoading ? () => _sendMessage(_textController.text) : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
