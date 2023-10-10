import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/consts/lists.dart';
import 'package:qurban_3/controllers/product_controller.dart';
import 'package:qurban_3/views/category_screen/category_details.dart';
import 'package:qurban_3/views/chat_screen/chat_screen.dart';
import 'package:qurban_3/views/home_screen/item_details.dart';

class ProfileSeller extends StatefulWidget {
  final dynamic data;

  const ProfileSeller({Key? key, required this.data}) : super(key: key);

  @override
  _ProfileSellerState createState() => _ProfileSellerState();
}

class _ProfileSellerState extends State<ProfileSeller> {
  Position? _buyerPosition;
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updateBuyerLocation();
  }

  Future<void> _requestLocationPermission() async {
  if (!mounted) {
    return;
  }

  final permissionStatus = await Geolocator.checkPermission();
  if (permissionStatus == LocationPermission.denied) {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Izinkan lokasi untuk melihat jarak antara anda dan penjual'),
          ),
        );
      }
      return;
    }
  }

  if (permissionStatus == LocationPermission.deniedForever) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Location permission permanently denied. Please enable it in app settings.',
          ),
        ),
      );
    }
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
    var controller2 = Get.put(ProductController());
    return Scaffold(
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      appBar: AppBar(
  title: Text(
    'Seller Profile',
    style: TextStyle(
      color: Colors.black, // Ganti dengan warna yang Anda inginkan
    ),
  ),
)
,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                                      width: 70, fit: BoxFit.cover)
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
                    SizedBox(width: 20),
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
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                );
                              } else if (snapshot.hasError) {
                                return const Text('Failed to load data');
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                          5.heightBox,
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('vendors')
                                .doc(widget.data['vendor_id'])
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                dynamic vendorData = snapshot.data!.data();
                                String email = vendorData['alamat'];
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
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.message_rounded, color: darkFontGrey),
                    ).onTap(() {
                      Get.to(
                        () => const ChatScreen(),
                        arguments: [
                          widget.data['p_seller'],
                          widget.data['vendor_id']
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
              20.heightBox,
              /*
              Container(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: 2,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 150,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Image.asset(
                          categoriesImages[index],
                          height: 100,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        categoriesList[index]
                            .text
                            .color(darkFontGrey)
                            .align(TextAlign.center)
                            .make(),
                      ],
                    ).box.rounded.clip(Clip.antiAlias).make().onTap(() {
                      controller2.getSubCategories(categoriesList[index]);
                      Get.to(() => CategoryDetails(title: categoriesList[index]));
                    });
                  },
                ),
              ), */
        
              Container(
                //padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          "Hewan dari toko ini"
                              .text
                              .black
                              .fontFamily(bold)
                              .size(18)
                              .make(),
                        ]),
                    10.heightBox,
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .where('vendor_id', isEqualTo: widget.data['vendor_id'])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<DocumentSnapshot> productDocs =
                              snapshot.data!.docs;
        
                          // Filter products with quantity greater than 0
                          List<DocumentSnapshot> filteredProducts =
                              productDocs.where((productDoc) {
                            int? quantity =
                                int.tryParse(productDoc['p_quantity']);
                            return quantity != null && quantity > 0;
                          }).toList();
        
                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                filteredProducts.length, // Use filteredProducts
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 300,
                            ),
                            itemBuilder: (context, index) {
                              dynamic productData =
                                  filteredProducts[index].data();
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
                                      .fontFamily(bold)
                                      .color(darkFontGrey)
                                      //.size(16)
                                      .make(),
                                  const SizedBox(height: 5),
                                  "${productData['p_category']}"
                                      .text
                                      .color(darkFontGrey)
                                      .fontFamily(semibold)
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
                                  .white
                                  .margin(
                                      const EdgeInsets.symmetric(horizontal: 4))
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
                  ],
                ),
              ),
              10.heightBox,
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          "Habis Terjual"
                              .text
                              .black
                              .fontFamily(bold)
                              .size(18)
                              .make(),
                        ]),
                    10.heightBox,
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .where('vendor_id', isEqualTo: widget.data['vendor_id'])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<DocumentSnapshot> productDocs =
                              snapshot.data!.docs;
        
                          // Filter products with quantity greater than 0
                          List<DocumentSnapshot> filteredProducts =
                              productDocs.where((productDoc) {
                            int? quantity =
                                int.tryParse(productDoc['p_quantity']);
                            return quantity != null && quantity <= 0;
                          }).toList();
        
                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                filteredProducts.length, // Use filteredProducts
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 300,
                            ),
                            itemBuilder: (context, index) {
                              dynamic productData =
                                  filteredProducts[index].data();
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
                                      .fontFamily(bold)
                                      .color(darkFontGrey)
                                      //.size(16)
                                      .make(),
                                  const SizedBox(height: 5),
                                  "${productData['p_category']}"
                                      .text
                                      .color(darkFontGrey)
                                      .fontFamily(semibold)
                                      .make(),
                                  const SizedBox(height: 5),
                                  "Rp. ${double.parse(productData['p_price']).numCurrency}"
                                      .text
                                      .size(11)
                                      .fontFamily(bold)
                                      .make(),
                                  const SizedBox(height: 5),
                                ],
                              )
                                  .box
                                  .gray200
                                  .margin(
                                      const EdgeInsets.symmetric(horizontal: 4))
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
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
