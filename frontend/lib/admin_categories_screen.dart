import 'package:flutter/material.dart';
import 'database_service.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  List<Category> _categories = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  // Add form
  final _addNameCtl = TextEditingController();
  final _addDescCtl = TextEditingController();
  bool _addSubmitting = false;

  // Edit state
  int? _editingId;
  late TextEditingController _editNameCtl;
  late TextEditingController _editDescCtl;
  bool _editSubmitting = false;

  @override
  void initState() {
    super.initState();
    _editNameCtl = TextEditingController();
    _editDescCtl = TextEditingController();
    _loadCategories();
  }

  @override
  void dispose() {
    _addNameCtl.dispose();
    _addDescCtl.dispose();
    _editNameCtl.dispose();
    _editDescCtl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _categories = await DatabaseService.getCategories(
        search: _search.isNotEmpty ? _search : null,
      );
      if (!mounted) return;
      setState(() => _loading = false);
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
    _loadCategories();
  }

  Future<void> _handleAdd() async {
    final name = _addNameCtl.text.trim();
    if (name.isEmpty) return;
    setState(() => _addSubmitting = true);
    try {
      final created = await DatabaseService.createCategory(name, _addDescCtl.text.trim());
      if (!mounted) return;
      setState(() {
        _categories.add(created);
        _addNameCtl.clear();
        _addDescCtl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category created')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _addSubmitting = false);
    }
  }

  void _startEdit(Category c) {
    setState(() {
      _editingId = c.id;
      _editNameCtl.text = c.name;
      _editDescCtl.text = c.description ?? '';
    });
  }

  void _cancelEdit() {
    setState(() => _editingId = null);
  }

  Future<void> _handleEdit() async {
    final name = _editNameCtl.text.trim();
    if (_editingId == null || name.isEmpty) return;
    setState(() => _editSubmitting = true);
    try {
      final updated = await DatabaseService.updateCategory(
        _editingId!,
        name,
        _editDescCtl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        final idx = _categories.indexWhere((c) => c.id == _editingId);
        if (idx != -1) _categories[idx] = updated;
        _editingId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _editSubmitting = false);
    }
  }

  Future<void> _handleDelete(Category c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${c.name}"? Products will lose this category.'),
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
      await DatabaseService.deleteCategory(c.id);
      if (!mounted) return;
      setState(() => _categories.removeWhere((x) => x.id == c.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${c.name}" deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories',
            style: TextStyle(color: theme.colorScheme.primary, fontFamily: 'Poetsen')),
      ),
      body: Column(
        children: [
          // Add form
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New Category',
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 10),
                TextField(
                  controller: _addNameCtl,
                  decoration: InputDecoration(
                    hintText: 'Category name',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addDescCtl,
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addSubmitting ? null : _handleAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _addSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Add Category'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildList(theme)),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(_error!),
            TextButton(onPressed: _loadCategories, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_categories.isEmpty) {
      return const Center(child: Text('No categories'));
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final c = _categories[index];
          if (_editingId == c.id) {
            return _buildEditTile(c, theme);
          }
          return _buildCategoryTile(c, theme);
        },
      ),
    );
  }

  Widget _buildCategoryTile(Category c, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (c.description != null && c.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(c.description!, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _startEdit(c),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _handleDelete(c),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTile(Category c, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _editNameCtl,
              decoration: InputDecoration(
                labelText: 'Name',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _editDescCtl,
              decoration: InputDecoration(
                labelText: 'Description',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: _cancelEdit, child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _editSubmitting ? null : _handleEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _editSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
