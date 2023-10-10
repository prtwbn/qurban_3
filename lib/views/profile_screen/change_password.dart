//import 'dart:html';
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/controllers/profile_controller.dart';
import 'package:qurban_3/widgets_common/custom_password.dart';
//import 'package:qurban_3/widgets_common/bg_widget.dart';
import 'package:qurban_3/widgets_common/custom_textfield.dart';
import 'package:qurban_3/widgets_common/our_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  final dynamic data;
  const ChangePasswordScreen({Key? key, this.data}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var controller = Get.find<ProfileController>();

  @override
  void initState() {
    //controller.nameController.text = widget.username!;
    super.initState();
    controller.oldpassController.text = '';
    controller.newpassController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: whiteColor,
          appBar: AppBar(
            title: "Edit Profile"
                .text
                .color(darkFontGrey)
                .fontFamily(semibold)
                .make(),
            actions: [
              controller.isloading.value
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(redColor),
                    )
                  : ourButton(
                      color: brown,
                      onPress: () async {
                        controller.isloading(true);

                      if (controller.newpassController.text.length < 6) {
                        VxToast.show(context,
                            msg:
                                "Password tidak boleh kurang dari sama dengan 6 karakter");
                        controller.isloading(false);
                        return;
                      }

                      if (controller.snapshotData['password'] ==
                          controller.oldpassController.text) {
                        await controller.changeAuthPassword(
                          email: controller.snapshotData['email'],
                          password: controller.oldpassController.text,
                          newpassword: controller.newpassController.text,
                        );

                        // This line updates the password in the Firestore.
                        await controller.updatePw(
                            password: controller.newpassController.text);

                        controller.oldpassController.clear();
                        controller.newpassController.clear();

                        VxToast.show(context, msg: "Password Updated");
                        Navigator.pop(context);
                        controller.isloading(false);
                      } else {
                        // Message for incorrect old password
                        VxToast.show(context,
                            msg: "Password lama yang Anda masukkan salah");
                        controller.isloading(false);
                        }
                      },
                      textColor: whiteColor,
                      title: "Save",
                    ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              10.heightBox,
              CustomPassword(
                  controller: controller.oldpassController,
                  hint: passwordHint,
                  title: oldpass,
                  isPass: true),
              10.heightBox,
              CustomPassword(
                  controller: controller.newpassController,
                  hint: passwordHint,
                  title: newpass,
                  isPass: true),
            ]),
          ),
        ));
    //var controller = Get.find<ProfileController>();

    /*
    return bgWidget(
        child: Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.data['imageUrl'] == '' && controller.profileImgPath.isEmpty
                  ? Image.asset(imgProfile2, width: 100, fit: BoxFit.cover)
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make()
                  : widget.data['imageUrl'] != '' &&
                          controller.profileImgPath.isEmpty
                      ? Image.network(
                          widget.data['imageUrl'],
                          width: 100,
                          fit: BoxFit.cover,
                        ).box.roundedFull.clip(Clip.antiAlias).make()
                      : Image.file(
                          File(controller.profileImgPath.value),
                          width: 100,
                          fit: BoxFit.cover,
                        ).box.roundedFull.clip(Clip.antiAlias).make(),
              10.heightBox,
              ourButton(
                  color: yellow,
                  onPress: () {
                    controller.changeImage(context);
                    //Get.find<ProfileController>().changeImage(context);
                  },
                  textColor: whiteColor,
                  title: "Change"),
              const Divider(),
              20.heightBox,
              customTextField(
                  controller: controller.nameController,
                  hint: nameHint,
                  title: name,
                  isPass: false),
              10.heightBox,
              customTextField(
                  controller: controller.oldpassController,
                  hint: passwordHint,
                  title: oldpass,
                  isPass: true),
              10.heightBox,
              customTextField(
                  controller: controller.newpassController,
                  hint: passwordHint,
                  title: newpass,
                  isPass: true),
              20.heightBox,
              controller.isloading.value
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(redColor),
                    )
                  : SizedBox(
                      width: context.screenWidth - 60,
                      child: ourButton(
                          color: yellow,
                          onPress: () async {
                            controller.isloading(true);

                            //if img is not selected
                            if (controller.profileImgPath.value.isNotEmpty) {
                              await controller.uploadProfileImage();
                            } else {
                              controller.profileImageLink =
                                  widget.data['imageUrl'];
                            }

                            //if old pw match database
                            if (widget.data['password'] ==
                                // ignore: duplicate_ignore
                                controller.oldpassController.text) {
                              await controller.changeAuthPassword(
                                  email: widget.data['email'],
                                  password: controller.oldpassController.text,
                                  newpassword:
                                      controller.newpassController.text);
                              await controller.updateProfile(
                                  imgUrl: controller.profileImageLink,
                                  name: controller.nameController.text,
                                  password: controller.newpassController.text);
                             
                              VxToast.show(context, msg: "Updated");
                            } else if (controller
                                    .oldpassController.text.isEmptyOrNull &&
                                controller
                                    .newpassController.text.isEmptyOrNull) {
                              await controller.updateProfile(
                                  imgUrl: controller.profileImageLink,
                                  name: controller.nameController.text,
                                  password:
                                      widget.data['password']);
                              VxToast.show(context, msg: "Updated");
                            } else {
                              VxToast.show(context, msg: "Some error occured");
                              controller.isloading(false);
                            }
                          },
                          textColor: whiteColor,
                          title: "Save"),
                    ),
            ],
          )
              .box
              .white
              .shadowSm
              .padding(const EdgeInsets.all(16))
              .margin(const EdgeInsets.only(top: 50, left: 12, right: 12))
              .rounded
              .make(),
        ),
      ),
    ));*/
  }
}
