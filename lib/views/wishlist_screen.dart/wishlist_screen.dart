import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';
//import 'package:qurban_3/consts/colors.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/services/firestore_services.dart';
import 'package:qurban_3/widgets_common/bg_widget.dart';
import 'package:qurban_3/widgets_common/loading_indicator.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
        title:
            "My Wishlist".text.color(darkFontGrey).fontFamily(semibold).make(),
      ),
        backgroundColor: whiteColor,
        body: StreamBuilder(
          stream: FirestorServices.getAllWishlists(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: loadingIndicator(),
              );
            } else if (snapshot.data!.docs.isEmpty) {
              return "Simpan Produkmu Disihi".text.color(darkFontGrey).makeCentered();
            } else {
              var data = snapshot.data!.docs;
              return Container(
                //margin: const EdgeInsets.only(top: 50), // Memberikan jarak 20 dari atas
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: Image.network(
                              "${data[index]['p_imgs'][0]}",
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                            title: "${data[index]['p_name']}"
                                .text
                                .fontFamily(semibold)
                                .size(16)
                                .make(),
                            subtitle: "${data[index]['p_price']}"
                                .numCurrency
                                .text
                                .color(redColor)
                                .fontFamily(semibold)
                                .make(),
                            trailing: const Icon(
                              Icons.favorite,
                              color: golden,
                            ).onTap(() async {
                              await firestore.collection(productsCollection).doc(data[index].id).set(
                                {
                                  'p_wishlist': FieldValue.arrayRemove([currentUser!.uid])
                                },
                                SetOptions(merge: true),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
