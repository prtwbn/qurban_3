import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/consts/lists.dart';
import 'package:qurban_3/controllers/auth_controller.dart';
import 'package:qurban_3/views/auth_screen/signup_screen.dart';
import 'package:qurban_3/views/home_screen/home.dart';
import 'package:qurban_3/widgets_common/applogo_widget.dart';
//import 'package:flutter/src/widgets/framework.dart';
//import 'package:flutter/src/widgets/container.dart';
//import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/widgets_common/bg_widget.dart';
import 'package:qurban_3/widgets_common/custom_password.dart';
import 'package:qurban_3/widgets_common/custom_textField.dart';
import 'package:qurban_3/widgets_common/our_button.dart';

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Get.back(); // Navigate back when the arrow is pressed
          },
        ),
      ),
    
    body: bgWidget(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            (context.screenHeight * 0.1).heightBox,
            applogoWidget(),
            "Reset Password".text.black.size(22).fontFamily(semibold).make(),
            15.heightBox,
            Obx(
              () => Column(
                children: [
                  customTextField(
                      hint: emailHint,
                      title: email,
                      isPass: false,
                      controller: controller.emailController),
                      
                  controller.isloading.value
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(redColor),
                        )
                      : ourButton(
                          color: yellow,
                          title: "Kirim email reset password",
                          textColor: whiteColor,
                          onPress: () async {
                            if (controller.emailController.text.isEmpty) {
                              // Show an error message if the email field is empty
                              VxToast.show(context, msg: "Isi kolom email");
                            } else {
                              controller.isloading(true);
                              await controller
                                  .resetPassword(); // Call the resetPassword method
                              controller.isloading(false);
                            }
                          },
                          
                        ).box.width(context.screenWidth - 50).make(),
                        
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
        )
    ));
  }
}
