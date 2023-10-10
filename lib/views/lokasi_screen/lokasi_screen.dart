import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:geodesy/geodesy.dart' as geodesy;
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/views/lokasi_screen/vendor_screen.dart';
import 'package:qurban_3/views/profile_seller.dart/profile_seller.dart';

class LokasiScreen extends StatefulWidget {
  const LokasiScreen({Key? key}) : super(key: key);

  @override
  State<LokasiScreen> createState() => _LokasiScreenState();
}

class _LokasiScreenState extends State<LokasiScreen> {
  late GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );
  

  Set<Marker> markers = {};
  Set<Circle> circles = {};
  List<DocumentSnapshot> vendors = [];
  double selectedRange = 1000; // Jangkauan radius awal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  markers: markers,
                  circles: circles,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                    _fetchVendorsData();
                  },
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          googleMapController
                              .animateCamera(CameraUpdate.zoomIn());
                        },
                        mini: true,
                        backgroundColor: golden,
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8.0),
                      FloatingActionButton(
                        onPressed: () {
                          googleMapController
                              .animateCamera(CameraUpdate.zoomOut());
                        },
                        mini: true,
                        backgroundColor: golden,
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<double>(
                  value: selectedRange,
                  onChanged: (value) {
                    setState(() {
                      selectedRange = value!;
                      // Mengambil posisi saat ini dan menampilkan vendor yang berada dalam jangkauan yang dipilih
                      _determinePosition().then((position) {
                        googleMapController
                            .animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target:
                                LatLng(position.latitude, position.longitude),
                            zoom: 14,
                          ),
                        ));

                        markers.clear();
                        circles.clear();
                        markers.add(
                          Marker(
                            markerId: const MarkerId('currentLocation'),
                            position:
                                LatLng(position.latitude, position.longitude),
                          ),
                        );

                        _showVendorsWithinRange(position.latitude,
                            position.longitude, selectedRange);

                        setState(() {});
                      });
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: 1000,
                      child: Text('1km'),
                    ),
                    const DropdownMenuItem(
                      value: 2000,
                      child: Text('2km'),
                    ),
                    const DropdownMenuItem(
                      value: 3000,
                      child: Text('3km'),
                    ),
                    const DropdownMenuItem(
                      value: 4000,
                      child: Text('4km'),
                    ),
                    const DropdownMenuItem(
                      value: 5000,
                      child: Text('5km'),
                    ),
                    const DropdownMenuItem(
                      value: 6000,
                      child: Text('6km'),
                    ),
                    const DropdownMenuItem(
                      value: 7000,
                      child: Text('7km'),
                    ),
                    const DropdownMenuItem(
                      value: 8000,
                      child: Text('8km'),
                    ),
                    const DropdownMenuItem(
                      value: 9000,
                      child: Text('9km'),
                    ),
                    const DropdownMenuItem(
                      value: 10000,
                      child: Text('10km'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await _determinePosition();

          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14,
            ),
          ));

          markers.clear();
          circles.clear();
          markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
            ),
          );

          // Menampilkan vendor yang berada dalam jangkauan yang dipilih
          _showVendorsWithinRange(
              position.latitude, position.longitude, selectedRange);

          setState(() {});
        },
        label: const Text("Lokasi Sekarang"),
        icon: const Icon(Icons.location_history),
        backgroundColor: const Color.fromRGBO(255, 168, 0, 1),
      ),
    );
  }

  
Position defaultPosition() {
  return Position(
    latitude: 0, 
    longitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0
  );  // Anda bisa mengganti ke lokasi default yang Anda inginkan.
}




  Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Izinkan lokasi untuk melihat jarak antara Anda dan penjual.'),
      ),
    );
    return defaultPosition();
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Izinkan lokasi untuk melihat jarak antara Anda dan penjual.'),
      ),
    );
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Izin lokasi ditolak, izinkan di pengaturan'),
        ),
      );
      return defaultPosition();
    }
  }

  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Izinkan lokasi untuk melihat jarak antara Anda dan penjual.'),
      ),
    );
    return defaultPosition();
  }

  Position position;
  try {
    position = await Geolocator.getCurrentPosition();
  } catch (e) {
    position = defaultPosition();
  }

  return position;
}



  Future<void> _fetchVendorsData() async {
    // Mengambil data penjual dari Firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('vendors').get();

    // Menyimpan data penjual ke dalam list vendors
    vendors = snapshot.docs;

    // Mengambil posisi saat ini
    Position currentPosition = await _determinePosition();
    LatLng currentLocation =
        LatLng(currentPosition.latitude, currentPosition.longitude);

    // Menambahkan Marker dan Circle untuk setiap penjual
    vendors.forEach((doc) {
      GeoPoint geoPoint = doc['vendor_location'];
      LatLng vendorLocation = LatLng(geoPoint.latitude, geoPoint.longitude);

      Marker marker = Marker(
        markerId: MarkerId(doc.id),
        position: vendorLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: doc['name'],
          snippet: doc['email'],
        ),
        onTap: () {},
      );

      markers.add(marker);
    });

    // Menghapus marker dan circle sebelumnya (jika ada)
    markers.removeWhere((marker) => marker.markerId.value == 'currentLocation');
    circles.removeWhere(
        (circle) => circle.circleId.value == 'currentLocationCircle');

    // Menambahkan Marker dan Circle untuk posisi penjual saat ini
    Marker currentLocationMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: currentLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: 'Current Location',
      ),
    );

    markers.add(currentLocationMarker);

    Circle currentLocationCircle = Circle(
      circleId: const CircleId('currentLocationCircle'),
      center: currentLocation,
      radius: selectedRange,
      fillColor: const Color.fromRGBO(0, 0, 255, 0.1),
      strokeColor: Colors.blue,
      strokeWidth: 2,
    );

    circles.add(currentLocationCircle);

    setState(() {});
  }

  void _showVendorsWithinRange(
      double currentLatitude, double currentLongitude, double rangeInMeters) {
    LatLng buyerLocation = LatLng(currentLatitude, currentLongitude);

    markers.removeWhere((marker) => marker.markerId.value == 'currentLocation');
    circles.removeWhere((circle) => circle.circleId.value == 'radiusCircle');

    Circle circle = Circle(
      circleId: const CircleId('radiusCircle'),
      center: buyerLocation,
      radius: rangeInMeters,
      fillColor: const Color.fromRGBO(255, 0, 0, 0.1),
      strokeColor: Colors.red,
      strokeWidth: 2,
    );

    circles.add(circle);

    Marker currentLocationMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: buyerLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: 'Current Location',
      ),
    );

    markers.add(currentLocationMarker);

    vendors.forEach((doc) {
      GeoPoint geoPoint = doc['vendor_location'];
      LatLng vendorLocation = LatLng(geoPoint.latitude, geoPoint.longitude);

      double distance = _calculateDistance(currentLatitude, currentLongitude,
          vendorLocation.latitude, vendorLocation.longitude);
      if (distance <= rangeInMeters) {
        Marker marker = Marker(
          markerId: MarkerId(doc.id),
          position: vendorLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: doc['name']),
          /*
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorScreen(data: doc),
              ),
            );
          },*/
        );

        markers.add(marker);
      }
    });

    setState(() {});
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    final p = 0.017453292519943295;
    final c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R; R = 6371 km
  }
}
