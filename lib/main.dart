import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Myapp());
}

class Myapp extends StatefulWidget {
  const Myapp({super.key});
  @override
  MyappState createState() => MyappState();
}

class MyappState extends State<Myapp> {
  bool home = false;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      home = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Hello world",
      theme: ThemeData(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: home ? const Homepage() : const Login(),
    );
  }
}

