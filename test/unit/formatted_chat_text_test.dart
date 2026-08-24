import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeevan/widgets/chat/formatted_chat_text.dart';

void main() {
  group('FormattedChatText Unit & Widget Tests', () {
    testWidgets('renders bold text without raw asterisks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormattedChatText(
              text: '**Immediate Action**: Apply organic fungicide.',
              isUser: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no raw asterisks are rendered
      expect(find.textContaining('**'), findsNothing);
      expect(find.byType(FormattedChatText), findsOneWidget);

      // Verify rich text spans
      final richTextFinder = find.descendant(
        of: find.byType(FormattedChatText),
        matching: find.byType(RichText),
      );
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      final rootSpan = richText.text as TextSpan;
      
      // Look for the bold span in children or recursive spans
      bool hasBoldImmediateAction = false;
      rootSpan.visitChildren((span) {
        if (span is TextSpan && span.text == 'Immediate Action' && span.style?.fontWeight == FontWeight.w700) {
          hasBoldImmediateAction = true;
          return false;
        }
        return true;
      });

      expect(hasBoldImmediateAction, isTrue, reason: 'Must contain bold Immediate Action text span');
    });

    testWidgets('renders headers, bullet lists and inline code cleanly', (tester) async {
      const markdown = '''### Diagnosis Summary
• **Target Crop**: Tomato
• **Confidence**: 95%
Use `copper_spray` for treatment.''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormattedChatText(
              text: markdown,
              isUser: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Confirm raw markdown hashes or asterisks are not left unparsed
      expect(find.textContaining('###'), findsNothing);
      expect(find.textContaining('**'), findsNothing);
      expect(find.byType(FormattedChatText), findsOneWidget);
    });
  });
}
