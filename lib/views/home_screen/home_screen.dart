import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/consts/lists.dart';
import 'package:qurban_3/controllers/home_controller.dart';
import 'package:qurban_3/controllers/product_controller.dart';
import 'package:qurban_3/services/firestore_services.dart';
import 'package:qurban_3/views/category_screen/category_details.dart';
import 'package:qurban_3/views/home_screen/item_details.dart';
import 'package:qurban_3/views/home_screen/search_screen.dart';
import 'package:qurban_3/widgets_common/loading_indicator.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Future<String?> getReverseGeocoding(double lat, double lon) async {
    final apiKey = 'AIzaSyCH8hzCcApdrez5vZc9WNZk8L3PsNhMVXU';
    final endpointUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey';

    final response = await http.get(Uri.parse(endpointUrl));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      }
    }
    return null;
  }

  // Fungsi untuk mendapatkan lokasi pengguna
  Future<Position?> _getCurrentLocation(BuildContext context) async {
  Position? currentPosition;

  bool serviceEnabled;
  LocationPermission permission;

  // Periksa apakah layanan lokasi diaktifkan
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null; // Mengembalikan null
  }

  // Mintalah izin lokasi
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Tampilkan pesan ketika pengguna menolak dengan "tolak dan jangan tanya lagi"
      Get.snackbar("Izin Lokasi", "Aktifkan izin lokasi di perangkat anda", snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  if (permission == LocationPermission.denied) {
    Get.snackbar("Izin Lokasi", "Izinkan lokasi untuk melihat jarak antara anda dan penjual", snackPosition: SnackPosition.BOTTOM);
    return null; // Mengembalikan null
  }

  // Dapatkan lokasi pengguna
  try {
    currentPosition = await Geolocator.getCurrentPosition();
  } catch (e) {
    if (e is PermissionDeniedException) {
      // Tangkap exception ketika izin lokasi ditolak
      Get.snackbar("Izin Lokasi", "Aktifkan izin lokasi di perangkat anda", snackPosition: SnackPosition.BOTTOM);
    }
  }

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

  Future<double?> _getDistanceData(
      BuildContext context, Map<String, dynamic> product) async {
    var vendorId = product['vendor_id'];
    var vendorDoc = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .get();
    var vendorLocation = vendorDoc['vendor_location'];

    Position? userLocation = await _getCurrentLocation(context);
    if (userLocation != null) {
      return _calculateDistance(userLocation, vendorLocation);
    }
    return null;
  }

  Widget build(BuildContext context) {
    var controller2 = Get.put(ProductController());
    var controller = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.all(12),
      color: lightGrey,
      width: context.screenWidth,
      height: context.screenHeight,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 60,
              child: TextFormField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      if (controller
                          .searchController.text.isNotEmptyAndNotNull) {
                        Get.to(() => SearchScreen(
                              title: controller.searchController.text,
                            ));
                      }
                    },
                    child: const Icon(Icons.search),
                  ),
                  filled: true,
                  fillColor: whiteColor,
                  hintText: searchanything,
                  hintStyle: const TextStyle(color: textfieldGrey),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    VxSwiper.builder(
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      height: 200,
                      enlargeCenterPage: true,
                      itemCount: sliderslist.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Buka gambar dalam mode zoom
                            Get.to(() => Scaffold(
                                  appBar: AppBar(
                                    leading: IconButton(
                                      icon: Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () => Get.back(),
                                    ),
                                    backgroundColor: Colors
                                        .transparent, // latar belakang transparan untuk AppBar
                                    elevation:
                                        0, // menghilangkan shadow dari AppBar
                                  ),
                                  body: PhotoView(
                                    imageProvider:
                                        AssetImage(sliderslist[index]),
                                  ),
                                  backgroundColor: Colors
                                      .black, // latar belakang hitam untuk keseluruhan layar
                                ));
                          },
                          child: Image.asset(
                            sliderslist[index],
                            fit: BoxFit.fill,
                          )
                              .box
                              .rounded
                              .clip(Clip.antiAlias)
                              .margin(const EdgeInsets.symmetric(horizontal: 8))
                              .make(),
                        );
                      },
                    ),
                    30.heightBox,
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              "Kategori Hewan"
                                  .text
                                  .black
                                  .fontFamily(bold)
                                  .size(18)
                                  .make(),
                            ]
                          ),
                      15.heightBox,
                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: 2,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                width: 140,
                                fit: BoxFit.cover,
                              ),
                              //const SizedBox(height: 10),
                              /*
                              categoriesList[index]
                                  .text
                                  .color(darkFontGrey)
                                  .align(TextAlign.center)
                                  .make(),*/
                            ],
                          ).box.rounded.clip(Clip.antiAlias).make().onTap(() {
                            controller2.getSubCategories(categoriesList[index]);
                            Get.to(() =>
                                CategoryDetails(title: categoriesList[index]));
                          });
                        },
                      ),
                        ]
                    ),
                  
                    ),
                    //const SizedBox(height: 10),
                    Container(
                      //color: const Color.fromARGB(255, 236, 235, 235),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              "Rekomendasi Hewan"
                                  .text
                                  .black
                                  .fontFamily(bold)
                                  .size(18)
                                  .make(),
                              IconButton(
                                icon: const Icon(Icons.filter_list),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Urutkan Produk'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: const Text('Harga Terendah'),
                                            onTap: () {
                                              Get.back(); // Tutup dialog
                                              controller2.isLowestToHighest
                                                  .value = true;
                                            },
                                          ),
                                          ListTile(
                                            title:
                                                const Text('Harga Tertinggi'),
                                            onTap: () {
                                              Get.back(); // Tutup dialog
                                              controller2.isLowestToHighest
                                                  .value = false;
                                            },
                                          ),
                                          /*
                                          ListTile(
                                            title: const Text('Jarak Terdekat'),
                                            onTap: () {
                                              Get.back(); // Tutup dialog
                                              controller2.sortByDistance.value =
                                                  true;
                                            },
                                          ),
                                          */
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          StreamBuilder(
                            stream: FirestorServices.allproducts(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return loadingIndicator();
                              } else {
                                var allproductsdata = snapshot.data!.docs;
                                // Filter untuk mendapatkan satu produk terbaru dari setiap vendor dan kategori
                                Map<String, QueryDocumentSnapshot>
                                    latestProductsPerVendor = {};
                                allproductsdata =
                                    allproductsdata.where((product) {
                                  return (int.tryParse(
                                              product['p_quantity'] ?? '0') ??
                                          0) >
                                      0;
                                }).toList();

                                for (var product in allproductsdata) {
                                  var vendorId = product['vendor_id'];
                                  var category = product['p_subcategory'];
                                  var uniqueKey = "$vendorId-$category";

                                  if (latestProductsPerVendor[uniqueKey] ==
                                      null) {
                                    latestProductsPerVendor[uniqueKey] =
                                        product;
                                  }
                                }

                                allproductsdata =
                                    latestProductsPerVendor.values.toList();
                                return Obx(() {
                                  List<DocumentSnapshot> filteredProducts = [];

                                  // Filter harga berdasarkan nilai isLowestToHighest

                                  if (controller2.isLowestToHighest.value) {
                                    allproductsdata.sort((a, b) {
                                      var priceA = double.parse(a['p_price']);
                                      var priceB = double.parse(b['p_price']);
                                      return priceA.compareTo(priceB);
                                    });
                                  } else {
                                    allproductsdata.sort((a, b) {
                                      var priceA = double.parse(a['p_price']);
                                      var priceB = double.parse(b['p_price']);
                                      return priceB.compareTo(priceA);
                                    });
                                  }

                                  // Salin data produk yang difilter ke dalam filteredProducts
                                  filteredProducts = List.from(allproductsdata);

                                  return GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: filteredProducts.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        mainAxisExtent: 300,
                                      ),
                                      itemBuilder: (context, index) {
                                        return FutureBuilder(
                                          future: () async {
                                            var vendorId =
                                                filteredProducts[index]
                                                    ['vendor_id'];
                                            var vendorDoc =
                                                await FirebaseFirestore.instance
                                                    .collection('vendors')
                                                    .doc(vendorId)
                                                    .get();
                                            var vendorLocation =
                                                vendorDoc['vendor_location'];

                                            Position? userLocation =
                                                await _getCurrentLocation(
                                                    context);
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.network(
                                                  filteredProducts[index]
                                                      ['p_imgs'][0],
                                                  height: 200,
                                                  width: 200,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                    );
                                                  },
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                    return Text(
                                                        'Your error widget here');
                                                  },
                                                ),

                                                const Spacer(),
                                                const SizedBox(height: 5),
                                                "${filteredProducts[index]['p_jenishewan']}"
                                                    .text
                                                    .fontFamily(semibold)
                                                    .color(darkFontGrey)
                                                    .make(),
                                                const SizedBox(height: 5),
                                                "Rp. ${double.parse(filteredProducts[index]['p_price']).numCurrency}"
                                                    .text
                                                    .size(13)
                                                    .fontFamily(bold)
                                                    .make(),
                                                const SizedBox(height: 5),

                                                Row(
                                                  children: [
                                                    Icon(Icons
                                                        .location_on_sharp), // Icon lokasi
                                                    //const SizedBox(width: 2), // Spasi antara ikon dan teks
                                                    Text(
                                                        '${snapshot.data?.toStringAsFixed(2) ?? '0.0'} km'),
                                                  ],
                                                )

                                                //Text('${snapshot.data?.toStringAsFixed(1) ?? '0.0'} km'),
                                              ],
                                            )
                                                .box
                                                .white
                                                .margin(
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4))
                                                .roundedSM
                                                .padding(
                                                    const EdgeInsets.all(12))
                                                .make()
                                                .onTap(() {
                                              Get.to(
                                                () => ItemDetails(
                                                  title:
                                                      "${allproductsdata[index]['p_jenishewan']}",
                                                  data: allproductsdata[index],
                                                ),
                                              );
                                            });
                                          },
                                        );
                                      });
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
