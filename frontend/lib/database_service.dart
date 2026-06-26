import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart' as rhttp;

class Product {
  final String id;
  final String title;
  final String image;
  final double price;
  final String description;
  final int quantity;

  Product({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.description = "",
    this.quantity = 1,
  });

  factory Product.fromJson(Map<String, dynamic> json, String baseUrl) {
    double parsePrice(dynamic p) {
      if (p == null) return 0.0;
      if (p is num) return p.toDouble();
      if (p is String) return double.tryParse(p) ?? 0.0;
      return 0.0;
    }

    String title = json['name'] ?? 'No Title';
    String description = json['description'] ?? '';
    String rawImage = json['image'] ?? '';
    String imageName = rawImage.contains('/')
        ? rawImage.split('/').last
        : rawImage;

    String normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    String fullImageUrl = "$normalizedBaseUrl/images/$imageName";

    List<Color> parsedColors = [];
    if (json['colors'] != null && json['colors'] is List) {
      for (var c in json['colors']) {
        try {
          String hex = c.toString().replaceAll('#', '');
          if (hex.length == 6) hex = 'FF$hex';
          parsedColors.add(Color(int.parse(hex, radix: 16)));
        } catch (_) {}
      }
    } else {
      parsedColors = [
        const Color(0xFFF79926),
        const Color(0xFF555555),
        const Color(0xFFFFA12E),
        const Color(0xFFE74C3C),
      ];
    }

    return Product(
      id: json['id']?.toString() ?? '',
      title: title,
      image: fullImageUrl,
      price: parsePrice(json['price']),
      description: description,
      quantity: json['quantity'] ?? 1,
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
  static rhttp.RhttpClient? _client;

  static rhttp.RhttpClient get client {
    return _client ??= rhttp.RhttpClient.createSync(
      settings: const rhttp.ClientSettings(throwOnStatusCode: false),
    );
  }

  static void setClient(rhttp.RhttpClient customClient) {
    _client = customClient;
  }

  static Future<List<Product>> getProducts() async {
    try {
      final response = await client
          .get('$_normalizedBaseUrl/products')
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => Product.fromJson(json, _normalizedBaseUrl))
            .toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching products: $e");
      rethrow;
    }
  }

  static Future<List<Product>> getOrders() async {
    try {
      final response = await client
          .get(
            '$_normalizedBaseUrl/orders',
            headers: _token != null
                ? rhttp.HttpHeaders.rawMap({'Authorization': 'Bearer $_token'})
                : null,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => Product.fromJson(json, _normalizedBaseUrl))
            .toList();
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
      final response = await client
          .post(
            '$_normalizedBaseUrl/orders',
            headers: rhttp.HttpHeaders.rawMap({
              'Content-Type': 'application/json',
              if (_token != null) 'Authorization': 'Bearer $_token',
            }),
            body: rhttp.HttpBody.json({
              'product_id': productId,
              'quantity': quantity,
            }),
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

  static Future<void> login(String email, String password) async {
    try {
      final response = await client
          .post(
            '$_normalizedBaseUrl/login',
            headers: rhttp.HttpHeaders.rawMap({
              'Content-Type': 'application/json',
            }),
            body: rhttp.HttpBody.json({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
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
      final response = await client
          .post(
            '$_normalizedBaseUrl/register',
            headers: rhttp.HttpHeaders.rawMap({
              'Content-Type': 'application/json',
            }),
            body: rhttp.HttpBody.json({
              'name': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      log("Error registering: $e");
      rethrow;
    }
  }

  static Future<UserProfile> getProfile() async {
    try {
      final response = await client
          .get(
            '$_normalizedBaseUrl/profile',
            headers: _token != null
                ? rhttp.HttpHeaders.rawMap({'Authorization': 'Bearer $_token'})
                : null,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data, _normalizedBaseUrl);
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
      final request = await client.post(
        '$_normalizedBaseUrl/profile/avatar',
        headers: rhttp.HttpHeaders.rawMap({'Authorization': 'Bearer $_token'}),
        body: rhttp.HttpBody.multipart({
          'avatar': rhttp.MultipartItem.bytes(bytes: s, fileName: filename),
        }),
      );

      final response = request.body;
      if (request.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response);
        return data['avatar'] ?? '';
      } else {
        throw Exception('Server returned ${request.statusCode}: $response');
      }
    } catch (e) {
      log("Error uploading avatar: $e");
      rethrow;
    }
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

  factory UserProfile.fromJson(Map<String, dynamic> json, String baseUrl) {
    String? rawAvatar = json['avatar'];
    String? avatarUrl;
    if (rawAvatar != null && rawAvatar.isNotEmpty) {
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

    return UserProfile(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      avatar: avatarUrl,
    );
  }
}
