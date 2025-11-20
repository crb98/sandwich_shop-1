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

  Future<double> _calculatePrice(Sandwich sandwich, int quantity) async {
    // Call the repository with the required named params and normalize result to double.
    dynamic callResult;
    try {
      callResult = pricingRepository.calculatePrice(
        sandwich,
        quantity: quantity,
        isFootlong: sandwich.isFootlong,
      );
    } catch (e) {
      // If the repository throws for any reason, return 0.0 to avoid crashing.
      return 0.0;
    }

    final dynamic awaited = await (callResult is Future ? callResult : Future.value(callResult));

    if (awaited is num) return awaited.toDouble();
    return double.tryParse(awaited.toString()) ?? 0.0;
  }
}