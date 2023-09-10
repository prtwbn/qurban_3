import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/controllers/cart_controller.dart';
//import 'package:qurban_3/controllers/product_controller.dart';
import 'package:qurban_3/views/home_screen/home.dart';
//import 'package:qurban_3/views/orders_screen/orders_detail.dart';
import 'package:qurban_3/widgets_common/custom_textfield.dart';
import 'package:qurban_3/widgets_common/loading_indicator.dart';
import 'package:qurban_3/widgets_common/our_button.dart';
//import 'package:qurban_3/views/orders_screen/order_details.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ShippingDetails extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nohpController = TextEditingController();
  
/*
  _startTimer() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('remainingTime', 600); // Set sisa waktu ke 10 menit (600 detik)

  // Menggunakan Timer.periodic untuk mengurangi sisa waktu setiap detik
  Timer.periodic(Duration(seconds: 1), (timer) async {
    int remainingTime = prefs.getInt('remainingTime') ?? 0;
    if (remainingTime > 0) {
      remainingTime--;
      await prefs.setInt('remainingTime', remainingTime);
    } else {
      timer.cancel();
      // Lakukan tindakan ketika waktu habis
    }
  });
}*/

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<CartController>();
     
    return Obx(
      () => Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: "Booking Info"
              .text
              .fontFamily(semibold)
              .color(darkFontGrey)
              .make(),
        ),
        bottomNavigationBar: SizedBox(
          height: 60,
          child: controller.placingOrder.value
              ? Center(
                  child: loadingIndicator(),
                )
              : ourButton(
                  onPress: () async {
                    if (nameController.text.isEmpty || nohpController.text.isEmpty) {
                      VxToast.show(context, msg: "Nama lengkap dan nomor telepon harus diisi");
                    } else {
                       controller.nameController.text = nameController.text; // Simpan nilai nama ke controller
                      controller.nohpController.text = nohpController.text;
                      await controller.placeMyOrder(totalAmount: controller.totalP.value, remainingTime: 10 * 60);

                      await controller.decreaseStock(); 

                      
                      await controller.clearCart();
                      VxToast.show(context, msg: "Booking Berhasil. Silahkan Cek Bookingan Anda Dibagian My Orders di Menu Account");

                      
                      
                      Get.offAll(() => const Home());
                    }
                  },
                  color: (nameController.text.isEmpty || nohpController.text.isEmpty) ? Colors.yellow[800] : golden,
                  textColor: whiteColor,
                  title: "Continue",
                ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              customTextField(
                title: "Nama Lengkap",
                hint: "Nama Pembooking",
                controller: nameController,
                isPass: false,
              ),
              customTextField(
                title: "No Hp",
                hint: "No Hp",
                controller: nohpController,
                isPass: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
