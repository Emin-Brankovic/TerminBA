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
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

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

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _markSelectedAsRead() async {
    if (_selectedIds.isEmpty) return;

    try {
      await context.read<CancelationNotificationProvider>().markAsSeenMultiple(_selectedIds.toList());
      if (mounted) {
         await context.read<NotificationProvider>().fetchUnseenCount();
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Notifications marked as read')),
         );
      }
      _clearSelection();
      _pagingController.refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as seen: $e')),
        );
      }
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await _showConfirmationDialog(
      'Delete Notifications',
      'Are you sure you want to delete selected notifications?',
    );
    if (!confirm) return;

    try {
      await context.read<CancelationNotificationProvider>().deleteMultiple(_selectedIds.toList());
      if (mounted) {
         await context.read<NotificationProvider>().fetchUnseenCount();
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Notifications deleted successfully')),
         );
      }
      _clearSelection();
      _pagingController.refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notifications: $e')),
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
        title: _isSelectionMode
            ? Text('${_selectedIds.length} Selected')
            : const Text('Notifications'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.mark_email_read),
                  onPressed: _markSelectedAsRead,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelected,
                ),
              ]
            : null,
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
    final isSelected = _selectedIds.contains(notification.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isSelected ? Colors.green.shade50 : (isUnseen ? Colors.orange.shade50 : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.green : (isUnseen ? Colors.orange.shade200 : Colors.grey.shade200),
          width: isSelected || isUnseen ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onLongPress: () {
          setState(() {
            _isSelectionMode = true;
            _toggleSelection(notification.id);
          });
        },
        onTap: () {
          if (_isSelectionMode) {
            _toggleSelection(notification.id);
          } else {
            _markAsSeen(notification);
          }
        },
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
                  if (isUnseen && !_isSelectionMode)
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
                  if (_isSelectionMode)
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.green : Colors.grey,
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
