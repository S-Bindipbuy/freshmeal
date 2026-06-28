import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'cart_service.dart';
import 'database_service.dart';
import 'order_screen.dart';
import 'login_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

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
                  color: theme.colorScheme.surfaceContainerHighest,
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
                      color: theme.shadowColor.withValues(alpha: 0.1),
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontFamily: "Poetsen",
                                        color: theme
                                            .textTheme.displayLarge?.color,
                                      ),
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

                              if (widget.product.description.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "About",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: "Poetsen",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      widget.product.description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                        height: 1.6,
                                        fontFamily: "Poetsen",
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),

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
                                    if (quantity > 1) {
                                      setState(() => quantity--);
                                    }
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

                              const SizedBox(height: 80),
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

          // Floating back button
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

          // Shopping bag button
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
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Price",
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
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
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (DatabaseService.token == null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                        if (DatabaseService.token == null) return;
                      }
                      CartService.instance.addItem(
                        widget.product.id,
                        widget.product.title,
                        widget.product.price,
                        quantity,
                      );
                      if (!context.mounted) return;
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
}
