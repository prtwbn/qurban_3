import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final endpointUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey';

  final response = await http.get(Uri.parse(endpointUrl));
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data['results'] != null && data['results'].isNotEmpty) {
      return data['results'][0]['formatted_address'];
    }
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
                            Get.to(() => PhotoView(
                                  imageProvider: AssetImage(sliderslist[index]),
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
                    20.heightBox,
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: GridView.builder(
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
                            Get.to(() =>
                                CategoryDetails(title: categoriesList[index]));
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
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
                              allProduct.text.black
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
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.network(
                                            filteredProducts[index]['p_imgs']
                                                [0],
                                            height: 200,
                                            width: 200,
                                            fit: BoxFit.cover,
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
                                              .fontFamily(bold)
                                              .make(),
                                          const SizedBox(height: 5),
                                        ],
                                      )
                                          .box
                                          .white
                                          .margin(const EdgeInsets.symmetric(
                                              horizontal: 4))
                                          .roundedSM
                                          .padding(const EdgeInsets.all(12))
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
