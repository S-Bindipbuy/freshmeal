import 'package:flutter/material.dart';
import 'cart_service.dart';
import 'database_service.dart';
import 'freshmeal.pb.dart' as $pb;
import 'map_picker_screen.dart';
import 'login_screen.dart';

String _statusLabel($pb.OrderStatus status) {
  switch (status) {
    case $pb.OrderStatus.PENDING:
      return 'Pending';
    case $pb.OrderStatus.PAID:
      return 'Paid';
    case $pb.OrderStatus.CONFIRMED:
      return 'Confirmed';
    case $pb.OrderStatus.PREPARING:
      return 'Preparing';
    case $pb.OrderStatus.DELIVERED:
      return 'Delivered';
    case $pb.OrderStatus.CANCELLED:
      return 'Cancelled';
    default:
      return 'Unknown';
  }
}

Color _statusColor($pb.OrderStatus status) {
  switch (status) {
    case $pb.OrderStatus.PENDING:
      return Colors.orange;
    case $pb.OrderStatus.PAID:
      return Colors.blue;
    case $pb.OrderStatus.CONFIRMED:
      return Colors.teal;
    case $pb.OrderStatus.PREPARING:
      return Colors.purple;
    case $pb.OrderStatus.DELIVERED:
      return Colors.green;
    case $pb.OrderStatus.CANCELLED:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<$pb.OrderHistoryItem> _history = [];
  bool _loading = true;
  String? _error;
  final Map<int, String> _productNames = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadProducts();
    CartService.instance.addListener(_onCartChanged);
    _initBranch();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await DatabaseService.getProducts();
      if (mounted) {
        for (final p in products) {
          _productNames[int.parse(p.id)] = p.title;
        }
      }
    } catch (_) {}
  }

  String _itemName($pb.OrderHistoryItem order, $pb.OrderItem item) {
    if (item.productName.isNotEmpty) return item.productName;
    final name = _productNames[item.productId.toInt()];
    if (name != null) return name;
    return 'Product #${item.productId}';
  }

  String _itemPrice($pb.OrderItem item) {
    final price = double.tryParse(item.priceAtTime);
    if (price != null && price > 0) {
      return '\$${(price * item.quantity.toInt()).toStringAsFixed(2)}';
    }
    return '';
  }

  Future<void> _initBranch() async {
    final cart = CartService.instance;
    if (cart.deliveryLat != null && cart.deliveryLng != null && cart.branchId == null) {
      await cart.fetchNearestBranch(cart.deliveryLat!, cart.deliveryLng!);
    }
  }

  Future<void> _pickLocation() async {
    final cart = CartService.instance;
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: cart.deliveryLat,
          initialLng: cart.deliveryLng,
        ),
      ),
    );
    if (result != null) {
      final lat = result['lat']!;
      final lng = result['lng']!;
      cart.setDeliveryLocation(lat, lng);
      await cart.fetchNearestBranch(lat, lng);
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    CartService.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await DatabaseService.getOrderHistory();
      if (mounted) {
        setState(() {
          _history = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _checkout() async {
    final cart = CartService.instance;
    if (cart.isEmpty) return;

    if (DatabaseService.token == null) {
      final loggedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true) return;
    }

    if (cart.deliveryLat == null || cart.deliveryLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please set a delivery location first"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      await _pickLocation();
      if (cart.deliveryLat == null || cart.deliveryLng == null) return;
    }

    try {
      await cart.checkout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order placed!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {});
        await _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Checkout failed: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = CartService.instance;
    final history = _history.toList();

    if (DatabaseService.token == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("Sign in to order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poetsen")),
                  const SizedBox(height: 8),
                  Text("Create an account or sign in to place orders", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6))),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Navigator.canPop(context)
                      ? Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const SizedBox(width: 48),
                  Text(
                    "Cart",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontFamily: "Poetsen",
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: _loading && _history.isEmpty && cart.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 40),
                            Center(child: CircularProgressIndicator()),
                          ],
                        )
                      : ListView(
                          children: [
                            if (!cart.isEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  "Current Cart",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poetsen",
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: _pickLocation,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        cart.deliveryLat != null ? Icons.location_on : Icons.location_on_outlined,
                                        size: 18,
                                        color: cart.deliveryLat != null ? Colors.red : theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          cart.deliveryLat != null
                                              ? '${cart.deliveryLat!.toStringAsFixed(4)}, ${cart.deliveryLng!.toStringAsFixed(4)}'
                                              : 'Tap to set delivery location',
                                          style: TextStyle(
                                            color: cart.deliveryLat != null
                                                ? theme.colorScheme.primary
                                                : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Poetsen",
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (cart.branchName.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              cart.branchName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right, size: 18, color: theme.textTheme.bodySmall?.color),
                                    ],
                                  ),
                                ),
                              ),
                              _buildCartCard(theme, cart),
                              const SizedBox(height: 24),
                            ],
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Center(
                                  child: Text(
                                    "Error: $_error",
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            if (history.isEmpty && cart.isEmpty && !_loading && _error == null)
                              const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Center(child: Text("No orders yet")),
                              ),
                            if (_loading && history.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                            if (history.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  "Order History",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poetsen",
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              ...history.map(
                                (o) => Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: _buildHistoryCard(o, theme),
                                ),
                              ),
                            ],
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

  Widget _buildCartCard(ThemeData theme, CartService cart) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cart",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poetsen",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: "Poetsen",
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _qtyBtn(Icons.remove, () {
                          CartService.instance.updateQuantity(
                            item.productId,
                            item.quantity - 1,
                          );
                          setState(() {});
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${item.quantity}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _qtyBtn(Icons.add, () {
                          CartService.instance.updateQuantity(
                            item.productId,
                            item.quantity + 1,
                          );
                          setState(() {});
                        }),
                        const SizedBox(width: 12),
                      ],
                    ),
                    Flexible(
                      child: Text(
                        "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontFamily: "Poetsen",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Subtotal: ",
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                Text(
                  "\$${cart.subtotal.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontFamily: "Poetsen",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text("Payment Method", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: "Poetsen")),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _paymentChip(
                    icon: Icons.qr_code,
                    label: "ABA KHQR",
                    selected: cart.paymentMethod == PaymentMethod.abaKhqr,
                    onTap: () => CartService.instance.setPaymentMethod(PaymentMethod.abaKhqr),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _paymentChip(
                    icon: Icons.credit_card,
                    label: "Credit Card",
                    selected: cart.paymentMethod == PaymentMethod.creditCard,
                    onTap: () => CartService.instance.setPaymentMethod(PaymentMethod.creditCard),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        CartService.instance.clear();
                        setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Clear Cart",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poetsen",
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Place Order",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poetsen",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetail($pb.OrderHistoryItem order, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order.id}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Poetsen"),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (order.createdAt.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(order.createdAt, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6))),
            ],
            const Divider(height: 20),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _itemName(order, item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontFamily: "Poetsen"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text("x${item.quantity}", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6))),
                    ),
                    if (_itemPrice(item).isNotEmpty)
                      Flexible(
                        child: Text(
                          _itemPrice(item),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontFamily: "Poetsen"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Poetsen")),
                Text(
                  "\$${order.total}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontFamily: "Poetsen"),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard($pb.OrderHistoryItem order, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showOrderDetail(order, theme),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${order.id}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poetsen",
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(order.status),
                      style: TextStyle(
                        color: _statusColor(order.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              if (order.createdAt.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  order.createdAt,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _itemName(order, item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: "Poetsen",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          "x${item.quantity}",
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      if (_itemPrice(item).isNotEmpty)
                        Flexible(
                          child: Text(
                            _itemPrice(item),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontFamily: "Poetsen",
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Total: ",
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "\$${order.total}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontFamily: "Poetsen",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentChip({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? theme.colorScheme.primary : Colors.grey, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? theme.colorScheme.primary : Colors.grey,
                fontFamily: "Poetsen",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
