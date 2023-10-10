import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';
//import 'package:qurban_3/consts/colors.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/services/firestore_services.dart';
import 'package:qurban_3/views/chat_screen/chat_screen.dart';
import 'package:qurban_3/widgets_common/loading_indicator.dart';
import 'package:intl/intl.dart' as intl;

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title:
            "Pesan Saya".text.color(darkFontGrey).fontFamily(semibold).make(),
      ),
      body: StreamBuilder(
        stream: FirestorServices.getAllMessages(currentUser!.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: loadingIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return "No messages yet!".text.color(darkFontGrey).makeCentered();
          } else {
            var data = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: List.generate(data.length, (index) {
                      var t = data[index]['created_on'] == null
                          ? DateTime.now()
                          : data[index]['created_on'].toDate();
                      var time = intl.DateFormat("h:mma").format(t);
                      // print(data[index]['friend_name']);
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('vendors')
                            .doc(data[index]['users']
                                .where((user) => user != currentUser!.uid)
                                .first)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasData) {
                            dynamic userData = userSnapshot.data!.data();

                            String imageUrl = userData['imageUrl'];

                            return ListTile(
                              onTap: () {
                                Get.to(() => const ChatScreen(), arguments: [
                                  data[index]['users']
                                      .where((user) => user != currentUser!.uid)
                                      .first,
                                  data[index]['users']
                                      .where((user) => user != currentUser!.uid)
                                      .first,
                                  data[index]['told'],
                                ]);
                              },
                              leading: imageUrl.isNotEmpty
                                  ? Image.network(imageUrl,
                                          width: 50, fit: BoxFit.cover)
                                      .box
                                      .roundedFull
                                      .clip(Clip.antiAlias)
                                      .make()
                                  : Image.asset('assets/icons/user.png',
                                          width: 40, fit: BoxFit.cover)
                                      .box
                                      .roundedFull
                                      .clip(Clip.antiAlias)
                                      .make(),
                              title: "${userData['name']}"
                                  .text
                                  .fontFamily(semibold)
                                  .color(darkFontGrey)
                                  .make(),
                              subtitle:
                                  "${data[index]['last_msg']}".text.make(),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  time.text
                                      .fontFamily(semibold)
                                      .color(darkFontGrey)
                                      .make(),
                                  if (data[index]['unread_count_pembeli'] !=
                                          null &&
                                      data[index]['unread_count_pembeli'] > 0)
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        '${data[index]['unread_count_pembeli']}',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Text('Failed to load data');
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },

                        /*
                        leading: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('vendors')
                              .doc(data[index]['told'])
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
                        */
                      );
                    }),
                  )),
            );
          }
        },
      ),
    );
  }
}
