import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qurban_3/consts/consts.dart';
import 'package:qurban_3/views/chat_screen/chat_screen.dart';
import 'package:qurban_3/views/lokasi_screen/vendor_screen.dart';
import 'package:qurban_3/views/orders_screen/components/order_place_details.dart';
import 'package:qurban_3/views/orders_screen/components/order_status.dart';
import 'package:intl/intl.dart' as intl;
import 'package:qurban_3/views/orders_screen/vendor.dart';
import 'package:qurban_3/views/profile_seller.dart/profile_seller.dart';

class OrderDetails extends StatefulWidget {
  final dynamic data;
  const OrderDetails({Key? key, this.data}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final TextEditingController cancellationReasonController =
      TextEditingController();

  void cancelOrder() async {
    if (widget.data['order_placed'] == false) {
      // Order sudah dibatalkan sebelumnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Maaf bookingan sudah dibatalkan sebelumnya"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    // 1. Mengubah `order_placed` menjadi `false`.

    // 2. Mengembalikan stock produk seperti semula.
    // Jika Anda memiliki field 'stock' di setiap produk di collection produk, Anda bisa melakukan perbaruan sebagai berikut:
    for (var order in widget.data['orders']) {
      var productId = order['product_id'];
      var quantityOrdered = order['qty']; // Tidak perlu konversi ke int

      var productRef = firestore.collection(productsCollection).doc(productId);

      // Mengambil data produk saat ini
      var productData = await productRef.get();

      var currentStock;
      // Check jika p_quantity berupa string atau int
      if (productData['p_quantity'] is String) {
        currentStock = int.tryParse(productData['p_quantity']) ?? 0;
      } else {
        currentStock = productData['p_quantity'];
      }

      // Update stock produk
      await productRef.update({
        'p_quantity': (currentStock + quantityOrdered)
            .toString() // Ubah ke string jika Anda ingin menyimpannya sebagai string
      });
    }
  }

  void cancelOrderConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Apakah Anda yakin ingin membatalkan bookingan ini?"),
              SizedBox(height: 20.0),
              TextField(
                controller: cancellationReasonController,
                decoration: InputDecoration(
                  labelText: "Alasan Pembatalan",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Tidak"),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: Text("Ya"),
              onPressed: () async {
                if (cancellationReasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Harap isi alasan pembatalan agar bookingan dapat dibatalkan!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                // Simpan alasan pembatalan ke Firebase
                await firestore
                    .collection(orderCollection)
                    .doc(widget.data.id)
                    .update({
                  'cancellation_reason': cancellationReasonController.text,
                  'order_placed': false
                });

                // Tutup dialog
                Navigator.of(context).pop();

                if (widget.data['order_placed'] == false) {
                  // Order sudah dibatalkan sebelumnya
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Maaf bookingan sudah dibatalkan sebelumnya"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                } else {
                  cancelOrder(); // Panggil fungsi cancelOrder
                }
              },
            ),
          ],
        );
      },
    );
  }

  //var controller = Get.put(OrdersController());
  /*Timer? _timer;

  int secondsRemaining = 30; // 10 minutes in seconds
  late String documentId;

  @override
  void initState() {
    super.initState();
    documentId = widget.data.id;

    final cancelTime = widget.data['cancel_time'].toDate();
    final currentTime = DateTime.now();

    if (currentTime.isAfter(cancelTime)) {
      cancelOrderAndRestoreStock();
    } else {
      final timeDifference = cancelTime.difference(currentTime);
      secondsRemaining = timeDifference.inSeconds;

      // Periksa apakah pesanan sudah dibatalkan
      if (widget.data['order_placed'] == true &&
          currentTime.isBefore(cancelTime)) {
        startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer?.cancel();
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          timer.cancel();
          cancelOrderAndRestoreStock();
          // Cancel the order here
        }
      });
    });
  }

  void cancelOrderAndRestoreStock() async {
    DocumentSnapshot orderDoc =
        await firestore.collection(orderCollection).doc(documentId).get();
    if (orderDoc['order_placed'] == true) {
      // Batalkan pesanan
      await firestore.collection(orderCollection).doc(documentId).update({
        'order_placed': false,
      });
// Mengembalikan stok
      List orders = widget.data['orders'];
      for (var order in orders) {
        // Ambil data produk berdasarkan id
        DocumentSnapshot productDoc = await firestore
            .collection(productsCollection)
            .doc(order['product_id'])
            .get();
        int currentQty = int.parse(productDoc['p_quantity'].toString());
        int orderQty = int.parse(order['qty'].toString());

        // Update stok produk
        await firestore
            .collection(productsCollection)
            .doc(order['product_id'])
            .update({'p_quantity': (currentQty + orderQty).toString()});
      }
    }
  }

  String _formatTime() {
    final minutes = (secondsRemaining / 60).floor();
    final seconds = secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  } */
  Position? _buyerPosition;
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    //_updateBuyerLocation();
  }

  Future<void> _requestLocationPermission() async {
    final permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.denied) {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Izinkan lokasi untuk melihat jarak antara anda dan penjual'),
          ),
        );
        return;
      }
    }

    if (permissionStatus == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Location permission permanently denied. Please enable it in app settings.',
          ),
        ),
      );
      return;
    }

    if (mounted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    final permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.denied ||
        permissionStatus == LocationPermission.deniedForever) {
      await _requestLocationPermission();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _buyerPosition = position;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }
