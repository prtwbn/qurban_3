import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/consts/firebase_const.dart';

class HomeController extends GetxController{
  @override
  void onInit() {
    getUsername();
    super.onInit();
  }
  var currentNavIndex = 0.obs;

  User? get currentUser => auth.currentUser;


  var username = ''.obs;

  var searchController = TextEditingController();

  var isLowestPrice = false.obs;
var isHighestPrice = false.obs;
  getUsername() async {
    if (currentUser == null) return; 
  var n = await firestore.collection(usersCollection).where('id', isEqualTo: currentUser!.uid).get().then((value) {
    if (value.docs.isNotEmpty) {
      return value.docs.single['name'];
    }
    return null; // Tambahkan ini untuk menangani kasus ketika tidak ada dokumen yang ditemukan
  });

  username.value = n ?? ''; // Menggunakan operator null-aware (?.) dan null-coalescing (??) untuk menangani nilai null
}

  void getSubCategories(String categoriesList) {}

}