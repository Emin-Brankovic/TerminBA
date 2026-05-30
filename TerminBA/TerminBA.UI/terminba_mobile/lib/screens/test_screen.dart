import 'package:flutter/material.dart';
import 'package:terminba_mobile/layouts/master_screen_bottom_nav.dart';

class TestScreen extends StatelessWidget {
	final bool showBottomNav;

	const TestScreen({super.key, this.showBottomNav = true});

	@override
	Widget build(BuildContext context) {
		final content = SafeArea(
			child: ListView(
				padding: const EdgeInsets.all(20),
				children: [
					Text(
						'Test Screen',
						style: Theme.of(context).textTheme.displayLarge,
					),
					const SizedBox(height: 12),
					Text(
						'This is placeholder content for the bottom navigation.',
						style: Theme.of(context).textTheme.bodyMedium,
					),
					const SizedBox(height: 20),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Stats',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 8),
									const Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											Text('Active items'),
											Text('12'),
										],
									),
									const SizedBox(height: 6),
									const Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											Text('Pending'),
											Text('4'),
										],
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Card(
						child: ListTile(
							leading: const Icon(Icons.info_outline),
							title: const Text('Status'),
							subtitle: const Text('Everything looks good.'),
							trailing: const Icon(Icons.chevron_right),
						),
					),
				],
			),
		);

		if (!showBottomNav) {
			return content;
		}

		return Scaffold(
			body: content,
			bottomNavigationBar: BottomNavigationBar(
				type: BottomNavigationBarType.fixed,
				showUnselectedLabels: true,
				currentIndex: 0,
				onTap: (index) {
					if (index == 0) return;
					Navigator.push(
						context,
						MaterialPageRoute(
							builder: (_) => MasterScreenBottomNav(initialIndex: index),
						),
					);
				},
				items: const [
					BottomNavigationBarItem(
						icon: Icon(Icons.home_outlined),
						label: 'Home',
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.search),
						label: 'Search',
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.event_available),
						label: 'Bookings',
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.person_outline),
						label: 'Profile',
					),
				],
			),
		);
	}
}
