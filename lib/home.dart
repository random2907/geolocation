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
  final _mapcontroller = MapController();
  Position? position;

  Future<void> _getLocation() async {
    Position? newposition = await Geolocator.getCurrentPosition();
    setState(() {
      position = newposition;
    });
    if (position != null) {
            WidgetsBinding.instance.addPostFrameCallback((callback){
      _mapcontroller.move(LatLng(position!.latitude, position!.longitude), 18);
            });
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _getLocation();
          setState(() {
            if (i == "Punch in") {
              i = "Punch out";
            } else {
              i = "Punch in";
            }
          });
        },
        label: Text(i),
      ),
      drawer: const CommonDrawer(),
      body: position == null
          ? const Center(child:Text("Tap the button below to get position"))
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
