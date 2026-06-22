import 'package:flutter/material.dart';
import 'package:terminba_mobile/screens/reservations_screen.dart';
import 'package:terminba_mobile/screens/home_screen.dart';
import 'package:terminba_mobile/screens/profile_menu_screen.dart';
import 'package:terminba_mobile/screens/search_screen.dart';

enum BottomTab {
	home,
	search,
	bookings,
	profile,
}

class MasterScreenBottomNav extends StatefulWidget {
	final int initialIndex;

	const MasterScreenBottomNav({super.key, this.initialIndex = 0});

	@override
	State<MasterScreenBottomNav> createState() => _MasterScreenBottomNavState();
}

class _MasterScreenBottomNavState extends State<MasterScreenBottomNav> {
	late int _selectedIndex;
	final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
		BottomTab.values.length,
		(_) => GlobalKey<NavigatorState>(),
	);
	final List<ScrollController> _scrollControllers = List.generate(
		BottomTab.values.length,
		(_) => ScrollController(),
	);

	@override
	void initState() {
		super.initState();
		_selectedIndex = widget.initialIndex
				.clamp(0, BottomTab.values.length - 1)
				.toInt();
	}

	@override
	void dispose() {
		for (final controller in _scrollControllers) {
			controller.dispose();
		}
		super.dispose();
	}

	Future<bool> _onWillPop() async {
		final currentNavigator = _navigatorKeys[_selectedIndex].currentState;
		if (currentNavigator != null && currentNavigator.canPop()) {
			currentNavigator.pop();
			return false;
		}

		if (_selectedIndex != 0) {
			setState(() {
				_selectedIndex = 0;
			});
			return false;
		}

		return true;
	}

	void _onTabTapped(int index) {
		if (index == _selectedIndex) {
			final currentNavigator = _navigatorKeys[index].currentState;
			if (currentNavigator != null && currentNavigator.canPop()) {
				currentNavigator.popUntil((route) => route.isFirst);
			}
			final controller = _scrollControllers[index];
			if (controller.hasClients) {
				controller.animateTo(
					0,
					duration: const Duration(milliseconds: 250),
					curve: Curves.easeOut,
				);
			}
			return;
		}

		setState(() {
			_selectedIndex = index;
		});
	}

	Widget _buildTabNavigator(BottomTab tab, int index) {
		return Navigator(
			key: _navigatorKeys[index],
			onGenerateRoute: (settings) {
				late final Widget screen;
				switch (tab) {
					case BottomTab.home:
						screen = HomeScreen(scrollController: _scrollControllers[index]);
						break;
					case BottomTab.search:
						screen = SearchScreen(scrollController: _scrollControllers[index]);
						break;
					case BottomTab.bookings:
						screen =
								ReservationsScreen(scrollController: _scrollControllers[index]);
						break;
					case BottomTab.profile:
						screen =
								ProfileMenuScreen(scrollController: _scrollControllers[index]);
						break;
				}
				return MaterialPageRoute(builder: (_) => screen);
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		final selectedColor = Theme.of(context).colorScheme.primary;

		return WillPopScope(
			onWillPop: _onWillPop,
			child: Scaffold(
				body: IndexedStack(
					index: _selectedIndex,
					children: [
						for (final tab in BottomTab.values)
							_buildTabNavigator(tab, tab.index),
					],
				),
				bottomNavigationBar: NavigationBar(
					selectedIndex: _selectedIndex,
					onDestinationSelected: _onTabTapped,
					destinations: [
						NavigationDestination(
							icon:  Semantics(
								label: 'Home',
								selected: false,
								child: Icon(Icons.home_outlined),
							),
							selectedIcon: Semantics(
								label: 'Home',
								selected: true,
								child: Icon(
									Icons.home_outlined,
									color: selectedColor,
								),
							),
							label: 'Home',
						),
						NavigationDestination(
							icon: Semantics(
								label: 'Search',
								selected: false,
								child: Icon(Icons.search_outlined),
							),
							selectedIcon: Semantics(
								label: 'Search',
								selected: true,
								child: Icon(
									Icons.search_outlined,
									color: selectedColor,
								),
							),
							label: 'Search',
						),
						NavigationDestination(
							icon: Semantics(
								selected: false,
								child: Badge(
									child: Icon(Icons.event_available_outlined),
								),
							),
							selectedIcon: Semantics(
								selected: true,
								child: Badge(
									child: Icon(
										Icons.event_available_outlined,
										color: selectedColor,
									),
								),
							),
							label: 'Bookings',
						),
						NavigationDestination(
							icon: Semantics(
								label: 'Profile',
								selected: false,
								child: Icon(Icons.person_outline),
							),
							selectedIcon: Semantics(
								label: 'Profile',
								selected: true,
								child: Icon(
									Icons.person_outline,
									color: selectedColor,
								),
							),
							label: 'Profile',
						),
					],
				),
			),
		);
	}
}
