import 'package:flutter/material.dart';
import 'package:qurban_3/consts/consts.dart';

Widget ourButton({onPress, color, textColor, String? title}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.all(12),
    ),
    
    onPressed: onPress,
    child: title!.text.color(textColor).fontFamily(bold).make());
}
