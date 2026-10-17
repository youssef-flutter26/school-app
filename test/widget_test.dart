import 'package:flutter_test/flutter_test.dart';
import 'package:schoolride/main.dart';

void main() {
  testWidgets('SchoolRide login screen renders', (tester) async {
    await tester.pumpWidget(const SchoolRideApp());
    expect(find.text('Welcome to SchoolRide'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
