import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

void main() {
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
            title: const Text("Login"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            },
          ),
          ListTile(
            title: const Text("Home"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Homepage()));
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
        ),
      ),
      drawer: const CommonDrawer(),
      body: const Padding(
        padding: EdgeInsets.only(top: 100, left: 18, right: 18),
        child: TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: "Enter your name",
          ),
        ),
      ),
    );
  }
}
