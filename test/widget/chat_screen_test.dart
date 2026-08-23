import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_theme.dart';
import 'package:jeevan/features/assistant/jeevan_assistant_screen.dart';
import 'package:jeevan/features/home/home_screen.dart';
import 'package:jeevan/application/chat/chat_provider.dart';
import 'package:jeevan/domain/models/chat_message.dart';

void main() {
  testWidgets('HomeScreen has a floating chat action button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Verify FAB with chat icon exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
  });

  testWidgets('JeevanAssistantScreen displays question above answer', (tester) async {
    final testMessages = [
      ChatMessage(
        id: 'msg-1',
        text: 'Which zones need water?',
        sender: ChatSender.user,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ChatMessage(
        id: 'msg-2',
        text: 'Zones A and D need irrigation.',
        sender: ChatSender.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatMessagesProvider.overrideWith((ref) async => testMessages),
          suggestedPromptsProvider.overrideWith((ref) async => []),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const JeevanAssistantScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final questionFinder = find.text('Which zones need water?');
    final answerFinder = find.text('Zones A and D need irrigation.');

    expect(questionFinder, findsOneWidget);
    expect(answerFinder, findsOneWidget);

    // Verify vertical order: Question's top coordinate is higher (smaller Y) than Answer's top coordinate
    final questionTop = tester.getTopLeft(questionFinder).dy;
    final answerTop = tester.getTopLeft(answerFinder).dy;
    expect(questionTop, lessThan(answerTop), reason: 'Question must appear above the answer');
  });
}
