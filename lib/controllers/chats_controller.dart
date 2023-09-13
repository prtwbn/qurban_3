import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/consts/firebase_const.dart';
import 'package:qurban_3/controllers/home_controller.dart';

class ChatsController extends GetxController {
  late String friendName;
  late String friendId;
  late CollectionReference chats;
  late String senderName;
  late String currentId;
  late TextEditingController msgController;
  dynamic chatDocId;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    friendName = Get.arguments[0];
    friendId = Get.arguments[1];
    chats = FirebaseFirestore.instance.collection(chatsCollection);
    senderName = Get.find<HomeController>().username.value;
    currentId = currentUser!.uid;
    msgController = TextEditingController();

    getChatId();
  }

  void getChatId() async {
    print("friendId: ${friendId}");
    print("currentId: ${currentId}");
    var chatSnapshot = await chats.where('users', whereIn: [
      [friendId, currentId],
      [currentId, friendId]
    ]).get();

    print("chatSnapshot.docs: ${chatSnapshot.docs}");


    if (chatSnapshot.docs.isNotEmpty) {
      chatDocId = chatSnapshot.docs.single.id;
      //await chats.doc(chatDocId).update({'unread_count_pembeli': 0});
    } else {
        var addChat = await chats.add({
          'created_on': FieldValue.serverTimestamp(),
          'last_msg': '',
          'users': [friendId, currentId],
          'told': friendId,
          'fromId': currentId,
          'friend_name': friendName,
          'sender_name': senderName
        });
        chatDocId = addChat.id;
      }
      
    

    isLoading(false);
  }

  void sendMsg(String msg) async {
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

