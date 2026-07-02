import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'cart_service.dart';
import 'database_service.dart';
import 'product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String? heroTag;

  const ProductCard({super.key, required this.product, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final String effectiveTag = heroTag ?? 'product_${product.id}';
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailScreen(product: product, heroTag: effectiveTag),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: theme.dividerColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  child: Hero(
                    tag: effectiveTag,
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: theme.colorScheme.surfaceContainerHighest,
                        highlightColor: theme.colorScheme.surface,
                        child: Container(color: theme.colorScheme.surface),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surface,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 30,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.textTheme.bodyLarge?.color,
                          fontFamily: "Poetsen",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '\$${product.price}',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                                fontFamily: "Poetsen",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              if (DatabaseService.token == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please log in first to add items"),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              CartService.instance.addItem(
                                product.id,
                                product.title,
                                product.price,
                                1,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${product.title} added to cart!"),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add,
                                color: theme.colorScheme.onPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Expanded(child: Container(color: theme.colorScheme.surface)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 80, color: theme.colorScheme.surface),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 12, width: 40, color: theme.colorScheme.surface),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback? onRemove;
  final VoidCallback? onDelete;

  const OrderCard({
    super.key,
    required this.product,
    this.quantity = 1,
    this.onRemove,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.dividerColor, width: 1),
           boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: theme.dividerColor, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: CachedNetworkImage(
                imageUrl: product.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: theme.colorScheme.surfaceContainerHighest,
                  highlightColor: theme.colorScheme.surface,
                  child: Container(color: theme.colorScheme.surface),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.broken_image, color: theme.colorScheme.outline),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                          fontFamily: "Poetsen",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildCircleButton(Icons.remove, onRemove, theme),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Text(
                              quantity.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildCircleButton(Icons.add, () {}, theme),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '\$${product.price}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poetsen",
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    VoidCallback? onPressed,
    ThemeData theme,
  ) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        color: theme.colorScheme.onPrimary,
        icon: Icon(icon, size: 14),
        onPressed: onPressed,
      ),
    );
  }
}

class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 14, width: 140, color: theme.colorScheme.surface),
                  const SizedBox(height: 12),
                  Container(height: 24, width: 70, color: theme.colorScheme.surface),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
