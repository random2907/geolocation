import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final emailAddress = TextEditingController();
  final password = TextEditingController();
  String? _errorMessage;

  Future<void> _signin() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress.text,
        password: password.text,
      );
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided for that user.';
        } else {
          _errorMessage = e.code;
        }
      });
    }
  }

  Future<void> _signup() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress.text,
        password: password.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'The account already exists for that email.';
        }
      });
    }
  }

  void _navigateToHome() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 50, left: 18, right: 18),
          child: TextField(
            textAlign: TextAlign.center,
            controller: emailAddress,
            decoration: const InputDecoration(
              labelText: "emailAddress",
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50, left: 18, right: 18),
          child: TextField(
            textAlign: TextAlign.center,
            controller: password,
            decoration: const InputDecoration(
              labelText: "password",
            ),
          ),
        ),
        SizedBox(
          height: 25,
          child: _errorMessage != null ? Text(_errorMessage!) : null,
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _signin();
              });
            },
            child: const Text("Sign in"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _signup();
              });
            },
            child: const Text("Sign up"),
          ),
        ),
      ]),
    );
  }
}
