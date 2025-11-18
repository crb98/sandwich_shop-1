import 'dart:async';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

class CartItem {
  final Sandwich sandwich;
  int quantity;

  CartItem({required this.sandwich, this.quantity = 1});
}

class Cart {
  final PricingRepository pricingRepository;
  final List<CartItem> _items = [];

  Cart({required this.pricingRepository});

  List<CartItem> get items => List.unmodifiable(_items);

  void add(Sandwich sandwich, {int quantity = 1}) {
    final idx = _indexOf(sandwich);
    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(CartItem(sandwich: sandwich, quantity: quantity));
    }
  }

  void remove(Sandwich sandwich) {
    _items.removeWhere((it) => _sameSandwich(it.sandwich, sandwich));
  }

  void updateQuantity(Sandwich sandwich, int quantity) {
    if (quantity <= 0) {
      remove(sandwich);
      return;
    }
    final idx = _indexOf(sandwich);
    if (idx >= 0) {
      _items[idx].quantity = quantity;
    } else {
      add(sandwich, quantity: quantity);
    }
  }

  void clear() => _items.clear();

  int get totalItems => _items.fold<int>(0, (sum, it) => sum + it.quantity);

  /// Returns the total price for all items in the cart.
  /// This uses PricingRepository.calculatePrice as the single source of truth.
  Future<double> getTotalPrice() async {
    double total = 0.0;
    for (final item in _items) {
      total += await _calculatePrice(item.sandwich, item.quantity);
    }
    return total;
  }

  /// Returns the total price for a single cart item (quantity included).
  Future<double> getItemTotalPrice(CartItem item) async {
    return await _calculatePrice(item.sandwich, item.quantity);
  }

  int _indexOf(Sandwich sandwich) {
    return _items.indexWhere((it) => _sameSandwich(it.sandwich, sandwich));
  }

  bool _sameSandwich(Sandwich a, Sandwich b) {
    return a.type == b.type && a.isFootlong == b.isFootlong && a.breadType == b.breadType;
  }

  /// Helper that attempts to call PricingRepository.calculatePrice in a tolerant way:
  /// - First tries calculatePrice(sandwich, quantity)
  /// - If that raises a NoSuchMethodError, falls back to calculatePrice(sandwich)
  /// The result is awaited so the repository can be sync or async.
  Future<double> _calculatePrice(Sandwich sandwich, int quantity) async {
    final dynamic calc = pricingRepository.calculatePrice;
    try {
      final result = calc(sandwich, quantity);
      return await result;
    } on NoSuchMethodError {
      final result = calc(sandwich);
      return await result;
    }
  }
}