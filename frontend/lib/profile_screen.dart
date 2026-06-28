import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/database_service.dart';
import 'package:frontend/login_screen.dart';
import 'package:frontend/dashboard_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    if (DatabaseService.token == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final profile = await DatabaseService.getProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      log("Error loading profile: $e");
      setState(() {
        _isLoading = false;
        _profile = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load profile: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        Uint8List? bytes;
        String filename = result.files.single.name;

        if (result.files.single.bytes != null) {
          bytes = result.files.single.bytes;
        } else if (result.files.single.path != null) {
          final name = File(result.files.single.path!);
          bytes = await name.readAsBytes();
        } else {
          return;
        }

        setState(() => _isLoading = true);
        if (bytes == null) {
          return;
        }

        await DatabaseService.uploadAvatar(bytes, filename);
        await _loadProfile();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile picture updated successfully!"),
            ),
          );
        }
      }
    } catch (e) {
      log("Error uploading image: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to upload avatar: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: DatabaseService.token == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_circle, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("You're not signed in", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poetsen")),
                      const SizedBox(height: 8),
                      Text("Sign in to place orders and track history", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6))),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _isLoading && _profile == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              backgroundImage: _profile?.avatar != null
                                  ? CachedNetworkImageProvider(
                                          _profile!.avatar!,
                                        )
                                        as ImageProvider
                                  : const AssetImage('assets/profile.png'),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: theme.colorScheme.onPrimary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _profile?.name ?? "SuperAdmin",
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: "Poetsen",
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        _profile?.email ?? "superadmin@freshmeal.com",
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Settings Section
                      _buildProfileItem(
                        context,
                        icon: isDark ? Icons.light_mode : Icons.dark_mode,
                        title: isDark
                            ? "Switch to Light Mode"
                            : "Switch to Dark Mode",
                        onTap: () {
                          themeNotifier.value = isDark
                              ? ThemeMode.light
                              : ThemeMode.dark;
                        },
                        iconColor: theme.colorScheme.onSurface,
                        theme: theme,
                      ),
                      _buildProfileItem(
                        context,
                        icon: Icons.person_outline,
                        title: "Edit Profile Picture",
                        onTap: _pickAndUploadImage,
                        theme: theme,
                      ),
                      _buildProfileItem(
                        context,
                        icon: Icons.history,
                        title: "Order History",
                        onTap: () {},
                        theme: theme,
                      ),
                      _buildProfileItem(
                        context,
                        icon: Icons.logout,
                        title: "Logout",
                        onTap: () {
                          DatabaseService.logout();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const DashboardScreen()),
                            (_) => false,
                          );
                        },
                        theme: theme,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
    Color? iconColor,
    bool isLast = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      color: theme.colorScheme.surface,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontFamily: "Poetsen", fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