/*
  void _updateBuyerLocation() async {
    // Memperbarui lokasi pembeli secara periodik
    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      _getCurrentLocation();
    }
  }*/

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadius = 6371; // Radius bumi dalam kilometer
    double latDiff = _radians(endLatitude - startLatitude);
    double lonDiff = _radians(endLongitude - startLongitude);
    double a = sin(latDiff / 2) * sin(latDiff / 2) +
        cos(_radians(startLatitude)) *
            cos(_radians(endLatitude)) *
            sin(lonDiff / 2) *
            sin(lonDiff / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  double _radians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    final documentId = widget.data.id;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: "Detail Bookingan"
            .text
            .color(darkFontGrey)
            .fontFamily(semibold)
            .make(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              orderStatus(
                  color: redColor,
                  icon: Icons.done,
                  title: "Booking",
                  showDone: widget.data['order_placed']),
              5.heightBox,
              orderStatus(
                  color: Colors.purple,
                  icon: Icons.done_all_rounded,
                  title: "Done",
                  showDone: widget.data['order_delivered']),
              10.heightBox,
              SizedBox(
                width: double.infinity, // Menyesuaikan lebar dengan parent
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 219, 201, 32),
                    onPrimary: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  onPressed: widget.data['order_placed']
                      ? cancelOrderConfirmation
                      : null,
                  child: Text("Cancel Booking"),
                ),
              ),
              const Divider(),
              10.heightBox,
              Card(
                elevation: 4,
                margin: EdgeInsets.all(0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ordered Product",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      20.heightBox,
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.data['orders'].length,
                        itemBuilder: (BuildContext context, int index) {
                          final order = widget.data['orders'][index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(11.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        order['sellername'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => VendorScren(
                                                data: order,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "kunjungi toko",
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(color: yellow2),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        order['img'],
                                        width: 40,
                                        fit: BoxFit.cover,
                                      ),
                                      5.heightBox,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            orderPlaceDetails(
                                              title1: order['title'],
                                              title2:
                                                  "Rp ${order['price'].toString().numCurrency}",
                                              d1: "${order['qty']}x",
                                              d2: "",
                                            ),
                                            orderPlaceDetails(
                                              title1: "Total Produk : ",
                                              title2:
                                                  "Rp ${widget.data['total_amount'].toString().numCurrency}",
                                              d1: "",
                                              d2: "",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  orderPlaceDetails(
                                    d1: widget.data['order_code'],
                                    d2: intl.DateFormat()
                                        .add_yMd()
                                        .add_Hm()
                                        .format(
                                            widget.data['order_date'].toDate()),
                                    title1: "No Pesanan",
                                    title2: "Waktu Booking",
                                  ),
                                  const Divider(),
                                  10.heightBox,
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('vendors')
                                        .doc(widget.data['orders'][index]
                                            ['vendor_id'])
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        dynamic vendorData =
                                            snapshot.data!.data();
                                        GeoPoint vendorLocation =
                                            vendorData['vendor_location'];
                                        double vendorLatitude =
                                            vendorLocation.latitude;
                                        double vendorLongitude =
                                            vendorLocation.longitude;

                                        LatLng vendorLatLng = LatLng(
                                            vendorLatitude, vendorLongitude);

                                        Set<Marker> markers = Set<Marker>.from([
                                          Marker(
                                            markerId: MarkerId('vendorMarker'),
                                            position: vendorLatLng,
                                            infoWindow: InfoWindow(
                                              title: 'Vendor Location',
                                              snippet:
                                                  'Latitude: $vendorLatitude, Longitude: $vendorLongitude',
                                            ),
                                          ),
                                        ]);

                                        LatLng? buyerLatLng;
                                        if (_buyerPosition != null) {
                                          buyerLatLng = LatLng(
                                            _buyerPosition!.latitude,
                                            _buyerPosition!.longitude,
                                          );

                                          double distance = calculateDistance(
                                            vendorLatitude,
                                            vendorLongitude,
                                            buyerLatLng.latitude,
                                            buyerLatLng.longitude,
                                          );

                                          return Column(
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                height: 200,
                                                child: GoogleMap(
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                    target: vendorLatLng,
                                                    zoom: 15,
                                                  ),
                                                  markers: markers,
                                                  myLocationEnabled: true,
                                                  myLocationButtonEnabled:
                                                      false,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Text(
                                                  'Jarak: ${distance.toStringAsFixed(2)} km dari anda',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Text(
                                                  '${vendorData['alamat']}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return SizedBox(
                                            width: double.infinity,
                                            height: 200,
                                            child: GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target: vendorLatLng,
                                                zoom: 15,
                                              ),
                                              markers: markers,
                                              myLocationEnabled: true,
                                              myLocationButtonEnabled: false,
                                            ),
                                          );
                                        }
                                      } else if (snapshot.hasError) {
                                        return const Text(
                                            'Failed to load data');
                                      } else {
                                        return const CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                  10.heightBox,
                                  SizedBox(
                                    width: double
                                        .infinity, // mengambil lebar penuh
                                    height: 50.0,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Color.fromARGB(255, 219, 201,
                                            32), // Warna latar button menjadi putih
                                        onPrimary:
                                            Colors.black, // Warna teks button
                                      ),
                                      onPressed: () {
                                        Get.to(
                                          () => const ChatScreen(),
                                          arguments: [
                                            widget.data['orders'][index]
                                                ['sellername'],
                                            widget.data['orders'][index]
                                                ['vendor_id'],
                                          ],
                                        );
                                      },
                                      child: Text("Hubungi Penjual"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
