import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/country_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CountryExplorerApp());
}

class CountryExplorerApp extends StatelessWidget {
  const CountryExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CountryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Country Explorer',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF4FC3F7),
          scaffoldBackgroundColor: const Color(0xFF0A0F1E),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
