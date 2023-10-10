//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qurban_3/consts/consts.dart';

class FirestorServices {
  //get user data
  static getUser(uid) {
    return firestore.collection(usersCollection).doc(uid).snapshots();
  }
  //get products

  static getProducts(category) {
    return firestore
        .collection(productsCollection)
        .where('p_category', isEqualTo: category)
        .snapshots();
  }

  //sub cat
  static getSubCategoryProducts(title) {
    return firestore
        .collection(productsCollection)
        .where('p_subcategory', isEqualTo: title)
        .snapshots();
  }

  //get cart
  static getCart(uid) {
    return firestore
        .collection(cartCollection)
        .where('added_by', isEqualTo: uid)
        .snapshots();
  }

  //delete doc
  static deleteDocument(docId) {
    return firestore.collection(cartCollection).doc(docId).delete();
  }

  //get all chat messages
  static getChatMessages(docId) {
    return firestore
        .collection(chatsCollection)
        .doc(docId)
        .collection(messagesCollection)
        .orderBy('created_on', descending: false)
        .snapshots();
  }

  static getAllOrdersSorted() {
    return firestore
        .collection(orderCollection)
        .where('order_by', isEqualTo: currentUser!.uid)
        .orderBy('order_date', descending: true)
        .snapshots();
  }

  static getAllOrders() {
    return firestore
        .collection(orderCollection)
        .where('order_by', isEqualTo: currentUser!.uid)
        .orderBy('order_date', descending: true)
        .snapshots();
  }

  static getAllWishlists() {
    return firestore
        .collection(productsCollection)
        .where('p_wishlist', arrayContains: currentUser!.uid)
        .snapshots();
  }

  static getAllMessages(uid) {
    print(uid);
    return firestore
        .collection(chatsCollection)
        .where('users', arrayContains: uid)
        .orderBy('created_on', descending: true)  // Urutkan berdasarkan 'created_on' dengan yang terbaru di atas
        .snapshots();
}


  static getCounts() async {
    var res = await Future.wait([
      firestore
          .collection(cartCollection)
          .where('added_by', isEqualTo: currentUser!.uid)
          .get()
          .then((value) {
        return value.docs.length;
      }),
      firestore
          .collection(productsCollection)
          .where('p_wishlist', arrayContains: currentUser!.uid)
          .get()
          .then((value) {
        return value.docs.length;
      }),
      firestore
          .collection(orderCollection)
          .where('order_by', isEqualTo: currentUser!.uid)
          .get()
          .then((value) {
        return value.docs.length;
      })
    ]);
    return res;
  }

  static allproducts() {
    return firestore.collection(productsCollection)
      .orderBy('timestamp', descending: true) // Urutkan berdasarkan timestamp dari yang terbaru
      .snapshots();
  }
  static allVendors() {
    return firestore.collection('vendors').snapshots();
  }

  static searchProducts(title) {
    return firestore.collection(productsCollection).get();
  }

  static Future<QuerySnapshot> searchVendors(String? title) {
  return firestore
      .collection('vendors')
      .where('name', isGreaterThanOrEqualTo: title)
      .get();
}
}
