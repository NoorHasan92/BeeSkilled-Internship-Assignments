import 'payment_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../models/saved_address.dart';
import '../providers/cart_provider.dart';
import '../services/address_service.dart';
import '../widgets/product_image.dart';
import 'addresses_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  SavedAddress? _selectedAddress;
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final stream = AddressService.instance.streamAddresses();
    final sub = stream.listen((addresses) {
      if (mounted) {
        setState(() {
          if (addresses.isNotEmpty) {
            try {
              _selectedAddress = addresses.firstWhere((a) => a.isDefault);
            } catch (_) {
              _selectedAddress = addresses.first;
            }
          } else {
            _selectedAddress = null;
          }
          _isLoadingAddress = false;
        });
      }
    });
    
    // Cancel subscription after first load to just use it for initial state
    // We update _selectedAddress manually when they pick a new one.
    // Actually, keeping the stream active is fine but we want to allow overriding.
    Future.delayed(const Duration(milliseconds: 500), () => sub.cancel());
  }

  void _proceedToPayment(BuildContext context) {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    final address = Address(
      name: _selectedAddress!.fullName,
      phone: _selectedAddress!.phone,
      address: _selectedAddress!.addressLine,
      city: _selectedAddress!.city,
      state: _selectedAddress!.state,
      pinCode: _selectedAddress!.pinCode,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MockPaymentPage(
          address: address,
          subtotal: cart.subtotal,
          total: cart.subtotal,
          items: cart.items.values
              .map(
                (item) => OrderItem(
                  productId: item.product.id,
                  name: item.product.name,
                  price: item.product.price,
                  quantity: item.quantity,
                  imageUrl: item.product.imageUrl,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _changeAddress() async {
    final selected = await Navigator.push<SavedAddress>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressesPage(selectMode: true),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedAddress = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Address',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _changeAddress,
                  child: Text(_selectedAddress == null ? 'Add' : 'Change'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: _isLoadingAddress
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _selectedAddress == null
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.location_off_outlined, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text('No address selected'),
                              const SizedBox(height: 16),
                              FilledButton.tonal(
                                onPressed: _changeAddress,
                                child: const Text('Select an Address'),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _selectedAddress!.label == 'Home' ? Icons.home_rounded : 
                                    _selectedAddress!.label == 'Work' ? Icons.work_rounded : Icons.location_on_rounded,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedAddress!.label,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedAddress!.fullName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text('${_selectedAddress!.addressLine}, ${_selectedAddress!.city}, ${_selectedAddress!.state} - ${_selectedAddress!.pinCode}'),
                              const SizedBox(height: 4),
                              Text('Phone: ${_selectedAddress!.phone}'),
                            ],
                          ),
                        ),
            ),

            const SizedBox(height: 32),
            Text(
              'Order Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ...cart.items.values.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ProductImage(imageUrl: item.product.imageUrl),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: TextStyle(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${(item.product.price * item.quantity).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '₹${cart.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Text(
                          'Free',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${cart.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedAddress == null ? null : () => _proceedToPayment(context),
                child: const Text('Proceed to Payment'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
