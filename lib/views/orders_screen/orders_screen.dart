import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/services/firestore_services.dart';
import 'package:qurban_3/views/orders_screen/orders_detail.dart';
import 'package:qurban_3/widgets_common/loading_indicator.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey, // Ganti warna latar belakang
      appBar: AppBar(
        title: "Riwayat Booking".text.color(darkFontGrey).fontFamily(semibold).make(),
      ),
      body: StreamBuilder(
        stream: FirestorServices.getAllOrders(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: loadingIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return "Belum ada yang di booking !".text.color(darkFontGrey).makeCentered().p16(); // Tambahkan padding dan atur warna teks
          } else {
            var data = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(16), // Tambahkan padding pada ListView
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                var orderData = data[index].data() as Map<String, dynamic>;
                var products = orderData['orders'] as List<dynamic>;

                return Container(
                  decoration: BoxDecoration(
                    color: whiteColor, // Ganti warna latar belakang item
                    borderRadius: BorderRadius.circular(12), // Tambahkan border radius
                  ),
                  padding: const EdgeInsets.all(16), // Tambahkan padding pada item
                  child: ListTile(
                    contentPadding: EdgeInsets.zero, // Hilangkan padding tambahan pada ListTile
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var product in products)
                          if (product['sellername'] != null)
                            Text(
                              product['sellername'],
                              style: const TextStyle(fontFamily: semibold),
                            ),
                          
                        5.heightBox,
                        
                        if (orderData['total_amount'] != null)
                          'Rp${orderData['total_amount'].toString().numCurrency}'
                              .text
                              .fontFamily(bold)
                              .make(),
                        5.heightBox,
                        if (orderData['order_date'] != null)
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(orderData['order_date'].toDate()),
                            style: const TextStyle(fontFamily: bold),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Get.to(() => OrderDetails(data: data[index]));
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: darkFontGrey,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16), // Tambahkan jarak antara item
            );
          }
        },
      ),
    );
  }
}
