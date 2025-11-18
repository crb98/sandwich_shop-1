import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  group('Sandwich model', () {
    final expectedNames = {
      SandwichType.veggieDelight: 'Veggie Delight',
      SandwichType.chickenTeriyaki: 'Chicken Teriyaki',
      SandwichType.tunaMelt: 'Tuna Melt',
      SandwichType.meatballMarinara: 'Meatball Marinara',
    };

    test('name returns correct human-readable name for each type', () {
      expectedNames.forEach((type, expected) {
        final sandwich = Sandwich(type: type, isFootlong: false, breadType: BreadType.white);
        expect(sandwich.name, expected);
      });
    });

    test('image returns correct path for footlong sizes', () {
      for (final type in SandwichType.values) {
        final sandwich = Sandwich(type: type, isFootlong: true, breadType: BreadType.wheat);
        final expectedPath = 'assets/images/${type.name}_footlong.png';
        expect(sandwich.image, expectedPath);
      }
    });

    test('image returns correct path for six inch sizes', () {
      for (final type in SandwichType.values) {
        final sandwich = Sandwich(type: type, isFootlong: false, breadType: BreadType.wholemeal);
        final expectedPath = 'assets/images/${type.name}_six_inch.png';
        expect(sandwich.image, expectedPath);
      }
    });

    test('breadType is stored correctly', () {
      final sandwich = Sandwich(type: SandwichType.tunaMelt, isFootlong: false, breadType: BreadType.wheat);
      expect(sandwich.breadType, BreadType.wheat);
    });
  });
}