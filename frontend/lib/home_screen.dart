import 'package:flutter/material.dart';
import 'shop_screen.dart';
import 'card.dart';
import 'database_service.dart';

class HomeScreen extends StatefulWidget {
  final bool isSelected;
  const HomeScreen({super.key, this.isSelected = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Product>> _productsFuture;
  bool _hasData = false;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If screen becomes selected and we don't have data yet (or have an error), try loading
    if (widget.isSelected &&
        !oldWidget.isSelected &&
        (!_hasData || _hasError)) {
      _loadProducts();
    }
  }

  void _loadProducts() {
    setState(() {
      _hasError = false; // Reset error state
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
    _loadProducts();
    await _productsFuture;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 15)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverToBoxAdapter(child: _buildPromoBanner(theme)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSectionHeader("Categories", context, theme),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryItem(
                            "Burger",
                            Icons.no_food_sharp,
                            const Color(0xFF555555),
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryItem(
                            "Pizza",
                            Icons.local_pizza_sharp,
                            theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryItem(
                            "Hotdog",
                            Icons.hot_tub_sharp,
                            theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryItem(
                            "Drink",
                            Icons.local_drink_sharp,
                            theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader("Products", context, theme),
              ),
            ),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(20.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 250,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.7,
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
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.7,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      childCount: products.length,
                      (context, index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 100)),
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
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(ThemeData theme) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find The Best Food Burger",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: "Poetsen",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Stay connected and track your health with this premium smart watch...",
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontFamily: "Poetsen",
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset("assets/burgerBanner.png", fit: BoxFit.contain),
          ),
        ],
      ),
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
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 32,
              fontFamily: "Poetsen",
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopScreen()),
            );
          },
          child: Text(
            "See all",
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Poetsen",
              color:
                  theme.textTheme.bodySmall?.color?.withOpacity(0.6) ??
                  Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      constraints: const BoxConstraints(minWidth: 100),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24.0),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: "Poetsen",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
