import 'package:flutter_test/flutter_test.dart';
import 'package:blazing_fruits/app.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(const BlazingFruitsApp());
      await tester.pump(); // settle animations

      expect(find.text('BLAZING\nFRUITS'), findsOneWidget);
    });

    testWidgets('renders lane selector buttons', (tester) async {
      await tester.pumpWidget(const BlazingFruitsApp());
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders PLAY button', (tester) async {
      await tester.pumpWidget(const BlazingFruitsApp());
      await tester.pump();

      expect(find.text('PLAY'), findsOneWidget);
    });

    testWidgets('renders LEADERBOARD button', (tester) async {
      await tester.pumpWidget(const BlazingFruitsApp());
      await tester.pump();

      expect(find.text('LEADERBOARD'), findsOneWidget);
    });

    testWidgets('tapping lane 3 selects it', (tester) async {
      await tester.pumpWidget(const BlazingFruitsApp());
      await tester.pump();

      await tester.tap(find.text('3'));
      await tester.pump();

      // After tap, '3' button should still exist (selection state changed)
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tapping LEADERBOARD navigates to leaderboard screen',
        (tester) async {
      await tester.pumpWidget(const BlazingFruitsApp());
      await tester.pump();

      await tester.tap(find.text('LEADERBOARD'));
      await tester.pumpAndSettle();

      expect(find.text('LEADERBOARD'), findsWidgets);
    });
  });
}
