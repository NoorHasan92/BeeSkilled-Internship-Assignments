import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PublicApiApp());
}

class PublicApiApp extends StatelessWidget {
  const PublicApiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.purple,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: const ProductPage(),
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.thumbnail,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String thumbnail;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Unknown Product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? 'Unknown',
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Uri url = Uri.parse('https://dummyjson.com/products?limit=20');
      final http.Response response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Server returned status code ${response.statusCode}');
      }

      final Map<String, dynamic> jsonData =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> productData = jsonData['products'] as List<dynamic>;

      final List<Product> loadedProducts = productData
          .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();

      if (!mounted) return;

      setState(() {
        _products = loadedProducts;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load products. Please check your connection and try again.';
      });
    }
  }

  void _toggleFavorite(int productId) {
    setState(() {
      if (_favoriteIds.contains(productId)) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });
  }

  List<Product> get _filteredProducts {
    return _products.where((Product p) {
      final bool matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final bool matchesSearch = p.title.toLowerCase().contains(_searchQuery) ||
          p.category.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get _categories {
    final Set<String> cats = _products.map((Product p) => p.category).toSet();
    final List<String> sortedCats = cats.toList()..sort();
    return ['All', ...sortedCats];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Explorer',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
            ),
            Text(
              'Discover products',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchProducts,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.indigo),
            const SizedBox(height: 24),
            Text(
              'Loading products...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.indigo.shade300,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 80, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _fetchProducts,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final List<Product> displayedProducts = _filteredProducts;

    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryChips(),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchProducts,
            color: Colors.indigo,
            child: displayedProducts.isEmpty
                ? _buildEmptyState()
                : _buildProductList(displayedProducts),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by title or category...',
          prefixIcon: const Icon(Icons.search, color: Colors.indigo),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final List<String> categories = _categories;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final String category = categories[index];
          final bool isSelected = _selectedCategory == category;
          return FilterChip(
            label: Text(
              category == 'All' 
                  ? category 
                  : category[0].toUpperCase() + category.substring(1),
            ),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                _selectedCategory = category;
              });
            },
            selectedColor: Colors.indigo.shade100,
            checkmarkColor: Colors.indigo,
            labelStyle: TextStyle(
              color: isSelected ? Colors.indigo.shade900 : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(
              color: isSelected ? Colors.indigo.shade300 : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 80, left: 32, right: 32),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No products found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or selecting a different category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 24),
      itemCount: products.length + 1, // +1 for the footer
      itemBuilder: (BuildContext context, int index) {
        if (index == products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Data provided by DummyJSON',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        }

        final Product product = products[index];
        final bool isFavorite = _favoriteIds.contains(product.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(product),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _toggleFavorite(product.id),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.redAccent : Colors.grey.shade400,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.3,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        product.thumbnail,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: Colors.grey.shade400,
              size: 40,
            ),
          );
        },
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
              strokeWidth: 2,
              color: Colors.indigo.shade200,
            ),
          );
        },
      ),
    );
  }
}
