import 'package:sandwich_shop/models/sandwich.dart';

class PricingRepository {
  double calculatePrice(Sandwich sandwich, {required int quantity, required bool isFootlong}) {
    final double pricePerItem = isFootlong ? 11.00 : 7.00;
    return quantity * pricePerItem;
  }
}
