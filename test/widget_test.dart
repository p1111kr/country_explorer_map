import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:country_explorer_map/main.dart';
import 'package:country_explorer_map/providers/country_provider.dart';

void main() {
  testWidgets('App loads and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CountryProvider()),
        ],
        child: const CountryExplorerApp(),
      ),
    );

    // Wait for UI animations / frames
    await tester.pumpAndSettle();

    // Check if main title appears
    expect(find.textContaining('World Explorer'), findsOneWidget);
  });
}
