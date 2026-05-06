import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection('products')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Product>> getFeaturedProductsStream() {
    return _firestore
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<BannerModel>> getBannersStream() {
    return _firestore.collection('banners').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> placeOrder(OrderModel order) async {
    final orderRef = _firestore.collection('orders').doc();
    await _firestore.runTransaction((transaction) async {
      // 1. Create the order
      transaction.set(orderRef, order.toMap());

      // 2. Clear the cart
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(order.userId)
          .collection('cart')
          .get();

      for (var doc in cartSnapshot.docs) {
        transaction.delete(doc.reference);
      }
    });
  }

  Stream<List<OrderModel>> getOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    await _firestore.collection('orders').doc(orderId).update(data);
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }
}
