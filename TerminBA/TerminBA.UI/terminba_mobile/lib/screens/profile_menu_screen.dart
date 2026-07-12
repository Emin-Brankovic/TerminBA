import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/screens/profile_screen.dart';
import 'package:terminba_mobile/screens/favorite_sport_centers_screen.dart';
import 'package:terminba_mobile/screens/player_search_requests_screen.dart';
import 'package:terminba_mobile/providers/notification_provider.dart';
import 'package:terminba_mobile/screens/my_posts_screen.dart';
import 'package:terminba_mobile/screens/public_profile_screen.dart';

class ProfileMenuScreen extends StatelessWidget {
	final ScrollController? scrollController;

	const ProfileMenuScreen({super.key, this.scrollController});

	Future<void> _confirmLogout(BuildContext context) async {
		final shouldLogout = await showDialog<bool>(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Log out'),
				content: const Text('Are you sure you want to log out?'),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context, false),
						child: const Text('Cancel'),
					),
					TextButton(
						onPressed: () => Navigator.pop(context, true),
						child: const Text('Log out'),
					),
				],
			),
		);

		if (shouldLogout ?? false) {
			await context.read<AuthProvider>().logout();
		}
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final accent = theme.colorScheme.primary;
		//final muted = theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600);

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
								MaterialPageRoute(
									builder: (_) => const ProfileScreen(),
								),
							);
						},
					),
					_listItem(
						context,
						icon: Icons.star_outline,
						title: 'Reviews',
						color: accent,
						onTap: () {
							Navigator.push(
								context,
								MaterialPageRoute(
									builder: (_) => const PublicProfileScreen(),
								),
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
								MaterialPageRoute(
									builder: (_) => const MyPostsScreen(),
								),
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
							) : null,
						onTap: () {
							Navigator.push(
								context,
								MaterialPageRoute(
									builder: (_) => const PlayerSearchRequestsScreen(),
								),
							);
						},
					),

					// _listItem(
					// 	context,
					// 	icon: Icons.lock_outline,
					// 	title: 'Privacy and Safety',
					// 	color: accent,
					// ),
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

