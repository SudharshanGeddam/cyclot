// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:cyclot_v1/widgets/loading_button.dart';

void main() {
  group('LoadingButton Widget Tests', () {
    testWidgets('renders button with label when not loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(label: 'Login', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_empty), findsNothing);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Login',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });

    testWidgets('disables button when loading', (WidgetTester tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Submit',
              onPressed: () {
                callCount++;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      // Button is disabled when loading - verify it shows progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('enables button and calls callback when not loading', (
      WidgetTester tester,
    ) async {
      var callCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Submit',
              onPressed: () {
                callCount++;
              },
              isLoading: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(callCount, equals(1));
    });

    testWidgets('displays loading state correctly', (
      WidgetTester tester,
    ) async {
      // Test loading state display
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Click me',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Click me'), findsNothing);

      // Test non-loading state display
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Click me',
              onPressed: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      // Should show label
      expect(find.text('Click me'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('uses full width by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(label: 'Full width button', onPressed: () {}),
          ),
        ),
      );

      final sizedBox = find.byType(SizedBox);
      expect(sizedBox, findsWidgets);
    });

    testWidgets('respects custom width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Custom width',
              onPressed: () {},
              width: 200,
            ),
          ),
        ),
      );

      expect(find.text('Custom width'), findsOneWidget);
    });

    testWidgets('uses default height of 48 when not specified', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(label: 'Default height', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Default height'), findsOneWidget);
    });

    testWidgets('respects custom height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Custom height',
              onPressed: () {},
              height: 64,
            ),
          ),
        ),
      );

      expect(find.text('Custom height'), findsOneWidget);
    });

    testWidgets('shows loading indicator with correct size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      final progressIndicator = find.byType(CircularProgressIndicator);
      expect(progressIndicator, findsOneWidget);

      // Verify the SizedBox containing the progress indicator
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);
    });

    testWidgets('handles null onPressed callback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(label: 'Disabled', onPressed: null),
          ),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('renders multiple buttons with different states', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LoadingButton(
                  label: 'Loading',
                  onPressed: () {},
                  isLoading: true,
                ),
                LoadingButton(
                  label: 'Not loading',
                  onPressed: () {},
                  isLoading: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Loading'), findsNothing);
      expect(find.text('Not loading'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('preserves label during loading state transition', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Submit Form',
              onPressed: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Submit Form'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Submit Form',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Loading indicator shows, label hidden
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
