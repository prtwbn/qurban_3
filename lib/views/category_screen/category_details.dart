import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/controllers/product_controller.dart';
import 'package:qurban_3/services/firestore_services.dart';
import 'package:qurban_3/views/home_screen/item_details.dart';
import 'package:qurban_3/widgets_common/bg_widget.dart';
import 'package:qurban_3/widgets_common/loading_indicator.dart';

class CategoryDetails extends StatefulWidget {
  final String? title;

  const CategoryDetails({Key? key, required this.title}) : super(key: key);

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  var controller = Get.find<ProductController>();
  dynamic productMethod;
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
    switchCategory(widget.title);
  }

  switchCategory(title) {
    if (controller.subcat.contains(title)) {
      productMethod = FirestorServices.getSubCategoryProducts(title);
    } else {
      productMethod = FirestorServices.getProducts(title);
    }
  }

  void sortProducts(String? filter) {
    setState(() {
      selectedFilter = filter;
      switch (filter) {
        case 'Harga Terendah':
          // Logic to sort products based on lowest price
          break;
        case 'Harga Tertinggi':
          // Logic to sort products based on highest price
          break;
      }
    });
  }

  @override
  // Fungsi untuk mendapatkan lokasi pengguna
  Future<Position?> _getCurrentLocation() async {
    Position? currentPosition;

    bool serviceEnabled;
    LocationPermission permission;

    // Periksa apakah layanan lokasi diaktifkan
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak diaktifkan.');
    }

    // Mintalah izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Izin Lokasi",
            "Izinkan lokasi untuk melihat jarak antara anda dan penjual",
            snackPosition: SnackPosition.BOTTOM);
        return null; // Mengembalikan null
      }
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Izin Lokasi",
            "Izinkan lokasi untuk melihat jarak antara anda dan penjual",
            snackPosition: SnackPosition.BOTTOM);
        return null; // Mengembalikan null
      }
    }

    // Dapatkan lokasi pengguna
    currentPosition = await Geolocator.getCurrentPosition();

    return currentPosition;
  }

  // Fungsi untuk menghitung jarak menggunakan formula Haversine
  double _calculateDistance(Position userLocation, var vendorLocation) {
    double lat1 = userLocation.latitude;
    double lon1 = userLocation.longitude;
    double lat2 = vendorLocation.latitude;
    double lon2 = vendorLocation.longitude;

    const R = 6371; // radius bumi dalam kilometer

    var dLat = _degreesToRadians(lat2 - lat1);
    var dLon = _degreesToRadians(lon2 - lon1);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var distance = R * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<double?> _getDistanceData(Map<String, dynamic> product) async {
    var vendorId = product['vendor_id'];
    var vendorDoc = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .get();
    var vendorLocation = vendorDoc['vendor_location'];

    Position? userLocation = await _getCurrentLocation();
    if (userLocation != null) {
      return _calculateDistance(userLocation, vendorLocation);
    }
    return null;
  }

  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(239, 239, 239, 1),
        appBar: AppBar(
          title: Row(
            children: [
              widget.title!.text.fontFamily(bold).black.make(),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text('Urutkan Produk'),
                      children: [
                        ListTile(
                          title: Text('Harga Terendah'),
                          onTap: () {
                            Get.back();
                            sortProducts('Harga Terendah');
                          },
                          /*
            tileColor: selectedFilter == 'Harga Terendah'
              ? Colors.blue.withOpacity(0.3)
              : null,*/
                        ),
                        ListTile(
                          title: Text('Harga Tertinggi'),
                          onTap: () {
                            Get.back();
                            sortProducts('Harga Tertinggi');
                          },
                          /*
            tileColor: selectedFilter == 'Harga Tertinggi'
              ? Colors.blue.withOpacity(0.3)
              : null, */
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                controller.subcat.length,
                (index) => "${controller.subcat[index]}"
                    .text
                    .size(12)
                    .fontFamily(semibold)
                    .color(darkFontGrey)
                    .makeCentered()
                    .box
                    .yellow300
                    .rounded
                    .size(110, 50)
                    .margin(const EdgeInsets.symmetric(horizontal: 4))
                    .make()
                    .onTap(() {
                  switchCategory("${controller.subcat[index]}");
                  setState(() {});
                }),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: productMethod,
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (!snapshot.hasData) {
                  return Expanded(
                    child: Center(
                      child: loadingIndicator(),
                    ),
                  );
                } else if (snapshot.data!.docs.isEmpty) {
                  return Expanded(
                    child: "No Products Found !"
                        .text
                        .color(darkFontGrey)
                        .makeCentered(),
                  );
                } else {
                  var data = snapshot.data!.docs;

                  if (selectedFilter == 'Harga Terendah') {
                    data.sort((a, b) {
                      var priceA = double.parse(a['p_price']);
                      var priceB = double.parse(b['p_price']);
                      return priceA.compareTo(priceB);
                    });
                  } else if (selectedFilter == 'Harga Tertinggi') {
                    data.sort((a, b) {
                      var priceA = double.parse(a['p_price']);
                      var priceB = double.parse(b['p_price']);
                      return priceB.compareTo(priceA);
                    });
                  }

                  // Filter produk dengan quantity 0 atau kosong
                  data = data
                      .where(
                          (product) => int.tryParse(product['p_quantity'])! > 0)
                      .toList();

                  return Expanded(
                      child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true, // Add shrinkWrap property
                          itemCount: data.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 300,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            return FutureBuilder(
                              future: () async {
                                var vendorId = data[index]['vendor_id'];
                                var vendorDoc = await FirebaseFirestore.instance
                                    .collection('vendors')
                                    .doc(vendorId)
                                    .get();
                                var vendorLocation =
                                    vendorDoc['vendor_location'];

                                Position? userLocation =
                                    await _getCurrentLocation();
                                double distance = 0;
                                if (userLocation != null) {
                                  distance = _calculateDistance(
                                      userLocation, vendorLocation);
                                }

                                return distance;
                              }(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // tampilkan loading ketika menunggu data
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      data[index]['p_imgs'][0],
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 5),
                                    "${data[index]['p_jenishewan']}"
                                        .text
                                        .fontFamily(semibold)
                                        .color(darkFontGrey)
                                        .make(),
                                    const SizedBox(height: 5),
                                    "Rp. ${double.parse(data[index]['p_price']).numCurrency}"
                                        .text
                                        .color(darkFontGrey)
                                        .fontFamily(bold)
                                        .size(15)
                                        .make(),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_sharp),
                                        Text(
                                            '${snapshot.data?.toStringAsFixed(2) ?? '0.0'} km'),
                                      ],
                                    )
                                  ],
                                )
                                    .box
                                    .white
                                    .margin(const EdgeInsets.symmetric(
                                        horizontal: 4))
                                    .roundedSM
                                    .outerShadow
                                    .padding(const EdgeInsets.all(12))
                                    .make()
                                    .onTap(() {
                                  controller.checkIfFav(data[index]);
                                  Get.to(
                                    () => ItemDetails(
                                      title: "${data[index]['p_jenishewan']}",
                                      data: data[index],
                                    ),
                                  );
                                });
                              },
                            );
                          }));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
