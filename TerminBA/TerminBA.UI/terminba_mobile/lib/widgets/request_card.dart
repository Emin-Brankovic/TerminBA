import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/play_request_response.dart';

/// Card for Received requests — shows requester info + Accept/Deny buttons.
class ReceivedRequestCard extends StatelessWidget {
  final PlayRequestResponse request;
  final VoidCallback? onAccept;
  final VoidCallback? onDeny;

  const ReceivedRequestCard({
    super.key,
    required this.request,
    this.onAccept,
    this.onDeny,
  });

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return '';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return d;
    }
  }

  String _formatDateOnly(String? d) {
    if (d == null || d.isEmpty) return '';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return d;
    }
  }

  String _formatTime(String? t) {
    if (t == null) return '';
    return t.substring(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    final requester = request.requester;
    final name = requester != null
        ? '${requester.firstName} ${requester.lastName}'
        : 'Unknown';
    final initials = requester != null
        ? '${requester.firstName.isNotEmpty ? requester.firstName[0] : ''}${requester.lastName.isNotEmpty ? requester.lastName[0] : ''}'
            .toUpperCase()
        : '?';

    final bool alreadyResponded = request.isAccepted != null;
    final bool isPostClosed = request.post?.isClosed == true;
    final bool canRespond = !alreadyResponded && !isPostClosed;

    final post = request.post;
    final facility = post?.reservation?.facility;
    final sport = post?.reservation?.chosenSport;
    final city = facility?.sportCenter?.city?.name ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF00C875).withOpacity(0.15),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C875),
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatDate(request.dateOfRequest),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (request.isSeenByOwner == false)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: _StatusChip(
                          label: 'New',
                          color: Colors.blue.shade600,
                        ),
                      ),
                    if (alreadyResponded)
                      Padding(
                        padding: EdgeInsets.only(bottom: isPostClosed ? 4.0 : 0.0),
                        child: _StatusChip(
                          label: request.isAccepted == true ? 'Accepted' : 'Denied',
                          color: request.isAccepted == true
                              ? const Color(0xFF00C875)
                              : Colors.red,
                        ),
                      ),
                    if (isPostClosed)
                      _StatusChip(
                        label: 'Finished',
                        color: Colors.grey.shade600,
                      ),
                  ],
                ),
              ],
            ),

            if (request.requestText != null &&
                request.requestText!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  '"${request.requestText}"',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${facility?.sportCenter?.username != null && facility!.sportCenter!.username!.isNotEmpty ? '${facility.sportCenter!.username} - ' : ''}${facility?.name ?? ''}'
                    '${city.isNotEmpty ? ', $city' : ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${_formatDateOnly(post?.reservation?.reservationDate)}'
                  '  ${_formatTime(post?.reservation?.startTime)} – ${_formatTime(post?.reservation?.endTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                if (sport != null)
                  _SmallBadge(label: sport.name!.toUpperCase()),
                if (post?.skillLevel != null)
                  _SmallBadge(label: post!.skillLevel!.toUpperCase()),
              ],
            ),

            if (canRespond) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C875),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDeny,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Deny'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card for Sent requests — shows post summary + current status.
class SentRequestCard extends StatelessWidget {
  final PlayRequestResponse request;
  final VoidCallback? onCancel;

  const SentRequestCard({
    super.key,
    required this.request,
    this.onCancel,
  });

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return '';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return d;
    }
  }

  String _formatTime(String? t) {
    if (t == null) return '';
    return t.substring(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    final post = request.post;
    final facility = post?.reservation?.facility;
    final sport = post?.reservation?.chosenSport;
    final postOwner = post?.reservation?.user;
    final ownerName = postOwner != null
        ? '${postOwner.firstName} ${postOwner.lastName}'
        : 'Unknown';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${facility?.sportCenter?.username != null && facility!.sportCenter!.username!.isNotEmpty ? '${facility.sportCenter!.username} - ' : ''}${facility?.name ?? 'Unknown facility'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'by $ownerName',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (request.isSeenByRequester == false && request.isAccepted != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: _StatusChip(
                          label: 'New',
                          color: Colors.blue.shade600,
                        ),
                      ),
                    _StatusChip(
                      label: request.statusLabel,
                      color: _statusColor(request.isAccepted),
                    ),
                    if (request.post?.isClosed == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: _StatusChip(
                          label: 'Finished',
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(post?.reservation?.reservationDate)}'
                  '  ${_formatTime(post?.reservation?.startTime)} – ${_formatTime(post?.reservation?.endTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                if (sport != null)
                  _SmallBadge(label: sport.name!.toUpperCase()),
                if (post?.skillLevel != null)
                  _SmallBadge(label: post!.skillLevel!.toUpperCase()),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              'Sent: ${_formatDate(request.dateOfRequest)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            if (request.isAccepted != false && request.post?.isClosed != true) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel Request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(bool? accepted) {
    if (accepted == null) return Colors.orange;
    return accepted ? const Color(0xFF00C875) : Colors.red;
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;

  const _SmallBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
