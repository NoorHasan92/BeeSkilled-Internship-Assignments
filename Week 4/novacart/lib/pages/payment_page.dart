import 'payment_success_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
class MockPaymentPage extends StatefulWidget {
  const MockPaymentPage({
    required this.address,
    required this.subtotal,
    required this.total,
    required this.items,
    super.key,
  });

  final Address address;
  final double subtotal;
  final double total;
  final List<OrderItem> items;

  @override
  State<MockPaymentPage> createState() => _MockPaymentPageState();
}

class _MockPaymentPageState extends State<MockPaymentPage> {
  String _selectedMethod = 'Card';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _processPayment() async {
    if (_selectedMethod != 'COD' && !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future<void>.delayed(const Duration(seconds: 2)); // Mock delay

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderId =
          'NC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      final order = OrderModel(
        userId: user.uid,
        orderId: orderId,
        items: widget.items,
        subtotal: widget.subtotal,
        deliveryFee: 0,
        total: widget.total,
        paymentMethod: _selectedMethod,
        paymentStatus: _selectedMethod == 'COD' ? 'pending' : 'paid',
        orderStatus: 'placed',
        address: widget.address,
      );

      await OrderService.instance.createOrder(order);

      if (!mounted) return;
      context.read<CartProvider>().clearCart();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PaymentSuccessPage(orderId: orderId)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount to Pay: ₹${widget.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Select Payment Method',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text(
                        'Credit / Debit Card',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: 'Card',
                      // ignore: deprecated_member_use
                      groupValue: _selectedMethod,
                      // ignore: deprecated_member_use
                      onChanged: (val) =>
                          setState(() => _selectedMethod = val!),
                      activeColor: Theme.of(context).colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                    if (_selectedMethod == 'Card')
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Card Number',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Expiry (MM/YY)',
                                    ),
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'CVV',
                                    ),
                                    obscureText: true,
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Card Holder Name',
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ],
                        ),
                      ),

                    const Divider(height: 1),

                    RadioListTile<String>(
                      title: const Text(
                        'UPI',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: 'UPI',
                      // ignore: deprecated_member_use
                      groupValue: _selectedMethod,
                      // ignore: deprecated_member_use
                      onChanged: (val) =>
                          setState(() => _selectedMethod = val!),
                      activeColor: Theme.of(context).colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                    if (_selectedMethod == 'UPI')
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'UPI ID',
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),

                    const Divider(height: 1),

                    RadioListTile<String>(
                      title: const Text(
                        'Cash on Delivery',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: 'COD',
                      // ignore: deprecated_member_use
                      groupValue: _selectedMethod,
                      // ignore: deprecated_member_use
                      onChanged: (val) =>
                          setState(() => _selectedMethod = val!),
                      activeColor: Theme.of(context).colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Pay ₹${widget.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

