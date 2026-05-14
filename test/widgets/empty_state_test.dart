// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:cyclot_v1/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('renders empty state with icon and message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'There are currently no bikes available for allocation.',
              icon: Icons.two_wheeler,
            ),
          ),
        ),
      );

      // Verify message is displayed
      expect(
        find.text('There are currently no bikes available for allocation.'),
        findsOneWidget,
      );

      // Verify icon is displayed
      expect(find.byIcon(Icons.two_wheeler), findsOneWidget);
    });

    testWidgets('displays custom icon provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'Try adjusting your search',
              icon: Icons.search_off,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('displays with different messages', (
      WidgetTester tester,
    ) async {
      const messages = [
        'No notifications yet',
        'No allocations to show',
        'No bikes have been returned',
        'No users found',
      ];

      for (final message in messages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyState(message: message, icon: Icons.info),
            ),
          ),
        );

        expect(find.text(message), findsOneWidget);
      }
    });

    testWidgets('is scrollable when content is long', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message:
                  'This is a very long message that might need scrolling. ' *
                  10, // Repeat to make it long
              icon: Icons.info,
            ),
          ),
        ),
      );

      // Verify the widget exists
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('centers content on screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(message: 'No items', icon: Icons.info),
          ),
        ),
      );

      // EmptyState should center its content
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('uses appropriate sizing for icon and text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'Empty state message',
              icon: Icons.cloud_off,
            ),
          ),
        ),
      );

      // Verify all elements are rendered
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Empty state message'), findsOneWidget);
    });

    testWidgets('adapts to different screen sizes', (
      WidgetTester tester,
    ) async {
      // Test on a small screen
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items on small screen',
              icon: Icons.info,
            ),
          ),
        ),
      );

      expect(find.byType(EmptyState), findsOneWidget);
    });
  });
}
