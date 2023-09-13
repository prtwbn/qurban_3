import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/controllers/chats_controller.dart';
import 'package:qurban_3/services/firestore_services.dart';
import 'package:qurban_3/views/chat_screen/components/sender_bubble.dart';
import 'package:qurban_3/widgets_common/loading_indicator.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final controller = Get.put(ChatsController());
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: "Chats".text.fontFamily(semibold).color(darkFontGrey).make(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: loadingIndicator());
                }
                return Expanded(
                    child: StreamBuilder(
                  stream: FirestorServices.getChatMessages(
                      controller.chatDocId.toString()),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: loadingIndicator(),
                      );
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child:
                            "Send a message...".text.color(darkFontGrey).make(),
                      );
                    } else {
                      return ListView.builder(
                        reverse: true, // ini akan membalik urutan item
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshot.data!
                              .docs[snapshot.data!.docs.length - index - 1];
                          return Align(
                              alignment: data['uid'] == currentUser!.uid
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: senderBubble(data));
                        },
                      );
                    }
                  },
                ));
              }),
              10.heightBox,
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: controller.msgController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: textfieldGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: textfieldGrey,
                        ),
                      ),
                      hintText: "Type a message...",
                    ),
                  )),
                  IconButton(
                      onPressed: () {
                        controller.sendMsg(controller.msgController.text);
                        controller.msgController.clear();
                      },
                      icon: const Icon(
                        Icons.send,
                        color: redColor,
                      ))
                ],
              )
                  .box
                  .height(60)
                  .padding(const EdgeInsets.all(12))
                  .margin(const EdgeInsets.only(bottom: 8))
                  .make(),
            ],
          ),
        ));
  }
}
