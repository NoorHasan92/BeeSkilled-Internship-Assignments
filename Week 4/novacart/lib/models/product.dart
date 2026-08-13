import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.rating,
    required this.imageUrl,
    required this.featured,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final double rating;
  final String imageUrl;
  final bool featured;

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Product(
      id: document.id,
      name: data['name'] as String? ?? 'Unnamed Product',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String? ?? 'Other',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      featured: data['featured'] as bool? ?? false,
    );
  }
}
