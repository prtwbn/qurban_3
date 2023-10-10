import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/controllers/cart_controller.dart';
import 'package:qurban_3/services/firestore_services.dart';
import 'package:qurban_3/views/cart_screen.dart/shipping_screen.dart';
import 'package:qurban_3/views/home_screen/home.dart';
import 'package:qurban_3/widgets_common/loading_indicator.dart';
import 'package:qurban_3/widgets_common/our_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(CartController());
    return Scaffold(
      backgroundColor: whiteColor,
      bottomNavigationBar: StreamBuilder(
        stream: FirestorServices.getCart(currentUser!.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else if (snapshot.data!.docs.isEmpty) {
            return SizedBox(
              height: 60,
              child: ourButton(
                color: golden,
                onPress: () {
                  Get.to(() => const Home());
                },
                textColor: whiteColor,
                title: "Pilih Hewan Qurban dan Aqiqah Terlebih Dahulu",
              ),
            );
          } else {
            var data = snapshot.data!.docs;
            var vendorIDs =
                Set<String>(); // Set untuk menyimpan vendorID yang unik

            // Mengecek vendorID pada setiap item dalam cart
            for (var item in data) {
              vendorIDs.add(item['vendor_id']);
            }

            if (vendorIDs.length > 1) {
              return SizedBox(
                height: 60,
                child: ourButton(
                  color: Colors
                      .grey, // Menampilkan tombol dalam keadaan tidak aktif
                  onPress: () {
                    // Tidak ada tindakan ketika tombol ditekan
                  },
                  textColor: whiteColor,
                  title: "Hanya bisa dari toko yang sama",
                ),
              );
            } else {
              return SizedBox(
                height: 60,
                child: ourButton(
                  color: golden,
                  onPress: () {
                    Get.to(() => ShippingDetails());
                  },
                  textColor: whiteColor,
                  title: "Booking",
                ),
              );
            }
          }
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: "Keranjang Saya"
            .text
            .color(darkFontGrey)
            .fontFamily(semibold)
            .make(),
      ),
      body: StreamBuilder(
        stream: FirestorServices.getCart(currentUser!.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: loadingIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: "Keranjang Kosong".text.color(darkFontGrey).make(),
            );
          } else {
            var data = snapshot.data!.docs;
            controller.calculate(data);
            controller.productSnapshot = data;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "${data[index]['sellername']}"
                                .text
                                .fontFamily(bold)
                                .size(16)
                                .make(),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    if (data[index]['qty'] > 1) {
                                      // Pastikan kuantitas lebih dari 1 sebelum mengurangi
                                      controller.decreaseCartQuantity(
                                          data[index].id, data[index]['qty']);
                                    }
                                  },
                                ),
                                Text(
                                  "${data[index]['qty']}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () async {
                                    DocumentSnapshot productData =
                                        await firestore
                                            .collection('products')
                                            .doc(data[index]['product_id'])
                                            .get();

                                    if (productData.exists) {
                                      // Mengambil nilai 'p_quantity' dan mengonversi ke integer
                                      int availableStock = int.tryParse(
                                              productData.get('p_quantity') ??
                                                  '0') ??
                                          0;

                                      if (data[index]['qty'] < availableStock) {
                                        // Periksa apakah qty di keranjang kurang dari stok produk yang tersedia
                                        controller.increaseCartQuantity(
                                            data[index].id, data[index]['qty']);
                                      } else {
                                        VxToast.show(context,
                                            msg: "Stok tidak cukup");
                                      }
                                    } else {
                                      VxToast.show(context,
                                          msg: "Produk tidak ditemukan");
                                    }
                                  },
                                ),
                              ],
                            ),
                            ListTile(
                              leading: Image.network(
                                "${data[index]['img']}",
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                              title:
                                  "${data[index]['title']} (x${data[index]['qty']})"
                                      .text
                                      .fontFamily(semibold)
                                      .size(16)
                                      .make(),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  "${data[index]['tprice']}"
                                      .numCurrency
                                      .text
                                      .color(brown)
                                      .fontFamily(semibold)
                                      .make(),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.delete,
                                color: golden,
                              ).onTap(() {
                                FirestorServices.deleteDocument(data[index].id);
                              }),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "Total Price"
                          .text
                          .fontFamily(semibold)
                          .color(brown)
                          .make(),
                      Obx(
                        () => "${controller.totalP.value}"
                            .numCurrency
                            .text
                            .fontFamily(semibold)
                            .color(brown)
                            .make(),
                      ),
                    ],
                  )
                      .box
                      .padding(const EdgeInsets.all(12))
                      .color(lightGolden)
                      .width(context.screenWidth - 60)
                      .roundedSM
                      .make(),
                  10.heightBox,
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
