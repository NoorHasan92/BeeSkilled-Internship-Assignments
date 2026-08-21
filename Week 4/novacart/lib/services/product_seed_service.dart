import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSeedService {
  static final ProductSeedService instance = ProductSeedService._();
  ProductSeedService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedProducts() async {
    final products = [
      // Tech
      {
        'id': 'nova_x1_headphones',
        'name': 'Nova X1 Headphones',
        'description': 'Premium wireless headphones with immersive sound and all-day comfort.',
        'price': 4999,
        'category': 'Tech',
        'rating': 4.8,
        'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&q=80',
        'featured': true,
      },
      {
        'id': 'nova_airpods_pro',
        'name': 'Nova AirPods Pro',
        'description': 'True wireless earbuds with active noise cancellation and adaptive EQ.',
        'price': 18999,
        'category': 'Tech',
        'rating': 4.7,
        'imageUrl': 'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=400&q=80',
        'featured': false,
      },
      {
        'id': 'nova_smart_speaker',
        'name': 'Nova Smart Speaker',
        'description': 'Voice-controlled smart speaker with rich room-filling sound.',
        'price': 3499,
        'category': 'Tech',
        'rating': 4.5,
        'imageUrl': 'https://images.unsplash.com/photo-1543512214-318c7553f230?w=400&q=80',
        'featured': true,
      },
      {
        'id': 'nova_mechanical_keyboard',
        'name': 'Nova Mechanical Keyboard',
        'description': 'RGB mechanical keyboard with tactile switches for satisfying typing.',
        'price': 7999,
        'category': 'Tech',
        'rating': 4.9,
        'imageUrl': 'https://images.unsplash.com/photo-1595225476474-87563907a212?w=400&q=80',
        'featured': false,
      },

      // Fashion
      {
        'id': 'urban_oversized_hoodie',
        'name': 'Urban Oversized Hoodie',
        'description': 'Comfortable and stylish oversized hoodie made from premium cotton blend.',
        'price': 1999,
        'category': 'Fashion',
        'rating': 4.6,
        'imageUrl': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400&q=80',
        'featured': true,
      },
      {
        'id': 'essential_sneakers',
        'name': 'Essential Sneakers',
        'description': 'Versatile everyday sneakers with cushioned soles for maximum comfort.',
        'price': 2499,
        'category': 'Fashion',
        'rating': 4.4,
        'imageUrl': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&q=80',
        'featured': false,
      },
      {
        'id': 'classic_denim_jacket',
        'name': 'Classic Denim Jacket',
        'description': 'Timeless vintage wash denim jacket suitable for any casual outfit.',
        'price': 3299,
        'category': 'Fashion',
        'rating': 4.7,
        'imageUrl': 'https://images.unsplash.com/photo-1495105787522-5334e3ffa0ef?w=400&q=80',
        'featured': true,
      },
      {
        'id': 'minimal_leather_backpack',
        'name': 'Minimal Leather Backpack',
        'description': 'Sleek leather backpack with padded laptop compartment and weather resistance.',
        'price': 4599,
        'category': 'Fashion',
        'rating': 4.8,
        'imageUrl': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&q=80',
        'featured': false,
      },

      // Home
      {
        'id': 'aura_desk_lamp',
        'name': 'Aura Desk Lamp',
        'description': 'Modern minimalist LED desk lamp with adjustable color temperature and brightness.',
        'price': 1499,
        'category': 'Home',
        'rating': 4.5,
        'imageUrl': 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400&q=80',
        'featured': false,
      },
      {
        'id': 'nordic_ceramic_vase',
        'name': 'Nordic Ceramic Vase',
        'description': 'Handcrafted matte ceramic vase with elegant curves for modern interiors.',
        'price': 899,
        'category': 'Home',
        'rating': 4.3,
        'imageUrl': 'https://images.unsplash.com/photo-1581783342308-f792dbdd27c5?w=400&q=80',
        'featured': false,
      },
      {
        'id': 'cloud_soft_cushion',
        'name': 'Cloud Soft Cushion',
        'description': 'Ultra-soft plush decorative cushion for couches and beds.',
        'price': 599,
        'category': 'Home',
        'rating': 4.2,
        'imageUrl': 'https://images.unsplash.com/photo-1574041103099-0091ff73e6a4?w=400&q=80',
        'featured': false,
      },
      {
        'id': 'minimal_wall_clock',
        'name': 'Minimal Wall Clock',
        'description': 'Silent sweep wooden wall clock with a clean, numberless face.',
        'price': 1299,
        'category': 'Home',
        'rating': 4.6,
        'imageUrl': 'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=400&q=80',
        'featured': true,
      },

      // Lifestyle
      {
        'id': 'nova_smart_watch',
        'name': 'Nova Smart Watch',
        'description': 'Advanced fitness tracking, heart rate monitoring, and sleep analysis on your wrist.',
        'price': 5999,
        'category': 'Lifestyle',
        'rating': 4.7,
        'imageUrl': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&q=80',
        'featured': true,
      },
      {
        'id': 'stainless_steel_bottle',
        'name': 'Stainless Steel Bottle',
        'description': 'Vacuum-insulated water bottle that keeps drinks cold for 24 hours.',
        'price': 999,
        'category': 'Lifestyle',
        'rating': 4.8,
        'imageUrl': 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&q=80',
        'featured': false,
      },
      {
        'id': 'everyday_travel_organizer',
        'name': 'Everyday Travel Organizer',
        'description': 'Compact tech and cable organizer pouch for seamless travel.',
        'price': 1199,
        'category': 'Lifestyle',
        'rating': 4.4,
        'imageUrl': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&q=80',
        'featured': false,
      },
    ];

    final batch = _firestore.batch();
    final productsCollection = _firestore.collection('products');

    for (final product in products) {
      final id = product['id'] as String;
      final docRef = productsCollection.doc(id);
      
      // Remove id from the data we write to Firestore
      final data = Map<String, dynamic>.from(product);
      data.remove('id');

      batch.set(docRef, data, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
