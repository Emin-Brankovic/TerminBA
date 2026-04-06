import 'package:flutter/material.dart';

class UniversalPagination extends StatelessWidget {
	final int currentPage;
	final int totalPages;
	final ValueChanged<int> onPageChanged;

	const UniversalPagination({
		super.key,
		required this.currentPage,
		required this.totalPages,
		required this.onPageChanged,
	});

	@override
	Widget build(BuildContext context) {
		final bool canGoPrevious = currentPage > 1;
		final bool canGoNext = currentPage < totalPages;

		return Row(
			mainAxisSize: MainAxisSize.min,
			children: [
				IconButton(
					onPressed: canGoPrevious ? () => onPageChanged(currentPage - 1) : null,
					icon: const Icon(Icons.chevron_left),
					tooltip: 'Previous page',
				),
				Text(
					'$currentPage / $totalPages',
					style: const TextStyle(fontWeight: FontWeight.w600),
				),
				IconButton(
					onPressed: canGoNext ? () => onPageChanged(currentPage + 1) : null,
					icon: const Icon(Icons.chevron_right),
					tooltip: 'Next page',
				),
			],
		);
	}
}
