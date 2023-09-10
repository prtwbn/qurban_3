import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              widget.title!.text.fontFamily(bold).black.make(),
              /*
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Urutkan Produk'),
                      content: ListView.builder(
                        itemCount: 2,
                        itemBuilder: (BuildContext context, int index) {
                          final filters = ['Harga Terendah', 'Harga Tertinggi'];
                          return ListTile(
                            title: Text(filters[index]),
                            onTap: () {
                              Get.back();
                              sortProducts(filters[index]);
                            },
                            tileColor: selectedFilter == filters[index] ? Colors.blue.withOpacity(0.3) : null,
                          );
                        },
                      ),
                    ),
                  );
                },
              ), */
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
                    .size(13)
                    .fontFamily(semibold)
                    .color(darkFontGrey)
                    .makeCentered()
                    .box
                    .yellow400
                    .rounded
                    .size(120, 60)
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

                  return Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      //shrinkWrap: true, // Add shrinkWrap property
                      itemCount: data.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 300,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
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
                            "${data[index]['p_name']}"
                                .text
                                .fontFamily(semibold)
                                .color(darkFontGrey)
                                .make(),
                            const SizedBox(height: 5),
                            "Rp. ${double.parse(data[index]['p_price']).numCurrency}"
                                .text
                                .color(darkFontGrey)
                                .fontFamily(bold)
                                .size(16)
                                .make(),
                            const SizedBox(height: 5),
                            "${data[index]['p_seller']}"
                                .text
                                .fontFamily(semibold)
                                .color(darkFontGrey)
                                .make(),
                          ],
                        ).box.white.margin(const EdgeInsets.symmetric(horizontal: 4)).roundedSM.outerShadowSm.padding(const EdgeInsets.all(12)).make().onTap(() {
                          controller.checkIfFav(data[index]);
                          Get.to(
                            () => ItemDetails(
                              title: "${data[index]['p_name']}",
                              data: data[index],
                            ),
                          );
                        });
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
