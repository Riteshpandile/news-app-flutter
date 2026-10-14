import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newsapp/Core/const/app_colors.dart';
import 'package:newsapp/Core/routers/app_router.dart';
import 'package:newsapp/Features/Auth/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = Hive.box('settings').get('email', defaultValue: '');

    final currentLocation = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'News Intelligence',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 1),

            const SizedBox(height: 16),

            // Latest News
            _DrawerItem(
              icon: Icons.newspaper_outlined,
              title: 'Latest News',
              selected: currentLocation == AppNavigation.news,
              onTap: () {
                Navigator.pop(context);
                context.go(AppNavigation.news);
              },
            ),

            // Favorites
            _DrawerItem(
              icon: Icons.bookmark_border_rounded,
              title: 'Favorites',
              selected: currentLocation == AppNavigation.favorites,
              onTap: () {
                Navigator.pop(context);
                context.go(AppNavigation.favorites);
              },
            ),

            const Spacer(),

            const Divider(color: AppColors.border, height: 1),

            // Logout at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: _DrawerItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                iconColor: Colors.red.shade700,
                titleColor: Colors.red.shade700,
                onTap: () async {
                  Navigator.pop(context);

                  await ref.read(authProvider.notifier).logout();

                  if (!context.mounted) return;

                  context.go(AppNavigation.login);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool selected;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        onTap: onTap,
        selected: selected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selectedTileColor: AppColors.primary.withValues(alpha: 0.10),
        leading: Icon(
          icon,
          color:
              iconColor ??
              (selected ? AppColors.primary : AppColors.secondaryText),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color:
                titleColor ?? (selected ? AppColors.primary : AppColors.text),
          ),
        ),
      ),
    );
  }
}
