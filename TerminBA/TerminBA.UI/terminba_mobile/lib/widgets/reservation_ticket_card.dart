import 'package:flutter/material.dart';
import 'package:terminba_mobile/model/reservation_response.dart';

class ReservationTicketCard extends StatelessWidget {
  final ReservationResponse details;

  const ReservationTicketCard({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reservation ID',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Text(
                  '${details.id.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildRow('Name', '${details.user?.firstName ?? ''} ${details.user?.lastName ?? ''}'.trim()),
                _buildDivider(),
                _buildRow('Mobile', details.user?.phoneNumber ?? ''),
                _buildDivider(),
                _buildRow('Sport', details.chosenSport?.name ?? ''),
                _buildDivider(),
                _buildRow('Address', '${details.facility?.sportCenter?.address ?? ''}, ${details.facility?.sportCenter?.city?.name ?? ''}'),
                _buildDivider(),
                _buildRow('Date', details.reservationDate ?? ''),
                _buildDivider(),
                _buildRow('Time', '${details.startTime ?? ''} - ${details.endTime ?? ''}'),
                _buildDivider(),
                _buildRow('Court', details.facility?.name ?? ''),
                _buildDivider(),
                _buildRow('Price', '${(details.price ?? 0).toStringAsFixed(2)} BAM', isHighlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                fontSize: isHighlight ? 16 : 14,
                color: isHighlight ? Colors.green : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE));
  }
}
