const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.checkExpiredOrders = functions.pubsub.schedule('every 1 minutes').onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const expiredOrdersQuery = await admin.firestore()
        .collection('orders')
        .where('order_placed', '==', true)
        .where('cancel_time', '<=', now)
        .get();
    
    let batch = admin.firestore().batch();

    expiredOrdersQuery.docs.forEach(doc => {
        const orderData = doc.data();
        // Batalkan pesanan
        batch.update(doc.ref, {'order_placed': false});

        // Mengembalikan stok (Anda bisa menyesuaikan logika ini sesuai dengan kebutuhan Anda)
        orderData.orders.forEach(async (order) => {
            const productRef = admin.firestore().collection('productsCollection').doc(order['product_id']);
            const productDoc = await productRef.get();
            const currentQty = parseInt(productDoc.data().p_quantity);
            const orderQty = parseInt(order.qty);
            batch.update(productRef, {'p_quantity': (currentQty + orderQty).toString()});
        });
    });

    await batch.commit();
    return null;
});
