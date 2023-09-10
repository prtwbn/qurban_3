import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/controllers/home_controller.dart';

class CartController extends GetxController {
  var totalP = 0.obs;
  late dynamic productSnapshot;
  var products = [];
  var vendors = [];
  var placingOrder = false.obs;
  int orderCode = 120;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nohpController = TextEditingController();

  calculate(data) {
    totalP.value = 0;
    for (var i = 0; i < data.length; i++) {
      totalP.value = totalP.value + int.parse(data[i]['tprice'].toString());
    }
  }

  decreaseStock() async {
    for (var i = 0; i < productSnapshot.length; i++) {
      var productId = productSnapshot[i]['product_id'];
      var productQty = int.parse(productSnapshot[i]['qty'].toString());

      DocumentSnapshot productDoc =
          await firestore.collection(productsCollection).doc(productId).get();
      var currentQty = int.parse(productDoc['p_quantity'].toString());
      var updatedQty =
          currentQty - productQty; // Hasil dari pengurangan adalah tipe int

      await firestore.collection(productsCollection).doc(productId).update({
        'p_quantity': updatedQty
            .toString() // Mengonversi kembali ke String saat menyimpan ke Firestore
      });
    }
  }

  String generateOrderCode() {
    String userId = currentUser!.uid;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return "${userId.substring(0, 4)}-${timestamp}";
  }

  placeMyOrder({required int totalAmount, required int remainingTime}) async {
    placingOrder(true);
    await getProductDetails();
    final cancelTime = DateTime.now().add(Duration(minutes: 1));

    String uniqueOrderCode = generateOrderCode();
    final homeController = Get.find<HomeController>();

    final counterRef = firestore.collection('metadata').doc('orderCounter');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Membaca current orderCode
      DocumentSnapshot counterSnapshot = await transaction.get(counterRef);
      if (!counterSnapshot.exists) {
        // Jika dokumen orderCounter belum ada, buat dengan nilai awal 1
        orderCode = 1;
        transaction.set(counterRef, {'current': orderCode});
      } else {
        orderCode =
            (counterSnapshot.data() as Map<String, dynamic>)['current'] + 1;

        transaction.update(counterRef, {'current': orderCode});
      }

      // Set pesanan dengan orderCode yang baru
      transaction.set(firestore.collection(orderCollection).doc(), {
        'order_code': uniqueOrderCode,
        'order_date': FieldValue.serverTimestamp(),
        'order_by': currentUser!.uid,
        'username': homeController.username.value,
        'order_by_name': nameController.text,
        'order_by_email': currentUser!.email,
        'order_by_nohp': nohpController.text,
        'order_placed': true,
        'order_confirmed': false,
        'order_delivered': false,
        'total_amount': totalAmount,
        'orders': products,
        'vendors': vendors,
        'cancel_time': cancelTime,
      });
    });

    placingOrder(false);
  }

  Stream<QuerySnapshot> getAllOrdersSorted() {
    return FirebaseFirestore.instance
        .collection('orders')
        .orderBy('order_date', descending: true)
        .snapshots();
  }

  getProductDetails() {
    products.clear();
    vendors.clear();
    for (var i = 0; i < productSnapshot.length; i++) {
      products.add({
        'product_id': productSnapshot[i]['product_id'],
        'img': productSnapshot[i]['img'],
        'vendor_id': productSnapshot[i]['vendor_id'],
        'price': productSnapshot[i]['price'],
        'tprice': productSnapshot[i]['tprice'],
        'qty': productSnapshot[i]['qty'],
        'title': productSnapshot[i]['title'],
        'sellername': productSnapshot[i]['sellername'],
      });
      vendors.add(productSnapshot[i]['vendor_id']);
    }
  }

  clearCart() {
    for (var i = 0; i < productSnapshot.length; i++) {
      firestore.collection(cartCollection).doc(productSnapshot[i].id).delete();
    }
  }
}
