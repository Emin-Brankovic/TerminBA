import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/cancelation_notification_response.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/cancelation_notification_provider.dart';
import 'package:terminba_mobile/providers/notification_provider.dart';
import 'package:intl/intl.dart';

class CancelationNotificationsScreen extends StatefulWidget {
  const CancelationNotificationsScreen({super.key});

  @override
  State<CancelationNotificationsScreen> createState() => _CancelationNotificationsScreenState();
}

class _CancelationNotificationsScreenState extends State<CancelationNotificationsScreen> {
  static const _pageSize = 10;

  final PagingController<int, CancelationNotificationResponse> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final result = await context.read<CancelationNotificationProvider>().get(
        filter: {
          'page': pageKey,
          'pageSize': _pageSize,
        },
      );

      final items = result.items ?? [];
      final total = result.totalCount ?? 0;
      final fetched = (pageKey - 1) * _pageSize + items.length;

      if (fetched >= total) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _markAsSeen(CancelationNotificationResponse notification) async {
    if (notification.isSeen) return;

    try {
      await context.read<NotificationProvider>().markCancelationAsSeen(notification.id);
      _pagingController.refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as seen: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd.MM.yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancelation Notifications'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        color: const Color(0xFF00C875),
        child: PagedListView<int, CancelationNotificationResponse>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<CancelationNotificationResponse>(
            itemBuilder: (context, item, index) => _buildNotificationCard(item),
            firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
            noItemsFoundIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No cancelation notifications yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(CancelationNotificationResponse notification) {
    final isUnseen = !notification.isSeen;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isUnseen ? Colors.orange.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnseen ? Colors.orange.shade200 : Colors.grey.shade200,
          width: isUnseen ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () => _markAsSeen(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cancel_presentation,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Request Cancelled',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isUnseen)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${notification.requesterName} has cancelled their accepted request for your reservation at ${notification.facilityName}${notification.reservation?.reservationDate != null ? ' on ${_formatDate(notification.reservation!.reservationDate!)}' : ''}.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                _formatDate(notification.dateCancelled),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
