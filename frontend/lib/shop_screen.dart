import 'package:flutter/material.dart';
import 'package:frontend/order_screen.dart';
import 'package:frontend/card.dart';
import 'package:frontend/database_service.dart';

class ShopScreen extends StatefulWidget {
  final bool isSelected;
  const ShopScreen({super.key, this.isSelected = false});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
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
  void didUpdateWidget(ShopScreen oldWidget) {
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
    super.build(context);

    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: theme.colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Noted: topbar
                Row(
                  children: [
                    Text(
                      "Shops",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontFamily: "Poetsen",
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.primary),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.shopping_bag_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // Noted: Search
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.secondary),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.search,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.5,
                        ),
                      ),
                      hintText: "Search products...",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Noted: Products
                Expanded(
                  child: FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 250,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: 6,
                          itemBuilder: (context, index) =>
                              const ProductCardSkeleton(),
                        );
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                            ),
                            Center(
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
                          ],
                        );
                      }

                      final products = snapshot.data!;
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: products[index],
                            heroTag: 'shop_product_${products[index].id}',
                          );
                        },
                      );
                    },
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
