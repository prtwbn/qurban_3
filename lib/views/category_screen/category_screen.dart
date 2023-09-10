import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/consts/lists.dart';
import 'package:qurban_3/controllers/product_controller.dart';
import 'package:qurban_3/views/category_screen/category_details.dart';
import 'package:qurban_3/widgets_common/bg_widget.dart';
//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProductController());


    return bgWidget(
        child: Scaffold(
            appBar: AppBar(
              title: "Categories".text.fontFamily(bold).black.make(),
            ),
            body: Container(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 2,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 200),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Image.asset(categoriesImages[index],height: 100, width: 200, fit: BoxFit.cover),
                        //10.heightBox,
                        categoriesList[index].text.color(darkFontGrey).align(TextAlign.center).make(),
                      ],
                    ).box.yellow100.rounded.clip(Clip.antiAlias).outerShadowSm.make().onTap(() {
                      controller.getSubCategories(categoriesList[index]);
                      Get.to(()=> CategoryDetails(title: categoriesList[index]));
                    });
                  }),
            )));
  }
}
