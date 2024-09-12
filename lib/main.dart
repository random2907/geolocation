import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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
  void initState(){
          super.initState();
          if (FirebaseAuth.instance.currentUser!=null){
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

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(
            height: 50,
            child: DrawerHeader(
              padding: EdgeInsets.only(left: 100),
              child:
                  Text("Menu", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          ListTile(
            title: const Text("Home"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Homepage()));
            },
          ),
          ListTile(
            title: const Text("Logout"),
            onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
            },
          ),
        ],
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  Position? position;
  String _locationMessage = "";

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _checkGps();
    await _getLocationAndSend();
  }

  Future<void> _checkGps() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      LocationPermission locationPermission =
          await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Location services are disabled.";
        });
        return;
      }
    }
  }

  Future<void> _getLocationAndSend() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Location permissions are permanently denied.";
      });
      return;
    }

    // Get the current position
    position = await Geolocator.getCurrentPosition();
    setState(() {
      _locationMessage =
          "Location fetched: ${position!.latitude}, ${position!.longitude}";
    });

    String url = 'http://192.168.0.108:8080/';
    await http.post(Uri.parse(url), body: {
      'latitude': position!.latitude.toString(),
      'longitude': position!.longitude.toString(),
    });
  }

  var i = "Punch in";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendence"),
        centerTitle: true,
      ),
      drawer: const CommonDrawer(),
      body: position == null
          ? Center(
              child: Text(_locationMessage.isEmpty
                  ? "Fetching location..."
                  : _locationMessage))
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(position!.latitude, position!.longitude),
                initialZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(position!.latitude, position!.longitude),
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.red),
                    ),
                  ],
                ),
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          _initializeLocation();
                          setState(() {
                            if (i == "Punch in") {
                              i = "Punch out";
                            } else {
                              i = "Punch in";
                            }
                          });
                        },
                        child: Text(i),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final emailAddress = TextEditingController();
  final password = TextEditingController();
  Future<void> _signin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress.text,
        password: password.text,
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Homepage()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> _signup() async {
    print(emailAddress.text);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress.text,
        password: password.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    }
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
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: ElevatedButton(
            onPressed: () {
              _signin();
            },
            child: const Text("Sign in"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: ElevatedButton(
            onPressed: () {
              _signup();
            },
            child: const Text("Sign up"),
          ),
        ),
      ]),
    );
  }
}
