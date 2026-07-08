import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/post_response.dart';

class PlayerSearchPostCard extends StatelessWidget {
  final PostResponse post;
  final bool isOwner;
  final String? requestStatus;
  final VoidCallback? onSendRequest;
  final VoidCallback? onClosePost;
  final VoidCallback? onEditPost;

  const PlayerSearchPostCard({
    super.key,
    required this.post,
    this.isOwner = false,
    this.requestStatus,
    this.onSendRequest,
    this.onClosePost,
    this.onEditPost,
  });

  static const _sportColor = Color(0xFF00C875);
  static const _skillColors = {
    'beginner': Color(0xFF4CAF50),
    'medium': Color(0xFFFF9800),
    'intermediate': Color(0xFFFF9800),
    'advance': Color(0xFFF44336),
    'advanced': Color(0xFFF44336),
  };

  Color _skillColor(String? level) {
    if (level == null) return Colors.grey;
    return _skillColors[level.toLowerCase()] ?? Colors.blueGrey;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String? t) {
    if (t == null) return '';
    return t.substring(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    final reservation = post.reservation;
    final user = reservation?.user;
    final facility = reservation?.facility;
    final sport = reservation?.chosenSport;
    final city = facility?.sportCenter?.city?.name ?? '';

    final posterName = user != null
        ? '${user.firstName} ${user.lastName}'
        : 'Unknown User';

    final initials = user != null
        ? '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
            .toUpperCase()
        : '??';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + name + badges
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _sportColor.withOpacity(0.15),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _sportColor,
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
                        posterName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: [
                          if (sport != null)
                            _Badge(
                              label: sport.name!.toUpperCase(),
                              color: _sportColor,
                            ),
                          if (post.skillLevel != null)
                            _Badge(
                              label: post.skillLevel!.toUpperCase(),
                              color: _skillColor(post.skillLevel),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Description
            if (post.text != null && post.text!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                post.text!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 10),

            // Location + Date row
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${facility?.sportCenter?.username != null && facility!.sportCenter!.username!.isNotEmpty ? '${facility.sportCenter!.username} - ' : ''}${facility?.name ?? ''}'
                    '${city.isNotEmpty ? ', $city' : ''}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(reservation?.reservationDate)}'
                  '  ${_formatTime(reservation?.startTime)} – ${_formatTime(reservation?.endTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  '${post.numberOfPlayersFound}/${post.numberOfPlayersWanted} found',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Action button
            SizedBox(
              width: double.infinity,
              child: isOwner
                  ? (post.isClosed
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Closed',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onEditPost,
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit Post'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue.shade600,
                                  side: BorderSide(color: Colors.blue.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onClosePost,
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Close Post'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade600,
                                  side: BorderSide(color: Colors.red.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ))
                  : (requestStatus == 'Joined'
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C875).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF00C875)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Accepted',
                            style: TextStyle(
                              color: Color(0xFF00C875),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            if (requestStatus == 'Pending') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request already sent.')),
                              );
                            } else if (onSendRequest != null) {
                              onSendRequest!();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: requestStatus == 'Pending' ? Colors.grey.shade400 : const Color(0xFF00C875),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            requestStatus == 'Pending' ? 'Request sent' : 'Send Request',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
