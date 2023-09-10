import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/views/chat_screen/chat_screen.dart';
import 'package:qurban_3/views/home_screen/item_details.dart';

class VendorScren extends StatefulWidget {
  final dynamic data;

  const VendorScren({Key? key, required this.data}) : super(key: key);

  @override
  _ProfileSellerState createState() => _ProfileSellerState();
}

class _ProfileSellerState extends State<VendorScren> {
  Position? _buyerPosition;
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updateBuyerLocation();
  }

  Future<void> _requestLocationPermission() async {
    final permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.denied) {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission denied.'),
          ),
        );
        return;
      }
    }

    if (permissionStatus == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Location permission permanently denied. Please enable it in app settings.',
          ),
        ),
      );
      return;
    }

    if (mounted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    final permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.denied ||
        permissionStatus == LocationPermission.deniedForever) {
      await _requestLocationPermission();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _buyerPosition = position;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _updateBuyerLocation() async {
    // Memperbarui lokasi pembeli secara periodik
    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      _getCurrentLocation();
    }
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadius = 6371; // Radius bumi dalam kilometer
    double latDiff = _radians(endLatitude - startLatitude);
    double lonDiff = _radians(endLongitude - startLongitude);
    double a = sin(latDiff / 2) * sin(latDiff / 2) +
        cos(_radians(startLatitude)) *
            cos(_radians(endLatitude)) *
            sin(lonDiff / 2) *
            sin(lonDiff / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  double _radians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Seller Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('vendors')
                        .doc(widget.data['vendor_id'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        dynamic vendorData = snapshot.data!.data();
                        String imageUrl = vendorData['imageUrl'];
                        return imageUrl.isNotEmpty
                            ? Image.network(imageUrl,
                                    width: 100, fit: BoxFit.cover)
                                .box
                                .roundedFull
                                .clip(Clip.antiAlias)
                                .make()
                            : Image.asset('assets/icons/user.png',
                                    width: 100, fit: BoxFit.cover)
                                .box
                                .roundedFull
                                .clip(Clip.antiAlias)
                                .make();
                      } else if (snapshot.hasError) {
                        return const Text('Failed to load data');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  
                  10.heightBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('vendors')
                        .doc(widget.data['vendor_id'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        dynamic vendorData = snapshot.data!.data();

                        String sellerName = vendorData[
                            'name']; // Ganti ini dengan nama field yang sesuai di database Anda
                        return Text(
                          ' $sellerName',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      } else if (snapshot.hasError) {
                        return const Text('Failed to load data');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('vendors')
                              .doc(widget.data['vendor_id'])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              dynamic vendorData = snapshot.data!.data();
                              String email = vendorData['email'];
                              return Text(
                                ' $email',
                                style: const TextStyle(fontSize: 16),
                              );
                            } else if (snapshot.hasError) {
                              return const Text('Failed to load data');
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  
                ],
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('vendors')
                  .doc(widget.data['vendor_id'])
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  dynamic vendorData = snapshot.data!.data();
                  GeoPoint vendorLocation = vendorData['vendor_location'];
                  double vendorLatitude = vendorLocation.latitude;
                  double vendorLongitude = vendorLocation.longitude;

                  LatLng vendorLatLng = LatLng(vendorLatitude, vendorLongitude);

                  Set<Marker> markers = Set<Marker>.from([
                    Marker(
                      markerId: MarkerId('vendorMarker'),
                      position: vendorLatLng,
                      infoWindow: InfoWindow(
                        title: 'Vendor Location',
                        snippet:
                            'Latitude: $vendorLatitude, Longitude: $vendorLongitude',
                      ),
                    ),
                  ]);

                  LatLng? buyerLatLng;
                  if (_buyerPosition != null) {
                    buyerLatLng = LatLng(
                      _buyerPosition!.latitude,
                      _buyerPosition!.longitude,
                    );

                    double distance = calculateDistance(
                      vendorLatitude,
                      vendorLongitude,
                      buyerLatLng.latitude,
                      buyerLatLng.longitude,
                    );

                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: vendorLatLng,
                              zoom: 15,
                            ),
                            markers: markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Jarak: ${distance.toStringAsFixed(2)} km dari anda',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: vendorLatLng,
                          zoom: 15,
                        ),
                        markers: markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return const Text('Failed to load data');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('vendor_id', isEqualTo: widget.data['vendor_id'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<DocumentSnapshot> productDocs = snapshot.data!.docs;
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: productDocs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 300,
                      ),
                      itemBuilder: (context, index) {
                        dynamic productData = productDocs[index].data();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              productData['p_imgs'][0],
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                            const Spacer(),
                            const SizedBox(height: 5),
                            "${productData['p_jenishewan']}"
                                .text
                                .fontFamily(semibold)
                                .color(darkFontGrey)
                                .make(),
                            const SizedBox(height: 5),
                            "Rp. ${double.parse(productData['p_price']).numCurrency}"
                                .text
                                .fontFamily(bold)
                                .make(),
                            const SizedBox(height: 5),
                          ],
                        )
                            .box
                            .gray200
                            .margin(const EdgeInsets.symmetric(horizontal: 4))
                            .roundedSM
                            .padding(const EdgeInsets.all(12))
                            .make()
                            .onTap(() {
                          Get.to(() => ItemDetails(
                              title: "${productData['p_jenishewan']}",
                              data: productData));
                        });
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Failed to load products');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
