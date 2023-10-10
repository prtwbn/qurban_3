import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/views/auth_screen/forget_password.dart';
import 'package:qurban_3/views/auth_screen/login_screen.dart';
import 'package:qurban_3/views/auth_screen/signup_screen.dart';

class AuthController extends GetxController {
  var isloading = false.obs;
  //textcontrollers
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  //login method

  Future<UserCredential?> loginMethod({context}) async {
    UserCredential? userCredential;

    // Cek apakah email dan password sudah diisi
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      VxToast.show(context, msg: "Silahkan isi email dan password");
      return null;
    }
    QuerySnapshot users = await firestore
        .collection(usersCollection)
        .where('email', isEqualTo: emailController.text)
        .get();
    if (users.docs.isEmpty) {
      VxToast.show(context, msg: "Email tidak ditemukan dalam daftar pembeli");
      return null;
    }

    try {
      userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      // Periksa apakah email sudah diverifikasi
      if (!userCredential.user!.emailVerified) {
        VxToast.show(context,
            msg:
                "Email belum diverifikasi, silahkan verifikasi untuk masuk ke aplikasi");
        isloading(false);
        Get.off(() => const LoginScreen());
        return null;
      }
      // Setelah berhasil masuk, perbarui currentUser
      currentUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        VxToast.show(context, msg: "Email tidak terdaftar");
      } else if (e.code == 'invalid-email') {
        VxToast.show(context,
            msg: "Format email salah, silahkan masukkan email yang benar");
      } else if (e.code == 'wrong-password') {
        VxToast.show(context,
            msg: "Password salah, masukkan password yang benar");
      } else {
        VxToast.show(context, msg: e.toString());
      }
    }
    return userCredential;
  }

  //signup method
  Future<UserCredential?> signupMethod(
      {required String email,
      required String password,
      required BuildContext context}) async {
    UserCredential? userCredential;

    if (password.length < 6) {
      VxToast.show(context,
          msg: "Password harus memiliki setidaknya 6 karakter");
      return null;
    }
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Kirim email verifikasi
      await userCredential.user?.sendEmailVerification();

      currentUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        VxToast.show(context,
            msg: "Format email salah, silahkan masukkan email yang benar");
      } else {
        VxToast.show(context, msg: e.toString());
      }
      return null; // Hentikan eksekusi kode di sini
    }

    return userCredential;
  }

  //storing data method
  storeUserData({name, password, email}) async {
    DocumentReference store =
        firestore.collection(usersCollection).doc(currentUser!.uid);
    await store.set({
      'name': name,
      'password': password,
      'email': email,
      'imageUrl': '',
      'id': currentUser!.uid,
      'cart_count': "00",
      'wishlist_count': "00",
      "order_count": "00",
    }, SetOptions(merge: true));
  }

  //signout method
  signoutMethod() async {
    try {
      await auth.signOut();

      // Pembersihan state
      emailController.clear();
      passwordController.clear();
      currentUser = null;

      await auth.userChanges().listen((user) {
        if (user == null) {
          Get.off(() => const LoginScreen());
        }
      });
    } catch (e) {
      VxToast.show(Get.context!, msg: e.toString());
    }
  }

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim())
          .then((_) {
        VxToast.show(Get.overlayContext!,
            msg: "Password reset email terkirim. Silahkan periksa email anda.");
      });
    } catch (e) {
      VxToast.show(Get.overlayContext!,
          msg: "Gagal mengirim email reset password. Silahkan coba lagi.");
    }
  }

  void navigateToPasswordResetPage() {
    Get.to(() => PasswordResetScreen());
  }
}
