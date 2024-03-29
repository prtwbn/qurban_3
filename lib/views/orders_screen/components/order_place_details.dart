import 'package:flutter/cupertino.dart';
import 'package:qurban_3/consts/consts.dart';

Widget orderPlaceDetails({title1, title2, d1, d2}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "$title1".text.fontFamily(semibold).size(12).make(),
            "$d1".text.color(redColor).fontFamily(semibold).size(12).make(),
          ],
        ),
        SizedBox(
          width: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "$title2".text.fontFamily(semibold).size(12).make(),
              "$d2".text.size(12).make(),
            ],
          ),
        )
      ],
    ),
  );
}
