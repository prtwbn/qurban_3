import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/services/firestore_services.dart';
import 'package:qurban_3/views/home_screen/item_details.dart';
import 'package:qurban_3/views/profile_seller.dart/profile_seller.dart';
import 'package:qurban_3/widgets_common/loading_indicator.dart';

class SearchScreen extends StatelessWidget {
  final String? title;

  const SearchScreen({Key? key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: title!.text.color(darkFontGrey).make(),
      ),
      body: FutureBuilder(
        future: FirestorServices.searchProducts(title),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: loadingIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return "Tidak ada penjual dengan nama tersebut".text.makeCentered();
          } else {
            var data = snapshot.data!.docs;
            var vendorSet = <String>{};
            var uniqueVendors = data.where((element) {
                String seller = element['p_seller'].toString().toLowerCase();
                if (seller.contains(title!.toLowerCase()) && !vendorSet.contains(seller)) {
                    vendorSet.add(seller);
                    return true;
                }
                return false;
            }).toList();
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: uniqueVendors.length,
                itemBuilder: (BuildContext context, int index) {
                  //var imageUrl = filtered[index]['imageUrl'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('vendors')
                                .doc(uniqueVendors[index]['vendor_id'])
                                .get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasData) {
                                dynamic vendorData = snapshot.data!.data();
                                String imageUrl = vendorData['imageUrl'];
                                return imageUrl.isNotEmpty
                                    ? Image.network(imageUrl,
                                            width: 70, fit: BoxFit.cover)
                                        .box
                                        .roundedFull
                                        .clip(Clip.antiAlias)
                                        .make()
                                    : Image.asset('assets/icons/user.png',
                                            width: 50, fit: BoxFit.cover)
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                "${uniqueVendors[index]['p_seller']}"
                                    .text
                                    .fontFamily(semibold)
                                    .color(darkFontGrey)
                                    .make(),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: darkFontGrey,
                          ),
                        ],
                      ),
                    ),
                  ).onTap(() {
                    Get.to(() => ProfileSeller(data: uniqueVendors[index]));
                  });
                },
              ),
            );
          }
        },
      ),
    );
  }
}
