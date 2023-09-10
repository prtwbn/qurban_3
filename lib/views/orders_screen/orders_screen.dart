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
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: "My Orders".text.color(darkFontGrey).fontFamily(semibold).make(),
      ),
      body: StreamBuilder(
        stream: FirestorServices.getAllOrders(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: loadingIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return "No orders yet!".text.color(darkFontGrey).makeCentered();
          } else {
            var data = snapshot.data!.docs;
            
            return ListView.separated(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                var orderData = data[index].data() as Map<String, dynamic>;
                var products = orderData['orders'] as List<dynamic>;

                return ListTile(
                  
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
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(
                color: Colors.yellow,
                height: 1,
                thickness: 2,
              ),
            );
          }
        },
      ),
    );
  }
}
