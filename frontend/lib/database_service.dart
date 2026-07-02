import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fixnum/fixnum.dart' as $fixnum;

import 'freshmeal.pb.dart' as $pb;
import 'freshmeal.pbenum.dart' as $pbenum;

class Product {
  final String id;
  final String title;
  final String image;
  final double price;
  final String description;
  final int quantity;
  final bool available;
  final int? categoryId;

  Product({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.description = "",
    this.quantity = 1,
    this.available = true,
    this.categoryId,
  });

  factory Product.fromProto($pb.Product p, String baseUrl) {
    String imageName = p.image.contains('/')
        ? p.image.split('/').last
        : p.image;
    String normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    String fullImageUrl = "$normalizedBaseUrl/images/$imageName";

    double parsedPrice = 0.0;
    final priceStr = p.price;
    if (priceStr.isNotEmpty) {
      parsedPrice = double.tryParse(priceStr) ?? 0.0;
    }

    return Product(
      id: p.id.toString(),
      title: p.name,
      image: fullImageUrl,
      price: parsedPrice,
      description: p.hasDescription() ? p.description : '',
      quantity: 1,
      available: p.available,
      categoryId: p.hasCategoryId() ? p.categoryId.toInt() : null,
    );
  }
}

class DatabaseService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  static String get _normalizedBaseUrl {
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  static String? _token;
  static http.Client? _client;
  static final authNotifier = ValueNotifier<String?>(null);

  static http.Client get client {
    return _client ??= http.Client();
  }

  static void setClient(http.Client customClient) {
    _client = customClient;
  }

  static String? get token => _token;

