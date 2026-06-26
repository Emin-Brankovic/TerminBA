import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/favorite_sport_center.dart';
import 'package:terminba_mobile/providers/favorite_sport_center_provider.dart';
import 'package:terminba_mobile/widgets/sport_center_card.dart';
import 'package:terminba_mobile/screens/sport_center_detail_screen.dart';
import 'dart:async';

class FavoriteSportCentersScreen extends StatefulWidget {
  const FavoriteSportCentersScreen({super.key});

  @override
  State<FavoriteSportCentersScreen> createState() => _FavoriteSportCentersScreenState();
}

class _FavoriteSportCentersScreenState extends State<FavoriteSportCentersScreen> {
  static const _pageSize = 10;
  late PagingController<int, FavoriteSportCenter> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final provider = context.read<FavoriteSportCenterProvider>();
      
      final filter = <String, dynamic>{
        'Page': pageKey,
        'PageSize': _pageSize,
      };

      final result = await provider.get(filter: filter);
      
      final newItems = result.items ?? [];
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: PagedListView<int, FavoriteSportCenter>(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<FavoriteSportCenter>(
          itemBuilder: (context, favorite, index) {
            if (favorite.sportCenter == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SportCenterCard(
                sportCenter: favorite.sportCenter!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SportCenterDetailScreen(
                        sportCenterId: favorite.sportCenterId!,
                        selectedDate: DateTime.now(),
                      ),
                    ),
                  ).then((_) {
                    _pagingController.refresh();
                  });
                },
              ),
            );
          },
          noItemsFoundIndicatorBuilder: (context) => const Center(
            child: Text('No favorites added yet.'),
          ),
          firstPageErrorIndicatorBuilder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Something went wrong.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pagingController.refresh,
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
