import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/screens/profile_screen.dart';
import 'package:terminba_mobile/screens/favorite_sport_centers_screen.dart';
import 'package:terminba_mobile/screens/player_search_requests_screen.dart';
import 'package:terminba_mobile/providers/notification_provider.dart';
import 'package:terminba_mobile/screens/my_posts_screen.dart';
import 'package:terminba_mobile/screens/public_profile_screen.dart';
import 'package:terminba_mobile/screens/my_reviews_screen.dart';
import 'package:terminba_mobile/widgets/confirmation_dialog.dart';

class ProfileMenuScreen extends StatelessWidget {
  final ScrollController? scrollController;

  const ProfileMenuScreen({super.key, this.scrollController});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await ConfirmationDialog.show(
      context,
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log out',
      cancelText: 'Cancel',
    );

    if (shouldLogout) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return SafeArea(
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _listItem(
            context,
            icon: Icons.person_outline,
            title: 'Account',
            color: accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _listItem(
            context,
            icon: Icons.star_outline,
            title: 'Reviews Received',
            color: accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PublicProfileScreen()),
              );
            },
          ),
          _listItem(
            context,
            icon: Icons.rate_review_outlined,
            title: 'Reviews Given',
            color: accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
              );
            },
          ),
          _listItem(
            context,
            icon: Icons.favorite_border,
            title: 'Favorites',
            color: accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteSportCentersScreen(),
                ),
              );
            },
          ),
          _listItem(
            context,
            icon: Icons.article_outlined,
            title: 'My Posts',
            color: accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyPostsScreen()),
              );
            },
          ),
          _listItem(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Requests',
            color: accent,
            trailing: context.watch<NotificationProvider>().unseenCount > 0
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${context.watch<NotificationProvider>().unseenCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlayerSearchRequestsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 36),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => _confirmLogout(context),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
