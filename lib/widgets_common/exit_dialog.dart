import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurban_3/widgets_common/our_button.dart';

import '../consts/consts.dart';

Widget exitDialog(context){
  return Dialog(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        "confirm".text.fontFamily(bold).size(18).color(darkFontGrey).make(),
        const Divider(),
        10.heightBox,
        "Are You Sure Want To Exit?"
        .text.size(16).color(darkFontGrey).make(),
        10.heightBox,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ourButton(
              color: redColor,
              onPress: (){
                SystemNavigator.pop();
              },
              textColor: whiteColor,
              title: "Yes"
            ),
            ourButton(
              color: redColor,
              onPress: (){
                Navigator.pop(context);
              },
              textColor: whiteColor,
              title: "No"
            ),
          ],
        ),
      ],
    ).box.color(lightGrey).padding(const EdgeInsets.all(12)).rounded.make(),
  );
}