import 'package:flutter/material.dart';
import 'package:terminba_mobile/screens/sport_center_search_screen.dart';

class SearchScreen extends StatelessWidget {
	final ScrollController? scrollController;

	const SearchScreen({super.key, this.scrollController});

	@override
	Widget build(BuildContext context) {
		return SportCenterSearchScreen(scrollController: scrollController);
	}
}
