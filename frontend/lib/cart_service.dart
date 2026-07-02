import 'package:flutter/foundation.dart';
import 'database_service.dart';

class CartItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
  });
}

enum PaymentMethod { abaKhqr, creditCard }

class CartService extends ChangeNotifier {
  CartService._();
  static final _instance = CartService._();
  static CartService get instance => _instance;

  final List<CartItem> _items = [];
  int? _branchId;
  String _branchName = '';
  bool _branchLoading = true;
  double? _deliveryLat;
  double? _deliveryLng;
  PaymentMethod _paymentMethod = PaymentMethod.abaKhqr;

  List<CartItem> get items => List.unmodifiable(_items);

  double get subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.price * i.quantity);

  int? get branchId => _branchId;
  String get branchName => _branchName;
  bool get branchLoading => _branchLoading;
  double? get deliveryLat => _deliveryLat;
  double? get deliveryLng => _deliveryLng;
  PaymentMethod get paymentMethod => _paymentMethod;

  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);

  bool get isEmpty => _items.isEmpty;

  bool get isLoggedIn => DatabaseService.token != null;

  void addItem(String productId, String productName, double price, int quantity) {
    final existing = _items.where((i) => i.productId == productId).firstOrNull;
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items.add(CartItem(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final existing = _items.where((i) => i.productId == productId).firstOrNull;
    if (existing == null) return;
    if (quantity <= 0) {
      _items.remove(existing);
    } else {
      existing.quantity = quantity;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _branchId = null;
    _branchName = '';
    _deliveryLat = null;
    _deliveryLng = null;
    _paymentMethod = PaymentMethod.abaKhqr;
    notifyListeners();
  }

  void setDeliveryLocation(double lat, double lng) {
    _deliveryLat = lat;
    _deliveryLng = lng;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setBranch(int id, String name) {
    _branchId = id;
    _branchName = name;
    _branchLoading = false;
    notifyListeners();
  }

  Future<void> fetchNearestBranch(double lat, double lng) async {
    _branchLoading = true;
    notifyListeners();
    try {
      final branch = await DatabaseService.getNearestBranch(lat, lng);
      _branchId = branch.id;
      _branchName = branch.name;
    } catch (_) {
      _branchId = null;
      _branchName = '';
    }
    _branchLoading = false;
    notifyListeners();
  }

  Future<void> checkout() async {
    if (_items.isEmpty) return;

    final reqList = <Map<String, dynamic>>[];
    for (final item in _items) {
      reqList.add({
        "product_id": int.parse(item.productId),
        "quantity": item.quantity,
      });
    }

    await DatabaseService.batchPlaceOrder(reqList, branchId: _branchId);
    _items.clear();
    _branchId = null;
    _branchName = '';
    _deliveryLat = null;
    _deliveryLng = null;
    notifyListeners();
  }
}
