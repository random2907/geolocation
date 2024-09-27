import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'home.dart';

class Permission extends StatefulWidget {
  const Permission({super.key});
  @override
  PermissionState createState() => PermissionState();
}

class PermissionState extends State<Permission> {
  String gpsStatus = "Tap to enable Location Permission";

  Future<void> isLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          gpsStatus = "Location Permission are denied";
        });
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        setState(() {
          gpsStatus = "Location Permission is permanently denied";
        });
        return;
      }
    }
    setState(() {
      gpsStatus = "Permission enabled";
    });
    _navigateToHome();
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
      appBar: AppBar(
        title: const Text("Permission"),
        centerTitle: true,
      ),
      body: Center(
      child:ElevatedButton(
        child: Text(gpsStatus),
        onPressed: () async {
          await isLocationPermission();
        },
      ),
      ),
    );
  }
}
