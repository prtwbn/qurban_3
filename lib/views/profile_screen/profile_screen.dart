import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/consts/lists.dart';
import 'package:qurban_3/controllers/auth_controller.dart';
import 'package:qurban_3/controllers/profile_controller.dart';
import 'package:qurban_3/services/firestore_services.dart';
import 'package:qurban_3/views/auth_screen/login_screen.dart';
import 'package:qurban_3/views/chat_screen/messaging_screen.dart';
import 'package:qurban_3/views/orders_screen/orders_screen.dart';
import 'package:qurban_3/views/profile_screen/edit_profile_screen.dart';
import 'package:qurban_3/views/wishlist_screen.dart/wishlist_screen.dart';
import 'package:qurban_3/widgets_common/bg_widget.dart';
//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBar();
    var controller = Get.put(ProfileController());
    //FirestorServices.getCounts();
    return bgWidget(
        child: Scaffold(
      body: StreamBuilder(
        stream: FirestorServices.getUser(currentUser!.uid),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(redColor),
              ),
            );
          } else {
            var data = snapshot.data!;
            return SafeArea(
                child: Column(
              children: [
                //edit profile button
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: const Align(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.edit, color: black))
                      .onTap(() {
                    controller.nameController.text = data['name'];
                    //controller.passController.text = data['password'];
                    Get.to(() => EditProfileScreen(
                          data: data,
                        ));
                  }),
                ),

                //users details section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      data['imageUrl'] == ''
                          ? Image.asset(imgProfile2,
                                  width: 80, fit: BoxFit.cover)
                              .box
                              .roundedFull
                              .clip(Clip.antiAlias)
                              .make()
                          : Image.network(data['imageUrl'],
                                  width: 100, fit: BoxFit.cover)
                              .box
                              .roundedFull
                              .clip(Clip.antiAlias)
                              .make(),
                      10.widthBox,
                      
                     
                    ],
                  ),
                ),
                10.heightBox,
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "${data['name']}".text.fontFamily(bold).black.make(),
                    
                  ],
                ),
                ),
                5.heightBox,
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "${data['email']}".text.black.make(),
                    
                  ],
                ),
                ),
                

                /*
                FutureBuilder(
                    future: FirestorServices.getCounts(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: loadingIndicator());
                      }else{
                        var countData = snapshot.data;
                        return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          detailsCard(
                              count: countData[0].toString(),
                              title: "your cart",
                              width: context.screenWidth / 3.3),
                          detailsCard(
                              count: countData[1].toString(),
                              title: "your wishlist",
                              width: context.screenWidth / 3.3),
                          detailsCard(
                              count: countData[2].toString(),
                              title: "your orders",
                              width: context.screenWidth / 3.3),
                        ],
                      );
                      }
                      
                    }),
                    */

                /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    detailsCard(
                        count: data['cart_count'],
                        title: "in your cart",
                        width: context.screenWidth / 3.4),
                    detailsCard(
                        count: data['wishlist_count'],
                        title: "in your wishlist",
                        width: context.screenWidth / 3.4),
                    detailsCard(
                        count: data['order_count'],
                        title: "your orders",
                        width: context.screenWidth / 3.4),
                  ],
                ),
                */

                30.heightBox,

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (context, index) {
                          return const Divider(color: golden, height: 1);
                        },
                        itemCount: profileButtonsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: (() async {
                              switch (index) {
                                case 0:
                                  Get.to(() => const WishlistScreen());
                                  break;
                                case 1:
                                  Get.to(() => const OrdersScreen());
                                  break;
                                case 2:
                                  Get.to(() => const MessagesScreen());
                                  break;
                                case 3:
                                 await Get.put(AuthController()).signoutMethod();
                                Get.offAll(() => const LoginScreen());
                                break;
                              }
                            }),
                            leading: Image.asset(
                              profileButtonIcon[index],
                              width: 22,
                            ),
                            title: profileButtonsList[index]
                                .text
                                .fontFamily(semibold)
                                .color(darkFontGrey)
                                .make(),
                          );
                        },
                      ),
                    ),
                  ],
                ) //.box.white.rounded.padding(const EdgeInsets.symmetric(horizontal: 16)).shadowSm.make(),
              ],
            ));
          }
        },
      ),
    ));
  }
}
