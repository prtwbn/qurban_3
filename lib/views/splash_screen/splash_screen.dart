import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:qurban_3/consts/colors.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:lottie/lottie.dart';
import 'package:qurban_3/views/auth_screen/login_screen.dart';
import 'package:qurban_3/views/home_screen/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  changeScreen(){
    Future.delayed(const Duration(seconds: 3),(){
      //Get.to(()=>const LoginScreen());

      auth.authStateChanges().listen((User? user) { 
        if (user == null && mounted) {
          Get.to(()=> const LoginScreen());
        }else{
          Get.to(()=> const Home());
        }
      });
    });
  }

  @override
  void initState() {
    changeScreen();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              height: 350,
              child: Lottie.asset('assets/animasi/sapi.json'),
            ),
          
            appname.text.fontFamily(bold).size(22).black.make(),
            10.heightBox,
            appdetail.text.fontFamily(bold).yellow900.make(),



          ],
        ),
      ),
    );
  }
}