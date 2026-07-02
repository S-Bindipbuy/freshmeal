import 'package:flutter/material.dart';
import 'shop_screen.dart';
import 'card.dart';
import 'database_service.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isSelected;
  final VoidCallback? onNavigateToShop;
  final VoidCallback? onNavigateToProfile;
  const HomeScreen({super.key, this.isSelected = false, this.onNavigateToShop, this.onNavigateToProfile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Product>> _productsFuture;
  late Future<List<Category>> _categoriesFuture;
  bool _hasData = false;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected &&
        !oldWidget.isSelected &&
        (!_hasData || _hasError)) {
      _loadData();
    }
  }

  void _loadData() {
    setState(() {
      _hasError = false;
      _categoriesFuture = DatabaseService.getCategories();
      _productsFuture = DatabaseService.getProducts()
          .then((data) {
            if (data.isNotEmpty) {
              _hasData = true;
            } else {
              _hasData = false;
            }
            return data;
          })
          .catchError((e) {
            _hasData = false;
            _hasError = true;
            throw e;
          });
    });
  }

  void _loadProducts() {
    setState(() {
      _hasError = false;
      _productsFuture = DatabaseService.getProducts()
          .then((data) {
            if (data.isNotEmpty) {
              _hasData = true;
            } else {
              _hasData = false;
            }
            return data;
          })
          .catchError((e) {
            _hasData = false;
            _hasError = true;
            throw e;
          });
    });
  }

  Future<void> _handleRefresh() async {
    _loadData();
    await _productsFuture;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + 10)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverToBoxAdapter(
                child: _buildHeader(theme),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverToBoxAdapter(child: _buildPromoBanner(theme)),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildCategoriesHeader(context, theme),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 90,
                      child: FutureBuilder<List<Category>>(
                        future: _categoriesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children: snapshot.data!
                                  .map((c) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: _buildCategoryItem(
                                          c.name,
                                          _categoryIcon(c.name),
                                          theme,
                                        ),
                                      ))
                                  .toList(),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader("Products", context, theme),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.65,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        childCount: 4,
                        (context, index) => const ProductCardSkeleton(),
                      ),
                    ),
                  );
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 50,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            snapshot.hasError
                                ? 'Failed to load products'
                                : 'No products found',
                          ),
                          TextButton(
                            onPressed: _loadProducts,
                            child: Text(
                              'Tap to Retry',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = snapshot.data!;
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      childCount: products.length,
                      (context, index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 80)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: ProductCard(
                            product: products[index],
                            heroTag: 'home_product_${products[index].id}',
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Deliver to",
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                fontFamily: "Poetsen",
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                    fontFamily: "Poetsen",
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: widget.onNavigateToProfile ?? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person_outline, color: theme.colorScheme.primary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.85),
            theme.colorScheme.primary.withValues(alpha: 0.6),
            theme.colorScheme.primary.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Transform.rotate(
                angle: 0.1,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(Icons.restaurant, size: 160, color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "WELCOME",
                            style: TextStyle(
                              fontSize: 9,
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Find The Best\nFood Near You",
                          style: TextStyle(
                            fontSize: 22,
                            color: theme.colorScheme.onPrimary,
                            fontFamily: "Poetsen",
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_offer, size: 12, color: theme.colorScheme.onPrimary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  "Get 20% OFF",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Poetsen",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      "assets/burgerBanner.png",
                      fit: BoxFit.contain,
                      height: 130,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Categories",
          style: TextStyle(
            fontSize: 22,
            fontFamily: "Poetsen",
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        GestureDetector(
          onTap: widget.onNavigateToShop ?? () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "See all",
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: "Poetsen",
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 10, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    BuildContext context,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontFamily: "Poetsen",
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        GestureDetector(
          onTap: widget.onNavigateToShop ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "See all",
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: "Poetsen",
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 10, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, ThemeData theme) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
              fontFamily: "Poetsen",
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('burger') || lower.contains('sandwich')) {
      return Icons.lunch_dining;
    } else if (lower.contains('pizza')) {
      return Icons.local_pizza;
    } else if (lower.contains('drink') || lower.contains('beverage')) {
      return Icons.local_drink;
    } else if (lower.contains('hotdog') || lower.contains('hot dog')) {
      return Icons.hot_tub;
    } else if (lower.contains('dessert') || lower.contains('sweet')) {
      return Icons.cake;
    } else if (lower.contains('soup')) {
      return Icons.soup_kitchen;
    } else if (lower.contains('salad')) {
      return Icons.eco;
    } else if (lower.contains('rice') || lower.contains('noodle')) {
      return Icons.ramen_dining;
    } else {
      return Icons.restaurant;
    }
  }
}
