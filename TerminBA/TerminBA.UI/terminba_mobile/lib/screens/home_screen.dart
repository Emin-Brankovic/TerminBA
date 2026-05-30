import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
	final ScrollController? scrollController;

	const HomeScreen({super.key, this.scrollController});

	@override
	Widget build(BuildContext context) {
		return SafeArea(
			child: ListView(
				controller: scrollController,
				padding: const EdgeInsets.all(20),
				children: [
					Text(
						'Home',
						style: Theme.of(context).textTheme.displayLarge,
					),
					const SizedBox(height: 12),
					Text(
						'Browse upcoming matches and featured courts.',
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
										'Today',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 8),
									const Text('2 open slots'),
									const SizedBox(height: 4),
									const Text('1 pending invite'),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Card(
						child: ListTile(
							leading: const Icon(Icons.calendar_today_outlined),
							title: const Text('Upcoming reservations'),
							subtitle: const Text('Review your next game.'),
							trailing: const Icon(Icons.chevron_right),
						),
					),
				],
			),
		);
	}
}
