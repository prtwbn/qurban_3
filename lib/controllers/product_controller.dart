import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/models/category_model.dart';
//import 'package:qurban_3/consts/firebase_const.dart';

class ProductController extends GetxController {
  var quantity = 0.obs;
  var totalPrice = 0.obs;

  var subcat = [];

  var isFav = false.obs;

  var isLowestToHighest = false.obs;
  


  getSubCategories(title) async {
    subcat.clear();
    var data = await rootBundle.loadString("lib/services/category_model.json");
    var decoded = categoryModelFromJson(data);
    var s =
        decoded.categories.where((element) => element.name == title).toList();

    for (var e in s[0].subcategory) {
      subcat.add(e);
    }
  }

  increaseQuantity(totalQuantity) {
    if (quantity.value < totalQuantity) {
      quantity.value++;
      //calculateTotalPrice(int.parse(data['p_price']));
    }
  }

  decreaseQuantity() {
    if (quantity.value > 0) {
      quantity.value--;
    }
  }

  calculateTotalPrice(price) {
    totalPrice.value = price * quantity.value;
  }

  
  addtoCart({docId, title, img, sellername, qty, tprice, context, price, vendorID, required int totalQuantity}) async {
    // Cek apakah produk dengan docId yang sama sudah ada di keranjang
    var existingProduct = await firestore.collection(cartCollection)
        .where('product_id', isEqualTo: docId)
        .where('added_by', isEqualTo: currentUser!.uid)
        .get();

    if (existingProduct.docs.isNotEmpty) {
        var existingQty = existingProduct.docs.first.get('qty') as int;
        qty += existingQty;

        // Pastikan jumlah produk tidak melebihi stok yang tersedia
        if (qty > totalQuantity) {
            VxToast.show(context, msg: "Maaf stok tidak cukup, anda sudah memasukkan produk di keranjang");
            return;
        }

        // Update qty di firestore untuk produk yang ada
        await firestore.collection(cartCollection)
            .doc(existingProduct.docs.first.id)
            .update({'qty': qty});
    } else {
        // Jika produk belum ada di keranjang, tambahkan ke firestore
        await firestore.collection(cartCollection).doc().set({
            'product_id': docId, 
            'title': title,
            'img': img,
            'sellername': sellername,
            'qty': qty,
            'vendor_id' : vendorID,
            'price' : price,
            'tprice': tprice,
            'added_by': currentUser!.uid
        }).catchError((error) {
            VxToast.show(context, msg: error.toString());
        });
    }
}



  

  resetValue() {
    totalPrice.value = 0;
    quantity.value = 0;
  }

  addToWishlist(docId, context) async {
    await firestore.collection(productsCollection).doc(docId).set({
      'p_wishlist': FieldValue.arrayUnion([currentUser!.uid])
    }, SetOptions(merge: true));
    isFav(true);
    VxToast.show(context, msg: "Added to wishlist");
  }

  removeFromWishlist(docId, context) async {
    await firestore.collection(productsCollection).doc(docId).set({
      'p_wishlist': FieldValue.arrayRemove([currentUser!.uid])
    }, SetOptions(merge: true));
    isFav(false);
    VxToast.show(context, msg: "Removed to wishlist");
  }

  checkIfFav(data) async {
    if (data['p_wishlist'].contains(currentUser!.uid)){
      isFav(true);
    }else{
      isFav(false);
    }
  }
  // product_controller.dart
}
