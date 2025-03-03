import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tabby_flutter/pages/api_key.dart';
import 'package:tabby_flutter/pages/chechout_page.dart';
import 'package:tabby_flutter/pages/home_page.dart';
import 'package:tabby_flutter/pages/new_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabby Flutter SDK Demo',
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      locale: const Locale('en', ''), // Use it for check Arabic locale
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const ApiKeyPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/new_session': (context) => const NewSession(),
        '/checkout': (context) => const CheckoutPage(),
      },
    );
  }
}
