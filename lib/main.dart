import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';


void main(){
        runApp(const Myapp());
}

class Myapp extends StatelessWidget{
        const Myapp({super.key});
        @override
        Widget build(BuildContext context){
                return MaterialApp(
                title: "Hello world",
                home: const Homepage(),
                theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                ),
                useMaterial3: true,
                ).copyWith(
                appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                ),
                ),
                darkTheme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueGrey,
                ),
                ).copyWith(
                appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blueGrey,
                ),
                ),
                themeMode: ThemeMode.system,
                );
        }
}

class Homepage extends StatefulWidget{
        const Homepage({super.key});
        @override
        HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage>{
        Position? position;
        String _locationMessage = "";

        @override 

        void initState(){
                super.initState();
                _getLocationAndSend();
        }

        Future<void> _getLocationAndSend() async {
                bool serviceEnabled;
                LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Location services are disabled.";
      });
      return;
    }
        permission = await Geolocator.checkPermission();
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
    setState((){
            _locationMessage = "Location fetched: ${position!.latitude}, ${position!.longitude}";
    });

     String url = 'http://192.168.0.108:8080/';
    await http.post(Uri.parse(url), body: {
      'latitude': position!.latitude.toString(),
      'longitude': position!.longitude.toString(),
    });
  }

        @override
        Widget build(BuildContext context){
                return Scaffold(
                appBar: AppBar(
                title: const Text("Attendence"),
                centerTitle: true,
                ),
                body:  position == null
                ? Center(child: Text(_locationMessage.isEmpty ? "Fetching location..." : _locationMessage))
                : FlutterMap(
                options: MapOptions(
                initialCenter: LatLng(position!.latitude,position!.longitude),
                initialZoom: 18,
                ),
                children: [
                TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                MarkerLayer(
                markers:[
                Marker(
                point: LatLng(position!.latitude,position!.longitude),
                width: 80,
                height: 80,
                child: const Icon( Icons.location_on, color: Colors.red),
                ),
                ],
                ),
                ],
                ),
                );
        }
}

