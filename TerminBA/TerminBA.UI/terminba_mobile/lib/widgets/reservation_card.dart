import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/reservation_response.dart';

class ReservationCard extends StatelessWidget {
  final ReservationResponse reservation;
  final bool isPast;
  final VoidCallback onShowDetails;
  final VoidCallback? onCancel;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.isPast,
    required this.onShowDetails,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 120,
              color: Colors.grey[300],
              child: (reservation.facility?.photos.isNotEmpty ?? false)
                  ? Image.network(reservation.facility!.photos.first.url ?? "", fit: BoxFit.cover)
                  : const Icon(Icons.sports_soccer, size: 50, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reservation.facility?.name ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${reservation.reservationDate} [${reservation.startTime}-${reservation.endTime}]',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.sports, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      reservation.chosenSport?.name ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                if (reservation.status == "Cancelled") ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Cancelled',
                      style: TextStyle(color: Colors.red[800], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (!isPast && onCancel != null && reservation.status != "Cancelled") ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onShowDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Show Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
