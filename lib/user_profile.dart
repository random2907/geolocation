import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'common_drawer.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  User? user;
  String? name;
  String? image;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    viewProfile();
  }

  Future<void> setProfile() async {
    await user?.updateProfile(
        displayName: "Ranjeet",
        photoURL:
            "https://images.unsplash.com/photo-1449452198679-05c7fd30f416?ixid=M3wxMTI1OHwwfDF8cmFuZG9tfHx8fHx8fHx8MTcyNzk1MzYzOXw&ixlib=rb-4.0.3&q=85&w=2640");

    user = FirebaseAuth.instance.currentUser;
    viewProfile();
  }

  Future<void> resetProfile() async {
    await user?.updateProfile(displayName: null, photoURL: null);
    user = FirebaseAuth.instance.currentUser;
    viewProfile();
  }

  void viewProfile() {
    if (user != null) {
      setState(() {
        name = user!.displayName;
        image = user!.photoURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      drawer: CommonDrawer(),
      body: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.all(0.0),
          child:
              image == null ? Text("No profile image") : Image.network(image!),
        ),
        Padding(
          padding: EdgeInsets.all(0.0),
          child: Text(name == null ? "Name is not set" : name!),
        ),
        Padding(
          padding: EdgeInsets.all(0.0),
          child: ElevatedButton(
              child: Text("Reset"),
              onPressed: () {
                resetProfile();
              }),
        ),
        Padding(
          padding: EdgeInsets.all(0.0),
          child: ElevatedButton(
              child: Text("Set name"),
              onPressed: () {
                setProfile();
              }),
        ),
      ]),
    );
  }
}
