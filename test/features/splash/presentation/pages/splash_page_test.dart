import 'package:expense_tracker/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Splash Page', () {
    testWidgets(
      'Displayed',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SplashPage());
        expect(find.byType(SplashPage), findsOneWidget);
      },
    );
  });
}
