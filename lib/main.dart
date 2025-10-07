import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'page/page.dart';
import 'response/response.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    List<QrCartillaResponse> lista = [];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contratistas',
      initialRoute: 'login',
      routes: {'login': (_) => Login()},
      theme: ThemeData(primaryColor: Colors.green[900]),
    );
  }
}
