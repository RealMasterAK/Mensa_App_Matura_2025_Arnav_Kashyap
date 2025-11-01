import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE', null);

  // Configure logging - temporarily enable INFO for debugging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    if (record.level >= Level.INFO) {
      debugPrint('${record.level.name}: ${record.message}');
      if (record.error != null) {
        debugPrint('Error: ${record.error}');
      }
      if (record.stackTrace != null && record.level >= Level.SEVERE) {
        debugPrint('Stack trace: ${record.stackTrace}');
      }
    }
  });

  runApp(const MensaApp());
}

class MensaApp extends StatelessWidget {
  const MensaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mensa KSWE',
      locale: const Locale('de', 'DE'),
      supportedLocales: const [Locale('de', 'DE')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(decoration: TextDecoration.none),
          bodyMedium: TextStyle(decoration: TextDecoration.none),
          bodySmall: TextStyle(decoration: TextDecoration.none),
          titleLarge: TextStyle(decoration: TextDecoration.none),
          titleMedium: TextStyle(decoration: TextDecoration.none),
          titleSmall: TextStyle(decoration: TextDecoration.none),
          labelLarge: TextStyle(decoration: TextDecoration.none),
          labelMedium: TextStyle(decoration: TextDecoration.none),
          labelSmall: TextStyle(decoration: TextDecoration.none),
          headlineLarge: TextStyle(decoration: TextDecoration.none),
          headlineMedium: TextStyle(decoration: TextDecoration.none),
          headlineSmall: TextStyle(decoration: TextDecoration.none),
          displayLarge: TextStyle(decoration: TextDecoration.none),
          displayMedium: TextStyle(decoration: TextDecoration.none),
          displaySmall: TextStyle(decoration: TextDecoration.none),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}
