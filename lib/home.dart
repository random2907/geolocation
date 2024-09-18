import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'common_drawer.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  String _locationMessage = "";
  final _mapcontroller = MapController();
  Position? position;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage =
            "Location services are disabled. Please enable them.";
      });
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Location permissions are denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Location permissions are permanently denied";
      });
      return;
    }

    Position newposition = await Geolocator.getCurrentPosition();
    setState(() {
      position = newposition;
    });
    if (position != null) {
      _mapcontroller.move(LatLng(position!.latitude, position!.longitude), 18);
    }
  }

  var i = "Punch in";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendence"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
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
      drawer: const CommonDrawer(),
      body: position == null
          ? Text(_locationMessage.isEmpty
              ? "Fetching location..."
              : _locationMessage)
          : FlutterMap(
              mapController: _mapcontroller,
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
              ],
            ),
    );
  }
}

