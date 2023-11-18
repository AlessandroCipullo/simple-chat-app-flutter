import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

final ButtonStyle _buttonStyle = ButtonStyle(
    elevation: const MaterialStatePropertyAll(15),
    shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(35)))),
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return Colors.black87;
      }
      return Colors.black;
    }),
    foregroundColor: MaterialStateProperty.all(Colors.white));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(style: _buttonStyle)),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/main_screen': (context) => const HomePage(),
        });
  }
}
