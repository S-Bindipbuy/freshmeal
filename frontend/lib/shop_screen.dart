import 'package:flutter/material.dart';
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
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _hasData = false;
  bool _hasError = false;
  String _search = '';
  int? _filterCategoryId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(ShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected &&
        !oldWidget.isSelected &&
        (!_hasData || _hasError)) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _hasError = false;
    });
    try {
      final results = await Future.wait([
        DatabaseService.getProducts(
          search: _search.isNotEmpty ? _search : null,
          categoryId: _filterCategoryId,
        ),
        DatabaseService.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0] as List<Product>;
        _categories = results[1] as List<Category>;
        _hasData = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _onSearchChanged(String value) {
    _search = value;
    _loadData();
  }

  void _onCategoryFilterChanged(int? categoryId) {
    _filterCategoryId = categoryId;
    _loadData();
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
                  ],
                ),
                const SizedBox(height: 16),
                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    prefixIcon: Icon(Icons.search, size: 20,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: theme.colorScheme.secondary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 10),
                // Category filter chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All', null, theme),
                      ..._categories.map((c) => _buildFilterChip(c.name, c.id, theme)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Products
                Expanded(
                  child: _buildProductGrid(theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int? categoryId, ThemeData theme) {
    final selected = _filterCategoryId == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 13, color: selected ? theme.colorScheme.onPrimary : null)),
        selected: selected,
        onSelected: (_) => _onCategoryFilterChanged(categoryId),
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(color: selected ? Colors.transparent : theme.dividerColor.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildProductGrid(ThemeData theme) {
    if (!_hasData && !_hasError) {
      // initial loading
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.7,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      );
    }

    if (_hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 50, color: theme.colorScheme.primary),
                const SizedBox(height: 10),
                const Text('Failed to load products'),
                TextButton(
                  onPressed: _loadData,
                  child: Text('Tap to Retry', style: TextStyle(color: theme.colorScheme.primary)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          const Center(child: Text('No products found')),
        ],
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.7,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: _products[index],
          heroTag: 'shop_product_${_products[index].id}',
        );
      },
    );
  }
}
