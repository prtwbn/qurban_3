import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/consts/firebase_const.dart';
import 'package:qurban_3/controllers/home_controller.dart';

class ChatsController extends GetxController {
  @override
  void onInit() {
    getChatId();
    super.onInit();
  }

  final chats = firestore.collection(chatsCollection);

  final friendName = Get.arguments[0];
  final friendId = Get.arguments[1];

  final senderName = Get.find<HomeController>().username;
  
  final currentId = currentUser!.uid;

  var msgController = TextEditingController();

  dynamic chatDocId;

  var isLoading = false.obs;

  getChatId() async {
    isLoading(true);
    
    var chatSnapshot = await chats
    .where('users', arrayContainsAny: [friendId, currentId])
    .limit(1)
    .get();


    if (chatSnapshot.docs.isNotEmpty) {
      chatDocId = chatSnapshot.docs.single.id;
      //await chats.doc(chatDocId).update({'unread_count_pembeli': 0});
    } else {
      try {
        var addChat = await chats.add({
          'created_on': FieldValue.serverTimestamp(),
          'last_msg': '',
          'users': [friendId, currentId],
          'told': friendId,
          'fromId': currentId,
          'friend_name': friendName,
          'sender_name': senderName.value
        });
        chatDocId = addChat.id;
      } catch (e) {
        print(e);
      }
    }

    isLoading(false);
  }

  sendMsg(String msg) async {
    if (msg.trim().isNotEmpty) {
      chats.doc(chatDocId).update({
        'created_on': FieldValue.serverTimestamp(),
        'last_msg': msg,
        'told': friendId,
        'fromId': currentId,
        //'unread_count_penjual': FieldValue.increment(1), // Karena pesan ini dikirim oleh pembeli, jadi kita tambah count untuk penjual
      });

      chats.doc(chatDocId).collection(messagesCollection).doc().set({
        'created_on': FieldValue.serverTimestamp(),
        'msg': msg,
        'uid': currentId,
      });
    }
  }
}

