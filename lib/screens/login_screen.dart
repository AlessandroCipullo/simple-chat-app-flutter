import 'package:chat_app/services/auth_methods.dart';
import 'package:chat_app/screens/homepage_screen.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authMethods = AuthMethods.getInstance();

  @override
  Widget build(BuildContext context) {
    if (authMethods.isUserLogged()) {
      return const HomePage();
    }
    return Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/background.png'), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: ElevatedButton(
                onPressed: () async {
                  Utils.showCircularProgress(context);
                  String res = await authMethods.signIn();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (res == 'Success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          Utils.createSnackbar('Accesso riuscito'));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()));
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(Utils.createSnackbar('Accesso negato'));
                    }
                  }
                },
                style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(15),
                    shape: const MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(35)))),
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.black87;
                      }
                      return Colors.black;
                    }),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    fixedSize: MaterialStatePropertyAll(Size(
                        MediaQuery.of(context).size.width * 0.6,
                        MediaQuery.of(context).size.height * 0.1))),
                child: const Text('Log in with Google')),
          ),
        ));
  }
}
