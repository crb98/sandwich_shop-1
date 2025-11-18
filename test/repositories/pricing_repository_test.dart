import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  group('PricingRepository', () {
    final repository = PricingRepository();

    test('calculates price for single six-inch correctly', () {
      final sandwich = Sandwich(type: SandwichType.veggieDelight, isFootlong: false, breadType: BreadType.white);
      final price = repository.calculatePrice(sandwich, quantity: 1, isFootlong: false);
      expect(price, 7.00);
    });

    test('calculates price for multiple footlongs correctly', () {
      final sandwich = Sandwich(type: SandwichType.chickenTeriyaki, isFootlong: true, breadType: BreadType.wheat);
      final price = repository.calculatePrice(sandwich, quantity: 3, isFootlong: true);
      expect(price, 33.00);
    });

    test('calculates price for zero quantity as zero', () {
      final sandwich = Sandwich(type: SandwichType.meatballMarinara, isFootlong: true, breadType: BreadType.wholemeal);
      final price = repository.calculatePrice(sandwich, quantity: 0, isFootlong: true);
      expect(price, 0.00);
    });
  });
}
