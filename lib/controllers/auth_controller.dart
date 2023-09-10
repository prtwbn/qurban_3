import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';

class AuthController extends GetxController {
  var isloading = false.obs;
  //textcontrollers
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  //login method

  Future<UserCredential?> loginMethod({context}) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  //signup method
  Future<UserCredential?> signupMethod(
      {required String email, required String password, required BuildContext context}) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
          currentUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  //storing data method
  storeUserData({name, password, email}) async {
  DocumentReference store = firestore.collection(usersCollection).doc(currentUser!.uid);
  await store.set({
    'name': name,
    'password': password,
    'email': email,
    'imageUrl': '',
    'id': currentUser!.uid,
    'cart_count' : "00",
    'wishlist_count' : "00",
    "order_count" : "00",
  }, SetOptions(merge: true));
}


  //signout method
  signoutMethod() async {
    try {
      await auth.signOut();
    } catch (e) {
      VxToast.show(Get.context!, msg: e.toString());
    }
  }
}
