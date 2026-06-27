import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'database_service.dart';
import 'order_screen.dart';
import 'http_cache_manager.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String heroTag;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.heroTag,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  String selectedSize = "M";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Hero(
              tag: widget.heroTag,
              child: CachedNetworkImage(
                cacheManager: HttpCacheManager.instance,
                imageUrl: widget.product.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          ),

          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.4),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black45 : Colors.black12,
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30.0,
                            vertical: 40.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Price Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.product.title,
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontFamily: "Poetsen",
                                            color: theme
                                                .textTheme
                                                .displayLarge
                                                ?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Special Fresh Meal",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withOpacity(0.6),
                                            fontFamily: "Poetsen",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${widget.product.price}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontFamily: "Poetsen",
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              // Info Row: Rating, Calories, Time
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoItem(
                                    Icons.star,
                                    "4.8",
                                    "Rating",
                                    theme,
                                  ),
                                  _buildInfoItem(
                                    Icons.local_fire_department,
                                    "150 kcal",
                                    "Calories",
                                    theme,
                                  ),
                                  _buildInfoItem(
                                    Icons.access_time_filled,
                                    "20-30 min",
                                    "Delivery",
                                    theme,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // Size Selection
                              const Text(
                                "Select Size",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Poetsen",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: ["S", "M", "L"].map((sizeLabel) {
                                  final isSelected = selectedSize == sizeLabel;
                                  return GestureDetector(
                                    onTap: () => setState(
                                      () => selectedSize = sizeLabel,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 15),
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : theme.dividerColor,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          sizeLabel,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 30),

                              // Quantity Selector
                              const Text(
                                "Quantity",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Poetsen",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  _buildQtyBtn(Icons.remove, () {
                                    if (quantity > 1)
                                      setState(() => quantity--);
                                  }, theme),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      quantity.toString().padLeft(2, '0'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _buildQtyBtn(Icons.add, () {
                                    setState(() => quantity++);
                                  }, theme),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // Description
                              const Text(
                                "About Product",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Poetsen",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                widget.product.description.isEmpty
                                    ? "This premium ${widget.product.title} is prepared with love and the best organic ingredients. Perfectly balanced taste for your healthy lifestyle."
                                    : widget.product.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.7),
                                  height: 1.6,
                                  fontFamily: "Poetsen",
                                ),
                              ),

                              const SizedBox(height: 120), // Bottom padding
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Back Button - Placed last to stay on top
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: Material(
              elevation: 4,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              color: theme.colorScheme.surface,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Cart Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Material(
              elevation: 4,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              color: theme.colorScheme.surface,
              child: IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Total Price
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Price",
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '\$${(widget.product.price * quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              // Add to Cart Button
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await DatabaseService.placeOrder(
                          widget.product.id,
                          quantity,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "$quantity x ${widget.product.title} added to cart!",
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              backgroundColor: theme.colorScheme.primary,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to add to cart: $e"),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text("Add to Cart"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: theme.textTheme.bodyLarge?.color),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String value,
    String label,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