  static Map<String, String> _headers({bool isProto = false}) {
    final headers = <String, String>{
      if (isProto) 'Content-Type': 'application/x-protobuf',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<List<Product>> getProducts({
    String? search,
    int? categoryId,
  }) async {
    try {
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (categoryId != null) params['category_id'] = categoryId.toString();
      final uri = Uri.parse(
        '$_normalizedBaseUrl/products',
      ).replace(queryParameters: params.isNotEmpty ? params : null);
      final response = await client
          .get(uri, headers: _headers())
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final productList = $pb.ProductList.fromBuffer(
          response.bodyBytes.toList(),
        );
        return productList.products
            .map((p) => Product.fromProto(p, _normalizedBaseUrl))
            .toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching products: $e");
      rethrow;
    }
  }

  static Future<void> deleteProduct(int id) async {
    try {
      final response = await client
          .delete(
            Uri.parse('$_normalizedBaseUrl/products/$id'),
            headers: _headers(isProto: true),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error deleting product: $e");
      rethrow;
    }
  }

  static Future<Product> toggleProductAvailability(
    int id,
    bool available,
  ) async {
    try {
      final req = $pb.Product(available: available);
      final response = await client
          .patch(
            Uri.parse('$_normalizedBaseUrl/products/$id/availability'),
            headers: _headers(isProto: true),
            body: req.writeToBuffer(),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return Product.fromProto(
          $pb.Product.fromBuffer(response.bodyBytes.toList()),
          _normalizedBaseUrl,
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error toggling availability: $e");
      rethrow;
    }
  }

  static Future<List<Category>> getCategories({String? search}) async {
    try {
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      final uri = Uri.parse(
        '$_normalizedBaseUrl/categories',
      ).replace(queryParameters: params.isNotEmpty ? params : null);
      final response = await client
          .get(uri, headers: _headers(isProto: true))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final categoryList = $pb.CategoryList.fromBuffer(
          response.bodyBytes.toList(),
        );
        return categoryList.categories
            .map((c) => Category.fromProto(c))
            .toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching categories: $e");
      rethrow;
    }
  }

  static Future<Category> createCategory(
    String name,
    String? description,
  ) async {
    try {
      final cat = $pb.Category(name: name);
      if (description != null && description.isNotEmpty) {
        cat.description = description;
      }
      final response = await client
          .post(
            Uri.parse('$_normalizedBaseUrl/categories'),
            headers: _headers(isProto: true),
            body: cat.writeToBuffer(),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Category.fromProto(
          $pb.Category.fromBuffer(response.bodyBytes.toList()),
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error creating category: $e");
      rethrow;
    }
  }

  static Future<Category> updateCategory(
    int id,
    String name,
    String? description,
  ) async {
    try {
      final cat = $pb.Category(name: name);
      if (description != null && description.isNotEmpty) {
        cat.description = description;
      }
      final response = await client
          .put(
            Uri.parse('$_normalizedBaseUrl/categories/$id'),
            headers: _headers(isProto: true),
            body: cat.writeToBuffer(),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return Category.fromProto(
          $pb.Category.fromBuffer(response.bodyBytes.toList()),
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error updating category: $e");
      rethrow;
    }
  }

  static Future<void> deleteCategory(int id) async {
    try {
      final response = await client
          .delete(
            Uri.parse('$_normalizedBaseUrl/categories/$id'),
            headers: _headers(isProto: true),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error deleting category: $e");
      rethrow;
    }
  }

  static Future<List<$pb.OrderHistoryItem>> getOrderHistory() async {
    try {
      final response = await client
          .get(
            Uri.parse('$_normalizedBaseUrl/orders'),
            headers: _headers(isProto: true),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final historyList = $pb.OrderHistoryList.fromBuffer(
          response.bodyBytes.toList(),
        );
        return historyList.orders.toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching orders: $e");
      rethrow;
    }
  }

  static Future<void> placeOrder(String productId, int quantity) async {
    try {
      final reqList = $pb.OrderRequestList(
        requests: [
          $pb.OrderRequest(
            productId: $fixnum.Int64(int.parse(productId)),
            quantity: quantity,
          ),
        ],
      );
      final response = await client
          .post(
            Uri.parse('$_normalizedBaseUrl/orders'),
            headers: _headers(isProto: true),
            body: reqList.writeToBuffer(),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      log("Error placing order: $e");
      rethrow;
    }
  }

  static Future<void> cancelOrder(int orderId) async {
    try {
      final response = await client
          .post(
            Uri.parse('$_normalizedBaseUrl/orders/$orderId/cancel'),
            headers: _headers(isProto: true),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      log("Error cancelling order: $e");
      rethrow;
    }
  }

  static Future<void> checkoutOrder(int orderId) async {
    try {
      final response = await client
          .post(
            Uri.parse('$_normalizedBaseUrl/orders/$orderId/checkout'),
            headers: _headers(isProto: true),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      log("Error checking out: $e");
      rethrow;
    }
  }

  static Future<void> updateCartItemQuantity(
    int orderId,
    int productId,
    int quantity,
  ) async {
    try {
      final response = await client
          .patch(
            Uri.parse('$_normalizedBaseUrl/orders/$orderId/items/$productId'),
            headers: _headers(isProto: false),
            body: '{"quantity":$quantity}',
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      log("Error updating cart item: $e");
      rethrow;
    }
  }

  static Future<List<Branch>> getBranches() async {
    try {
      final response = await client
          .get(
            Uri.parse('$_normalizedBaseUrl/branches'),
            headers: _headers(isProto: true),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final branchList = $pb.BranchList.fromBuffer(
          response.bodyBytes.toList(),
        );
        return branchList.branches.map((b) => Branch.fromProto(b)).toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching branches: $e");
      rethrow;
    }
  }

  static Future<Branch> getNearestBranch(double lat, double lng) async {
    try {
      final uri = Uri.parse('$_normalizedBaseUrl/branches/nearest').replace(
        queryParameters: {'lat': lat.toString(), 'lng': lng.toString()},
      );
      final response = await client
          .get(uri, headers: _headers(isProto: true))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return Branch.fromProto(
          $pb.Branch.fromBuffer(response.bodyBytes.toList()),
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching nearest branch: $e");
      rethrow;
    }
  }

  static Future<int> batchPlaceOrder(
    List<Map<String, dynamic>> items, {
    int? branchId,
    double? deliveryLat,
    double? deliveryLng,
  }) async {
    try {
      final reqList = $pb.OrderRequestList(
        requests: items
            .map(
              (item) => $pb.OrderRequest(
                productId: $fixnum.Int64(item["product_id"] as int),
                quantity: item["quantity"] as int,
              ),
            )
            .toList(),
      );
      if (branchId != null) {
        reqList.branchId = $fixnum.Int64(branchId);
      }
      if (deliveryLat != null) {
        reqList.deliveryLat = deliveryLat;
      }
      if (deliveryLng != null) {
        reqList.deliveryLng = deliveryLng;
      }
      final response = await client
          .post(
            Uri.parse('$_normalizedBaseUrl/orders'),
            headers: _headers(isProto: true),
            body: reqList.writeToBuffer(),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }

      final created = $pb.CreateOrderResponse.fromBuffer(
        response.bodyBytes.toList(),
      );
      return created.id.toInt();
    } catch (e) {
      log("Error placing order: $e");
      rethrow;
    }
  }

  static Future<void> login(String email, String password) async {
    try {
      final req = $pb.LoginRequest(email: email, password: password);
      final response = await client
          .post(
            Uri.parse('$_normalizedBaseUrl/login'),
            headers: _headers(isProto: true),
            body: req.writeToBuffer(),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final loginResp = $pb.LoginResponse.fromBuffer(
          response.bodyBytes.toList(),
        );
        _token = loginResp.token;
        authNotifier.value = _token;
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      log("Error logging in: $e");
      rethrow;
    }
  }

  static Future<void> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final req = $pb.RegisterRequest(
        email: email,
        name: username,
        password: password,
      );
      final response = await client
          .post(
            Uri.parse('$_normalizedBaseUrl/register'),
            headers: _headers(isProto: true),
            body: req.writeToBuffer(),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResp = $pb.LoginResponse.fromBuffer(
          response.bodyBytes.toList(),
        );
        _token = loginResp.token;
        authNotifier.value = _token;
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      log("Error registering: $e");
      rethrow;
    }
  }

  static void logout() {
    _token = null;
    authNotifier.value = null;
  }

  static Future<UserProfile> getProfile() async {
    try {
      final response = await client
          .get(
            Uri.parse('$_normalizedBaseUrl/profile'),
            headers: _headers(isProto: true),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final profile = $pb.ProfileResponse.fromBuffer(
          response.bodyBytes.toList(),
        );
        return UserProfile.fromProto(profile, _normalizedBaseUrl);
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      log("Error fetching profile: $e");
      rethrow;
    }
  }

  static Future<String> uploadAvatar(Uint8List s, String filename) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_normalizedBaseUrl/profile/avatar'),
      );
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.files.add(
        http.MultipartFile.fromBytes('image', s, filename: filename),
      );

      final streamedResponse = await client
          .send(request)
          .timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final avatarResp = $pb.AvatarResponse.fromBuffer(
          response.bodyBytes.toList(),
        );
        return avatarResp.avatar;
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      log("Error uploading avatar: $e");
      rethrow;
    }
  }
}

class Branch {
  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory Branch.fromProto($pb.Branch b) {
    return Branch(
      id: b.id.toInt(),
      name: b.name,
      address: b.address,
      lat: b.lat,
      lng: b.lng,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? description;
  final String createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Category.fromProto($pb.Category c) {
    return Category(
      id: c.id.toInt(),
      name: c.name,
      description: c.hasDescription() && c.description.isNotEmpty
          ? c.description
          : null,
      createdAt: c.createdAt,
    );
  }
}

class UserProfile {
  final int id;
  final String email;
  final String name;
  final String role;
  final String? avatar;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatar,
  });

  factory UserProfile.fromProto($pb.ProfileResponse p, String baseUrl) {
    String? avatarUrl;
    final rawAvatar = p.avatar;
    if (rawAvatar.isNotEmpty) {
      String imageName = rawAvatar.contains('/')
          ? rawAvatar.split('/').last
          : rawAvatar;
      if (!imageName.contains('.')) {
        imageName = '$imageName.jpg';
      }
      String normalizedBaseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      avatarUrl = "$normalizedBaseUrl/images/$imageName";
    }

    final roleEnum = p.role;
    String roleStr;
    if (roleEnum == $pbenum.Role.ADMIN) {
      roleStr = 'admin';
    } else if (roleEnum == $pbenum.Role.RESTAURANT) {
      roleStr = 'restaurant';
    } else {
      roleStr = 'customer';
    }

    return UserProfile(
      id: p.id.toInt(),
      email: p.email,
      name: p.name,
      role: roleStr,
      avatar: avatarUrl,
    );
  }
}
