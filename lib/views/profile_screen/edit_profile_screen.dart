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

class EditProfileScreen extends StatefulWidget {
  final dynamic data;
  const EditProfileScreen({Key? key, this.data}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var controller = Get.find<ProfileController>();
bool isStillActive = true;
  @override
  void initState() {
    isStillActive = false; 
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
            title: "Ubah Profil"
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
                      color: Colors.white, 
                      onPress: () async {
                        controller.isloading(true);
                        if (controller.profileImgPath.value.isNotEmpty) {
                          await controller.uploadProfileImage();
                        }

                        // Memanggil updateProfile dengan parameter yang benar
                        await controller.updateProfile(
                          imgUrl: controller
                              .profileImageLink, // Gunakan imgUrl dari controller
                          name: controller.nameController.text,
                          password: controller.newpassController
                              .text, // Jika password tidak diubah, gunakan password baru
                        );

                        VxToast.show(context, msg: "Terperbaharui");
                        //Navigator.pop(context);

// Cek apakah kolom password lama dan password baru kosong
                        if (controller.oldpassController.text.isEmpty &&
                            controller.newpassController.text.isEmpty) {
                          await controller.updateProfile(
                              imgUrl: controller.profileImageLink,
                              name: controller.nameController.text,
                              password: widget.data['password']);
                          VxToast.show(context, msg: "Terperbaharui");
                          Navigator.pop(context);
                          return; // Keluar dari fungsi onPress
                        }

                        // Validasi panjang password baru
                        if (controller.newpassController.text.length < 6) {
                          VxToast.show(context,
                              msg:
                                  "Maaf password tidak boleh kurang dari 6 karakter");
                          controller.isloading(false);
                          return;
                        }
                        //if img is not selected
                        if (controller.profileImgPath.value.isNotEmpty) {
                          await controller.uploadProfileImage();
                        } else {
                          controller.profileImageLink = widget.data['imageUrl'];
                        }

                        //if old pw match database
                        if (widget.data['password'] ==
                            // ignore: duplicate_ignore
                            controller.oldpassController.text) {
                          await controller.changeAuthPassword(
                              email: widget.data['email'],
                              password: controller.oldpassController.text,
                              newpassword: controller.newpassController.text);
                          await controller.updateProfile(
                              imgUrl: controller.profileImageLink,
                              name: controller.nameController.text,
                              password: controller.newpassController.text);

                          VxToast.show(context, msg: "Terperbaharui");
                          Navigator.pop(context);
                        } else if (controller
                                .oldpassController.text.isEmptyOrNull &&
                            controller.newpassController.text.isEmptyOrNull) {
                          await controller.updateProfile(
                              imgUrl: controller.profileImageLink,
                              name: controller.nameController.text,
                              password: widget.data['password']);
                          VxToast.show(context, msg: "Terperbaharui");
                          Navigator.pop(context);
                        } else if (widget.data['password'] !=
                            controller.oldpassController.text) {
                          VxToast.show(context,
                              msg:
                                  "Maaf password lama yang anda masukkan salah");
                          controller.isloading(false);
                        } else {
                          VxToast.show(context, msg: "Some error occured");
                          controller.isloading(false);
                        }
                      },
                      textColor: black,
                      title: "Simpan",
                    ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
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
                  title: "Ubah gambar"),
              const Divider(),
              20.heightBox,
              customTextField(
                  controller: controller.nameController,
                  hint: nameHint,
                  title: name,
                  isPass: false),
              
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
  }
}
