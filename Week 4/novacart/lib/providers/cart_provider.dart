import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
  });

  final Product product;
  int quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get totalItems {
    var total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double get subtotal {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.product.price * item.quantity;
    });
    return total;
  }

  void addProduct(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    if (!_items.containsKey(product.id)) return;
    
    if (_items[product.id]!.quantity > 1) {
      _items[product.id]!.quantity -= 1;
    } else {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  void increaseQuantity(Product product) {
    addProduct(product); // Does the same as addProduct
  }

  void decreaseQuantity(Product product) {
    removeProduct(product); // Does the same as removeProduct
  }

  void removeItem(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool containsProduct(Product product) {
    return _items.containsKey(product.id);
  }

  int quantityFor(Product product) {
    return _items[product.id]?.quantity ?? 0;
  }
}
