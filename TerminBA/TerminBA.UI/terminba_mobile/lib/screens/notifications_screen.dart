import 'package:flutter/material.dart';
import 'package:terminba_mobile/widgets/confirmation_dialog.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/notification_response.dart';
import 'package:terminba_mobile/providers/auth_provider.dart';
import 'package:terminba_mobile/providers/unified_notification_provider.dart';
import 'package:terminba_mobile/providers/notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _pageSize = 10;
  bool _isSelectionMode = false;
  final Set<Map<String, dynamic>> _selectedItems = {};

  final PagingController<int, NotificationResponse> _pagingController =
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
      final result = await context.read<UnifiedNotificationProvider>().get(
        filter: {
          'page': pageKey,
          'pageSize': _pageSize,
        },
      );

      if (!mounted) return;

      final items = result.items ?? [];
      final total = result.totalCount ?? 0;
      final fetched = (pageKey - 1) * _pageSize + items.length;

      if (fetched >= total) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, pageKey + 1);
      }
    } catch (error) {
      if (!mounted) return;
      _pagingController.error = error;
    }
  }

  Future<void> _markAsSeen(NotificationResponse notification) async {
    if (notification.isSeen) return;

    try {
      await context.read<NotificationProvider>().markCancelationAsSeen(notification.id, notification.type);
      _pagingController.refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as seen: $e')),
        );
      }
    }
  }

  void _toggleSelection(NotificationResponse notification) {
    setState(() {
      var existing = _selectedItems.where((i) => i['id'] == notification.id && i['type'] == notification.type);
      if (existing.isNotEmpty) {
        _selectedItems.removeWhere((i) => i['id'] == notification.id && i['type'] == notification.type);
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add({'id': notification.id, 'type': notification.type});
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _markSelectedAsRead() async {
    if (_selectedItems.isEmpty) return;

    try {
      await context.read<UnifiedNotificationProvider>().markAsSeenMultiple(_selectedItems.toList());
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
    if (_selectedItems.isEmpty) return;

    final confirm = await ConfirmationDialog.show(
      context,
      title: 'Delete Notifications',
      message: 'Are you sure you want to delete the selected notifications? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (!confirm) return;

    try {
      await context.read<UnifiedNotificationProvider>().deleteMultiple(_selectedItems.toList());
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
      return DateFormat('dd.MM.yyyy HH:mm').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateOnly(String dateStr) {
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
            ? Text('${_selectedItems.length} Selected')
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
        child: PagedListView<int, NotificationResponse>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<NotificationResponse>(
            itemBuilder: (context, item, index) => _buildNotificationCard(item),
            firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
            noItemsFoundIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationResponse notification) {
    final isUnseen = !notification.isSeen;
    final isSelected = _selectedItems.any((i) => i['id'] == notification.id && i['type'] == notification.type);
    final isCancelation = notification.type == "Cancelation";

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
            _toggleSelection(notification);
          });
        },
        onTap: () {
          if (_isSelectionMode) {
            _toggleSelection(notification);
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
                    isCancelation ? Icons.cancel_presentation : Icons.edit_calendar,
                    color: isCancelation ? Colors.orange.shade700 : Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isCancelation 
                          ? (notification.postOwnerId == notification.reservation?.userId
                              ? ((notification.reservation?.isCancelled ?? false) ? 'Reservation Canceled by Sport Center' : 'Accepted Request Canceled')
                              : 'Reservation Canceled')
                          : 'Reservation Updated',
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
                isCancelation
                    ? (notification.postOwnerId == notification.reservation?.userId
                        ? ((notification.reservation?.isCancelled ?? false)
                            ? '${notification.requesterName} has canceled your reservation${notification.reservation?.reservationDate != null ? ' on ${_formatDateOnly(notification.reservation!.reservationDate!)}' : ''}.'
                            : '${notification.requesterName} has canceled their accepted request for your reservation at ${notification.facilityName}${notification.reservation?.reservationDate != null ? ' on ${_formatDateOnly(notification.reservation!.reservationDate!)}' : ''}.')
                        : '${notification.requesterName} has canceled their reservation at ${notification.facilityName}${notification.reservation?.reservationDate != null ? ' on ${_formatDateOnly(notification.reservation!.reservationDate!)}' : ''}, so your accepted request is canceled.')
                    : '${notification.requesterName} has updated the reservation at ${notification.facilityName}${notification.reservation?.reservationDate != null ? ' on ${_formatDateOnly(notification.reservation!.reservationDate!)}' : ''}.',
                style: const TextStyle(fontSize: 14),
              ),
              if (notification.reason != null && notification.reason!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCancelation ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isCancelation ? Colors.red.shade200 : Colors.blue.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(isCancelation ? Icons.info_outline : Icons.update, color: isCancelation ? Colors.red.shade700 : Colors.blue.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isCancelation ? 'Reason: ${notification.reason}' : '${notification.reason}',
                          style: TextStyle(
                            color: isCancelation ? Colors.red.shade900 : Colors.blue.shade900,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                _formatDate(notification.date),
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
