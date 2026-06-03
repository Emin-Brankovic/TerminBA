import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:terminba_mobile/features/sport_center/sport_center_search_notifier.dart';
import 'package:terminba_mobile/features/sport_center/sport_center_search_state.dart';
import 'package:terminba_mobile/widgets/sport_center_card.dart';
import 'package:terminba_mobile/widgets/sport_filter_chips.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/sport_center_provider.dart';
import 'package:terminba_mobile/providers/sport_provider.dart';
import 'package:terminba_mobile/screens/profile_screen.dart';
import 'package:terminba_mobile/screens/sport_center_detail_screen.dart';

class SportCenterSearchScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const SportCenterSearchScreen({super.key, this.scrollController});

  @override
  State<SportCenterSearchScreen> createState() => _SportCenterSearchScreenState();
}

class _SportCenterSearchScreenState extends State<SportCenterSearchScreen>
    with AutomaticKeepAliveClientMixin {
  late final SportCenterSearchNotifier _notifier;
  bool _showFilters = true;

  @override
  void initState() {
    super.initState();
    _notifier = SportCenterSearchNotifier(
      authProvider: context.read<AuthProvider>(),
      sportCenterProvider: context.read<SportCenterProvider>(),
      sportProvider: context.read<SportProvider>(),
    );
    _notifier.initialize();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<SportCenterSearchNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                    child: _buildTopBar(state),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onChanged: notifier.updateSearchQuery,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search...',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Turfs',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: () {
                            setState(() => _showFilters = !_showFilters);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_showFilters)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: SportFilterChips(
                        selectedDate: state.selectedDate,
                        selectedSport: state.selectedSport,
                        sports: state.sports,
                      onDateTap: () => _selectDate(context, notifier),
                      onSportTap: notifier.selectSport,
                    ),
                  ),
                  if (state.error != null)
                    _ErrorBanner(
                      message: state.error!,
                      onRetry: notifier.loadFacilities,
                    ),
                  Expanded(
                    child: _buildContent(state, notifier),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(SportCenterSearchState state) {
    final theme = Theme.of(context);
    final city = state.userCity.isEmpty ? 'Your city' : state.userCity;
    final name = state.userName.isEmpty ? 'User' : state.userName;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Row(
      children: [
        const Icon(Icons.place_outlined, color: Colors.black54),
        const SizedBox(width: 6),
        Text(
          city,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          'Hi, $name',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFECFFF6),
            child: Text(
              initials,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00A565),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    SportCenterSearchState state,
    SportCenterSearchNotifier notifier,
  ) {
    if (state.isLoading) {
      return ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: 4,
        itemBuilder: (context, index) => _ShimmerCard(key: ValueKey(index)),
      );
    }

    if (state.sportCenters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'No sport centers found for ${_sportLabel(state)} on ${_dateLabel(state)}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: notifier.clearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: state.sportCenters.length,
      itemBuilder: (context, index) {
        final center = state.sportCenters[index];
        return SportCenterCard(
          sportCenter: center,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SportCenterDetailScreen(
                  sportCenterId: center.id,
                  selectedDate: state.selectedDate,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _sportLabel(SportCenterSearchState state) {
    return state.selectedSport?.name ?? 'all sports';
  }

  String _dateLabel(SportCenterSearchState state) {
    final date = state.selectedDate;
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(
    BuildContext context,
    SportCenterSearchNotifier notifier,
  ) async {
    final initialDate = notifier.state.selectedDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      notifier.selectDate(DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      ));
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(height: 16, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 12, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
