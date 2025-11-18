import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/main.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  group('App', () {
    testWidgets('renders OrderScreen as home', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(OrderScreen), findsOneWidget);
    });
  });

  group('OrderScreen - Quantity', () {
    testWidgets('shows initial quantity and title', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('1'), findsOneWidget); // initial quantity
      expect(find.text('Sandwich Counter'), findsOneWidget);
    });

    testWidgets('increments quantity when add icon tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('decrements quantity when remove icon tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      // start at 1 -> increment to 2, then decrement back to 1
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('does not decrement below zero', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      // start at 1 -> decrement to 0 -> further taps do nothing
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('Controls - Bread Dropdown', () {
    testWidgets('changes bread type with DropdownMenu', (WidgetTester tester) async {
      await tester.pumpWidget(const App());

      // Open bread dropdown and select 'wheat'
      await tester.tap(find.byType(DropdownMenu<BreadType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('wheat').last);
      await tester.pumpAndSettle();

      expect(find.text('wheat'), findsWidgets);

      // Open again and select 'wholemeal'
      await tester.tap(find.byType(DropdownMenu<BreadType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('wholemeal').last);
      await tester.pumpAndSettle();

      expect(find.text('wholemeal'), findsWidgets);
    });
  });

  group('Add to Cart confirmation & summary', () {
    testWidgets('initial cart summary is zero and updates after adding to cart',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      // Wait for initial async summary update
      await tester.pumpAndSettle();

      // initial state: 0 items, total £0.00
      expect(find.text('Items in cart: 0'), findsOneWidget);
      expect(find.text('Total: £0.00'), findsOneWidget);

      // Tap the Add to Cart button
      await tester.tap(find.text('Add to Cart'));
      await tester.pump(); // immediate UI changes (confirmation message)
      // confirmation message should appear
      expect(find.text('Added 1 footlong Veggie Delight sandwich(es) on white bread to cart'),
          findsOneWidget);

      // Allow async price calculation and summary update to complete
      await tester.pumpAndSettle();

      // Expect cart summary updated to 1 item
      expect(find.text('Items in cart: 1'), findsOneWidget);

      // Expect total changed from £0.00 to some non-zero amount
      final totalFinder = find.byWidgetPredicate((w) =>
          w is Text && (w.data ?? '').startsWith('Total: £'));
      expect(totalFinder, findsOneWidget);
      final Text totalWidget = tester.widget<Text>(totalFinder);
      final String totalText = totalWidget.data ?? '';
      expect(totalText, isNot('Total: £0.00'));
      // numeric value > 0
      final numeric = double.parse(totalText.replaceAll(RegExp(r'[^0-9.]'), ''));
      expect(numeric, greaterThan(0.0));
    });
  });

  group('StyledButton', () {
    testWidgets('renders with icon and label', (WidgetTester tester) async {
      const testButton = StyledButton(
        onPressed: null,
        icon: Icons.add,
        label: 'Test Add',
        backgroundColor: Colors.blue,
      );
      const testApp = MaterialApp(
        home: Scaffold(body: testButton),
      );
      await tester.pumpWidget(testApp);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Test Add'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
