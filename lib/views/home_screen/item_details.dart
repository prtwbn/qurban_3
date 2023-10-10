import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
//import 'package:get/get_rx/src/rx_types/rx_string.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:get/get_core/src/get_main.dart';
//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';
//import 'package:qurban_3/consts/colors.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/controllers/home_controller.dart';
import 'package:qurban_3/controllers/product_controller.dart';
import 'package:qurban_3/views/chat_screen/chat_screen.dart';
import 'package:qurban_3/views/profile_seller.dart/profile_seller.dart';
import 'package:qurban_3/widgets_common/our_button.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetails extends StatelessWidget {
  final String? title;
  final dynamic data;

  const ItemDetails({Key? key, required this.title, this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProductController());
    controller.checkIfFav(data);

    var homeController = Get.find<HomeController>();

    return WillPopScope(
      onWillPop: () async {
        controller.resetValue();
        return true;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                controller.resetValue();
                Get.back();
              },
              icon: const Icon(Icons.arrow_back)),
          title: title!.text.color(darkFontGrey).fontFamily(bold).make(),
          actions: [
            /*
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                )), */
            Obx(
              () => IconButton(
                  onPressed: () {
                    if (controller.isFav.value) {
                      controller.removeFromWishlist(data.id, context);
                      //controller.isFav(false);
                    } else {
                      controller.addToWishlist(data.id, context);
                      //controller.isFav(true);
                    }
                  },
                  icon: Icon(
                    Icons.favorite_rounded,
                    color: controller.isFav.value ? redColor : fontGrey,
                  )),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VxSwiper.builder(
                      autoPlay: data['p_imgs'].length >
                          1, // Hanya otomatis putar jika lebih dari 1 gambar
                      height: 350,
                      itemCount: data['p_imgs'].length,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: data['p_imgs'].length >
                          1, // Hanya aktifkan infinite scroll jika lebih dari 1 gambar
                      onPageChanged: (index) {
                        // Anda dapat memperbarui state dengan indeks gambar saat ini, jika diperlukan.
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Menampilkan gambar dalam tampilan perbesar saat ditekan
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.7),
                                    leading: IconButton(
                                      icon: Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Tutup tampilan perbesar
                                      },
                                    ),
                                  ),
                                  body: PhotoViewGallery.builder(
                                    itemCount: data['p_imgs'].length,
                                    builder: (context, index) {
                                      return PhotoViewGalleryPageOptions(
                                        imageProvider:
                                            NetworkImage(data['p_imgs'][index]),
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        maxScale:
                                            PhotoViewComputedScale.covered * 2,
                                      );
                                    },
                                    scrollPhysics: BouncingScrollPhysics(),
                                    backgroundDecoration: BoxDecoration(
                                      color: Colors.black,
                                    ),
                                    pageController: PageController(
                                        initialPage:
                                            index), // Memulai dari gambar yang ditekan
                                    onPageChanged: (index) {
                                      // Anda dapat melakukan sesuatu saat halaman gambar berubah, jika diperlukan.
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              // Image
                              Image.network(
                                data["p_imgs"][index],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),

                              // Teks dengan indeks/total foto (hanya ditampilkan jika lebih dari 1 gambar)

                              Positioned(
                                bottom: 10, // posisi dari bawah gambar
                                right: 10, // posisi dari sisi kanan gambar
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  color: Colors
                                      .black54, // background hitam dengan sedikit transparansi
                                  child: Text(
                                    '${index + 1}/${data["p_imgs"].length}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),

                    10.heightBox,
                    title!.text
                        .size(16)
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .make(),
                    10.heightBox,
                    Row(
                      children: [
                        "${data['p_category']}"
                            .text
                            .color(darkFontGrey)
                            .fontFamily(bold)
                            .size(16)
                            .make(),
                        Icon(Icons.arrow_right_outlined),
                        SizedBox(width: 5),
                        "${data['p_subcategory']}"
                            .text
                            .color(darkFontGrey)
                            .fontFamily(semibold)
                            .size(14)
                            .make(),
                      ],
                    ),
                    10.heightBox,
                    "Rp${double.parse(data['p_price']).numCurrency}"
                        .text
                        .color(brown)
                        .fontFamily(semibold)
                        .size(18)
                        .make(),
                    10.heightBox,
                    Row(
                      children: [
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('vendors')
                              .doc(data['vendor_id'])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              dynamic vendorData = snapshot.data!.data();
                              String imageUrl = vendorData['imageUrl'];
                              return imageUrl.isNotEmpty
                                  ? Image.network(imageUrl,
                                          width: 50, fit: BoxFit.cover)
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
                        // Bagian untuk menampilkan nama penjual
    Expanded(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vendors')
            .doc(data['vendor_id'])
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && snapshot.data!.exists) {
              var vendorData = snapshot.data!.data() as Map<String, dynamic>;
              var vendorName = vendorData['name'];
              return GestureDetector(
                onTap: () {
                  Get.to(() => ProfileSeller(data: data));
                },
                child: Text(
                  vendorName,
                  style: TextStyle(
                    color: darkFontGrey,
                    fontFamily: semibold,
                  ),
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    ),

    // Bagian untuk menampilkan ikon pesan
    CircleAvatar(
      backgroundColor: Colors.white,
      child: Icon(Icons.message_rounded, color: darkFontGrey),
    ).onTap(() {
      Get.to(
        () => ChatScreen(),
        arguments: [data['p_seller'], data['vendor_id']],
      );
    }),
  ],
).box.height(60).padding(const EdgeInsets.symmetric(horizontal: 16)).color(textfieldGrey).make(),
                    //color selection
                    20.heightBox,
                    Column(
                      children: [
                        /* Row(
                          children: [
                            SizedBox(
                              width: 100,
                               child: "Color: ".text.color(textfieldGrey).make(),
                            ),
                            Row(
                              children: List.generate(
                                3,
                                (index) => VxBox()
                                    .size(40, 40)
                                    .roundedFull
                                    .color(Vx.randomPrimaryColor)
                                    .margin(
                                        const EdgeInsets.symmetric(horizontal: 4))
                                    .make(),
                              ),
                            )
                          ],
                        ).box.padding(const EdgeInsets.all(8)).make(), */

                        //quantity row
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child:
                                  "Jumlah: ".text.color(textfieldGrey).make(),
                            ),
                            Obx(
                              () => Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        controller.decreaseQuantity();
                                        controller.calculateTotalPrice(
                                          int.parse(data['p_price']),
                                        );
                                      },
                                      icon: const Icon(Icons.remove)),
                                  controller.quantity.value.text
                                      .size(16)
                                      .color(darkFontGrey)
                                      .fontFamily(bold)
                                      .make(),
                                  IconButton(
                                      onPressed: () {
                                        controller.increaseQuantity(
                                            int.parse(data['p_quantity']));
                                        controller.calculateTotalPrice(
                                            int.parse(data['p_price']));
                                      },
                                      icon: const Icon(Icons.add)),
                                  10.widthBox,
                                  "(${data['p_quantity']} tersedia)"
                                      .text
                                      .color(textfieldGrey)
                                      .make(),
                                ],
                              ),
                            ),
                          ],
                        ).box.padding(const EdgeInsets.all(8)).make(),

                        //total row
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: "Total: ".text.color(textfieldGrey).make(),
                            ),
                            Obx(
                              () =>
                                  "Rp${controller.totalPrice.value.numCurrency}"
                                      .text
                                      .color(brown)
                                      .size(16)
                                      .fontFamily(bold)
                                      .make(),
                            ),
                          ],
                        ).box.padding(const EdgeInsets.all(8)).make(),
                      ],
                    ).box.white.shadowSm.make(),

                    //description section
                    10.heightBox,

                    "Deskripsi"
                        .text
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .make(),
                    10.heightBox,
                    "${data['p_desc']}".text.color(darkFontGrey).make(),
                    10.heightBox,

                    "Berat"
                        .text
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .make(),
                    10.heightBox,
                    "${data['p_berat']}".text.color(darkFontGrey).make(),
                    10.heightBox,

                    "Jenis kelamin"
                        .text
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .make(),
                    10.heightBox,
                    "${data['p_jeniskelamin']}".text.color(darkFontGrey).make(),
                    10.heightBox,

                    "Umur".text.color(darkFontGrey).fontFamily(semibold).make(),
                    10.heightBox,
                    "${data['p_umur']}".text.color(darkFontGrey).make(),

                    10.heightBox,

                    "Apakah memiliki Surat Keterangan Sehat ?"
                        .text
                        .color(darkFontGrey)
                        .fontFamily(semibold)
                        .make(),
                    10.heightBox,
                    "${data['p_sks']}".text.color(darkFontGrey).make(),
                    /*
                    10.heightBox,
                    SizedBox(
                      height: 200,
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('vendors')
                            .doc(data['vendor_id'])
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            GeoPoint geoPoint =
                                snapshot.data!['vendor_location'];
                            LatLng sellerLocation =
                                LatLng(geoPoint.latitude, geoPoint.longitude);
                            return GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: sellerLocation,
                                zoom: 14.0,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('marker_1'),
                                  position: sellerLocation,
                                ),
                              },
                            );
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                    */

                    20.heightBox,
                  ],
                ),
              ),
            )),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ourButton(
                  color: golden,
                  onPress: () {
                    if (controller.quantity.value > 0) {
                      controller.addtoCart(
                          context: context,
                          docId: data['product_id'],
                          vendorID: data['vendor_id'],
                          img: data['p_imgs'][0],
                          qty: controller.quantity.value,
                          //sellername: data['p_seller'],
                          title: data['p_jenishewan'],
                          price: data['p_price'],
                          tprice: controller.totalPrice.value,
                          totalQuantity: int.parse(data['p_quantity']));
                      VxToast.show(context, msg: "Dimasukkan ke keranjang");
                    } else {
                      VxToast.show(context, msg: "Jumlah hewan tidak boleh 0");
                    }
                  },
                  textColor: whiteColor,
                  title: "Tambahkan ke keranjang"),
            ),
          ],
        ),
      ),
    );
  }
}
