import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
	final ScrollController? scrollController;

	const BookingsScreen({super.key, this.scrollController});

	@override
	Widget build(BuildContext context) {
		return SafeArea(
			child: ListView(
				controller: scrollController,
				padding: const EdgeInsets.all(20),
				children: [
					Text(
						'Bookings',
						style: Theme.of(context).textTheme.displayLarge,
					),
					const SizedBox(height: 12),
					Text(
						'Manage your upcoming reservations.',
						style: Theme.of(context).textTheme.bodyMedium,
					),
					const SizedBox(height: 20),
					Card(
						child: ListTile(
							leading: const Icon(Icons.event_available_outlined),
							title: const Text('Court 2 - 18:00'),
							subtitle: const Text('City Arena · Tonight'),
							trailing: const Icon(Icons.chevron_right),
						),
					),
					const SizedBox(height: 12),
					Card(
						child: ListTile(
							leading: const Icon(Icons.schedule_outlined),
							title: const Text('Pending confirmation'),
							subtitle: const Text('Waiting for approval'),
							trailing: const Icon(Icons.chevron_right),
						),
					),
				],
			),
		);
	}
}
