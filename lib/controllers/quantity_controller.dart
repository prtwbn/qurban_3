import 'package:get/get.dart';

class QuantityController extends GetxController {
  var quantity = 0.obs;

  void increaseQuantity() {
    quantity.value++;
  }

  void decreaseQuantity() {
    if (quantity.value > 0) {
      quantity.value--;
    }
  }
}
