import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'database_service.dart';
import 'admin_categories_screen.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  int? _filterCategoryId;
  final Set<String> _toggling = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
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
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _search = value;
    _loadData();
  }

  void _onCategoryFilterChanged(int? categoryId) {
    _filterCategoryId = categoryId;
    _loadData();
  }

  Future<void> _toggleAvailability(Product product) async {
    final id = product.id;
    if (_toggling.contains(id)) return;
    _toggling.add(id);
    try {
      final updated = await DatabaseService.toggleProductAvailability(
        int.parse(product.id),
        !product.available,
      );
      if (!mounted) return;
      setState(() {
        final idx = _products.indexWhere((p) => p.id == product.id);
        if (idx != -1) _products[idx] = updated;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle: $e')),
      );
    } finally {
      _toggling.remove(id);
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await DatabaseService.deleteProduct(int.parse(product.id));
      if (!mounted) return;
      setState(() {
        _products.removeWhere((p) => p.id == product.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${product.title}" deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  String _categoryName(int? id) {
    if (id == null) return '';
    return _categories.where((c) => c.id == id).firstOrNull?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Management',
            style: TextStyle(color: theme.colorScheme.primary, fontFamily: 'Poetsen')),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Manage Categories',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCategoriesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _filterCategoryId,
                    isDense: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ..._categories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: _onCategoryFilterChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Refresh button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
          ),
          // Product list
          Expanded(
            child: _buildProductList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(ThemeData theme) {
    if (_loading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (_, _) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildSkeleton(theme),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(_error!),
            TextButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final p = _products[index];
          return _buildProductTile(p, theme);
        },
      ),
    );
  }

  Widget _buildProductTile(Product product, ThemeData theme) {
    final isToggling = _toggling.contains(product.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: product.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: theme.dividerColor),
                        errorWidget: (_, _, _) => Icon(Icons.broken_image, color: theme.disabledColor),
                      )
                    : Container(color: theme.dividerColor, child: const Icon(Icons.fastfood)),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                  if (_categoryName(product.categoryId).isNotEmpty)
                    Text(
                      _categoryName(product.categoryId),
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                    ),
                ],
              ),
            ),
            // Availability toggle
            _buildAvailButton(product, isToggling, theme),
            const SizedBox(width: 6),
            // Delete
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteProduct(product),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailButton(Product product, bool isToggling, ThemeData theme) {
    final avail = product.available;
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: isToggling ? null : () => _toggleAvailability(product),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: avail ? Colors.green : Colors.red.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        child: isToggling
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(avail ? 'Available' : 'Offline'),
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[900]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 14, width: 120, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 60, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
