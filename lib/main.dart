import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'package:geolocator/geolocator.dart';
import 'login.dart';
import 'permission.dart';

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
  bool isUser = false;
  bool isPermission = false;
  bool? permission;
  bool isInitilize = false;

  @override
  void initState() {
    super.initState();
    _permission();
  }

  Future<void> _permission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (FirebaseAuth.instance.currentUser != null) {
      isUser = true;
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      isPermission = false;
    } else {
      isPermission = true;
    }
    setState(() {
      isInitilize = true;
    });
  }

  @override
  Widget build(BuildContext context) {
          if (!isInitilize){
                  return const Center(child: CircularProgressIndicator());
          }
    return MaterialApp(
      title: "Hello world",
      theme: ThemeData(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: (isUser && isPermission)
          ? const Homepage()
          : (isUser ? const Permission() : const Login()),
    );
  }
}
