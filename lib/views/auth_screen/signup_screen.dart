import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/controllers/auth_controller.dart';
import 'package:qurban_3/views/auth_screen/login_screen.dart';
//import 'package:qurban_3/views/home_screen/home.dart';
//import 'package:qurban_3/consts/lists.dart';
import 'package:qurban_3/widgets_common/applogo_widget.dart';
//import 'package:flutter/src/widgets/framework.dart';
//import 'package:flutter/src/widgets/container.dart';
import 'package:qurban_3/widgets_common/bg_widget.dart';
import 'package:qurban_3/widgets_common/custom_password.dart';
import 'package:qurban_3/widgets_common/custom_textField.dart';
import 'package:qurban_3/widgets_common/our_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool? isCheck = false;
  var controller = Get.put(AuthController());

  //text controllers
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordRetypeController = TextEditingController();

  bool isInputValid() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordRetypeController.text.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            (context.screenHeight * 0.1).heightBox,
            applogoWidget(),
            "Daftar $appname".text.black.size(22).fontFamily(semibold).make(),
            15.heightBox,
            Obx(
              () => Column(
                children: [
                  customTextField(
                    hint: nameHint,
                    title: name,
                    controller: nameController,
                    isPass: false,
                  ),
                  customTextField(
                    hint: emailHint,
                    title: email,
                    controller: emailController,
                    isPass: false,
                  ),
                  CustomPassword(
                    hint: passwordHint,
                    title: password,
                    controller: passwordController,
                    isPass: true,
                  ),
                  CustomPassword(
                    hint: passwordHint,
                    title: retypePassword,
                    controller: passwordRetypeController,
                    isPass: true,
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            controller.navigateToPasswordResetPage();
                          }, child: forgetPass.text.make())),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: redColor,
                        checkColor: whiteColor,
                        value: isCheck,
                        onChanged: (newValue) {
                          setState(() {
                            isCheck = newValue;
                          });
                        },
                      ),
                      10.widthBox,
                      Expanded(
                        child: RichText(
                            text: const TextSpan(children: [
                          TextSpan(
                              text: "I agree to the ",
                              style: TextStyle(
                                  fontFamily: regular,
                                  //fontSize: 13,
                                  color: fontGrey)),
                          TextSpan(
                              text: termAndCond,
                              style: TextStyle(
                                  fontFamily: regular,
                                  //fontSize: 13,
                                  color: redColor)),
                          TextSpan(
                              text: " & ",
                              style: TextStyle(
                                  fontFamily: regular,
                                  fontSize: 13,
                                  color: redColor)),
                          TextSpan(
                              text: privacyPolicy,
                              style: TextStyle(
                                  fontFamily: regular,
                                  fontSize: 13,
                                  color: redColor)),
                        ])),
                      )
                    ],
                  ),
                  5.heightBox,
                  controller.isloading.value
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(redColor),
                        )
                      : ourButton(
                          color: isCheck == true ? yellow : lightGrey,
                          title: signup,
                          textColor: whiteColor,
                          onPress: () async {
                            if (isCheck != false) {
                              if (!isInputValid()) {
                                VxToast.show(context, msg: "Isi semua kolom");
                                return;
                              }

                              if (passwordController.text.length < 6) {
                                VxToast.show(context,
                                    msg:
                                        "Password harus memiliki setidaknya 6 karakter");
                                return;
                              }

                              if (passwordController.text !=
                                  passwordRetypeController.text) {
                                VxToast.show(context,
                                    msg: "Password tidak sama");
                                return;
                              }

                              controller.isloading(true);
                              try {
                                await controller
                                    .signupMethod(
                                        context: context,
                                        email: emailController.text,
                                        password: passwordController.text)
                                    .then((value) {
                                  return controller.storeUserData(
                                    email: emailController.text,
                                    password: passwordController.text,
                                    name: nameController.text,
                                  );
                                }).then((value) {
                                  VxToast.show(context,
                                      msg:
                                          "Pendaftaran berhasil, silahkan cek email untuk verifikasi akunmu untuk masuk ke aplikasi");
                                  Get.offAll(() => const LoginScreen());
                                });
                              } catch (e) {
                                auth.signOut();
                                VxToast.show(context, msg: e.toString());
                                controller.isloading(false);
                              }
                            }
                          }).box.width(context.screenWidth - 50).make(),
                  10.heightBox,
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: alreadyHaveAccount,
                          style: TextStyle(fontFamily: bold, color: fontGrey),
                        ),
                        TextSpan(
                          text: login,
                          style: TextStyle(fontFamily: bold, color: redColor),
                        ),
                      ],
                    ),
                  ).onTap(() {
                    Get.back();
                  })
                ],
              )
                  .box
                  .white
                  .rounded
                  .padding(const EdgeInsets.all(16))
                  .width(context.screenWidth - 70)
                  .shadowSm
                  .make(),
            ),
          ],
        ),
      ),
    ));
  }
}
