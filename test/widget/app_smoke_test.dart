import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/app.dart';

void main() {
  testWidgets('JeevanApp launches and renders splash screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JeevanApp(),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify Jeevan branding appears on splash
    expect(find.text('Jeevan'), findsOneWidget);
    expect(find.text('जीवन'), findsOneWidget);
    expect(find.text('Smart agriculture, one field at a time.'), findsOneWidget);

    // Settle splash timer (2500ms) + auth check latency (400ms) + navigation
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
  });
}
