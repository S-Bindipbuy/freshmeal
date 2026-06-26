import 'package:flutter/material.dart';
import 'card.dart';
import 'database_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<List<Product>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = DatabaseService.getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Noted: topbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Text(
                    "Cart",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontFamily: "Poetsen",
                    ),
                  ),
                  const SizedBox(width: 48), // Placeholder for symmetry
                ],
              ),
              const SizedBox(height: 20),
              // Noted : Product Orders
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _ordersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.separated(
                        itemCount: 3,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) =>
                            const OrderCardSkeleton(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No orders found'));
                    }

                    final orders = snapshot.data!;

                    double subtotal = orders.fold(
                      0.0,
                      (sum, item) => sum + (item.price * item.quantity),
                    );
                    double tax = subtotal * 0.1;
                    double total = subtotal + tax;
                    int totalItems = orders.fold(
                      0,
                      (sum, item) => sum + item.quantity,
                    );

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: orders.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              return TweenAnimationBuilder<double>(
                                duration: Duration(
                                  milliseconds: 300 + (index * 100),
                                ),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(50 * (1 - value), 0),
                                      child: child,
                                    ),
                                  );
                                },
                                child: OrderCard(
                                  product: orders[index],
                                  quantity: orders[index].quantity,
                                  onRemove: () {},
                                  onDelete: () {},
                                ),
                              );
                            },
                          ),
                        ),
                        _buildBottomBar(
                          theme,
                          isDark,
                          totalItems,
                          subtotal,
                          tax,
                          total,
                          context,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    ThemeData theme,
    bool isDark,
    int totalItems,
    double subtotal,
    double tax,
    double total,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.grey.shade200,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Product Items",
                style: TextStyle(
                  fontSize: 20,
                  color: theme.textTheme.bodyLarge?.color,
                  fontFamily: "Poetsen",
                ),
              ),
              Text(
                "Items : $totalItems",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tax (10%) : ",
                style: TextStyle(
                  fontSize: 18,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  fontFamily: "Poetsen",
                ),
              ),
              Text(
                '\$${tax.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Poetsen",
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Amount : ",
                style: TextStyle(
                  fontSize: 18,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  fontFamily: "Poetsen",
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Poetsen",
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Order processing..."),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Checkout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: "Poetsen",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
