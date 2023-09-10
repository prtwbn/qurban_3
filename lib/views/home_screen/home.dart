import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/controllers/home_controller.dart';
import 'package:qurban_3/views/cart_screen.dart/cart_screen.dart';
import 'package:qurban_3/views/chat_screen/messaging_screen.dart';
//import 'package:qurban_3/views/category_screen/category_screen.dart';
import 'package:qurban_3/views/home_screen/home_screen.dart';
import 'package:qurban_3/views/lokasi_screen/lokasi_screen.dart';
import 'package:qurban_3/views/profile_screen/profile_screen.dart';
import 'package:qurban_3/views/wishlist_screen.dart/wishlist_screen.dart';
import 'package:qurban_3/widgets_common/exit_dialog.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(HomeController());
    var navbarItem = [
      BottomNavigationBarItem(
          icon: Image.asset(icHome, width: 32), label: home),
      //BottomNavigationBarItem(
        //  icon: Image.asset(icCategories, width: 32), label: categories),
      BottomNavigationBarItem(
          icon: Image.asset(icLokasi, width: 55), label: lokasi),
      BottomNavigationBarItem(
          icon: Image.asset(icCart, width: 30), label: cart),
      BottomNavigationBarItem(
          icon: Image.asset(icProfile, width: 53), label: account)
    ];
    var navBody = [
      const HomeScreen(),
      //const CategoryScreen(),
      const LokasiScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
    return WillPopScope(
      onWillPop: () async {
        showDialog(barrierDismissible: false,context: context, builder: (context) => exitDialog(context));
        return false;
      },
      child: Scaffold(
        body: Column(
          children: [
            Obx(() => Expanded(
                child: navBody.elementAt(controller.currentNavIndex.value))),
          ],
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.currentNavIndex.value,
            selectedItemColor: yellow,
            selectedLabelStyle: const TextStyle(fontFamily: semibold),
            type: BottomNavigationBarType.fixed,
            backgroundColor: whiteColor,
            items: navbarItem,
            onTap: (value) {
              controller.currentNavIndex.value = value;
            },
          ),
        ),
      ),
    );
  }
}
