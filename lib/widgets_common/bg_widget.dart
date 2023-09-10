import 'package:flutter/material.dart';
import 'package:qurban_3/consts/consts.dart';

Widget bgWidget({Widget? child}){
  return Container(
    decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(imgBackground2), fit: BoxFit.fill)),
    child: child,
  );
}