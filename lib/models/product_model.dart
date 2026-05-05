import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String image;
  final String image1;
  final String title;
  final String description;
  final String price;
  final bool isFeatured;

  Product({
    required this.id,
    required this.image,
    required this.image1,
    required this.title,
    required this.description,
    required this.price,
    this.isFeatured = false,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return Product(
        id: doc.id,
        image: '',
        image1: '',
        title: 'Unknown Product',
        description: '',
        price: '0',
        isFeatured: false,
      );
    }
    return Product(
      id: doc.id,
      image: data['image'] ?? '',
      image1: data['image1'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: data['price']?.toString() ?? '0',
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}
