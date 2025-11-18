import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

class FakePricingRepository implements PricingRepository {
  final double sixInchPrice;

  FakePricingRepository(this.sixInchPrice);

  @override
  double calculatePrice(Sandwich sandwich, {required int quantity, required bool isFootlong}) {
    final unit = isFootlong ? sixInchPrice * 2 : sixInchPrice;
    return unit * quantity;
  }
}

void main() {
  group('Cart model', () {
    late PricingRepository repo;
    late Cart cart;
    final sA = Sandwich(type: SandwichType.veggieDelight, isFootlong: false, breadType: BreadType.white);
    final sB = Sandwich(type: SandwichType.tunaMelt, isFootlong: true, breadType: BreadType.wheat);

    setUp(() {
      repo = FakePricingRepository(3.0); // six-inch base price = 3.0
      cart = Cart(pricingRepository: repo);
    });

    test('adding same sandwich merges quantities', () {
      cart.add(sA);
      cart.add(sA, quantity: 2);
      expect(cart.items.length, 1);
      expect(cart.items.first.sandwich, sA);
      expect(cart.items.first.quantity, 3);
      expect(cart.totalItems, 3);
    });

    test('remove deletes matching sandwich', () {
      cart.add(sA);
      cart.add(sB);
      expect(cart.items.length, 2);

      cart.remove(sA);
      expect(cart.items.length, 1);
      expect(cart.items.first.sandwich, sB);
    });

    test('updateQuantity sets quantity and removes when zero', () {
      cart.add(sA, quantity: 1);
      cart.updateQuantity(sA, 5);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 5);

      cart.updateQuantity(sA, 0);
      expect(cart.items, isEmpty);
    });

    test('clear empties the cart and totalItems reflects it', () {
      cart.add(sA, quantity: 2);
      cart.add(sB, quantity: 1);
      expect(cart.totalItems, 3);

      cart.clear();
      expect(cart.items, isEmpty);
      expect(cart.totalItems, 0);
    });

    test('getItemTotalPrice and getTotalPrice use PricingRepository.calculatePrice', () async {
      cart.add(sA, quantity: 2); // 2 * 3.0 = 6.0
      cart.add(sB, quantity: 1); // footlong -> 2 * 3.0 = 6.0

      final itemTotal = await cart.getItemTotalPrice(cart.items.first);
      expect(itemTotal, 6.0);

      final total = await cart.getTotalPrice();
      expect(total, 12.0);
    });
  });
}