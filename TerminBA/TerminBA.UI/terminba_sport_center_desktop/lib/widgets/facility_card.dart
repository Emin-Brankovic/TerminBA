import 'package:flutter/material.dart';
import 'package:terminba_sport_center_desktop/enums/day_of_week_enum.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/facility_dynamic_price.dart';
// import 'package:terminba_admin_desktop/enums/day_of_week_enum.dart';
// import 'package:terminba_admin_desktop/model/sport_center.dart';
// import 'package:terminba_admin_desktop/model/working_hours.dart';
// import 'package:terminba_admin_desktop/screens/sport_center_insert_screen.dart';

class FacilityCard extends StatelessWidget {
  const FacilityCard({
    super.key,
    required this.facility,
    required this.onDelete,
    required this.onRefresh,
  });

  final Facility facility;
  final Function(int id) onDelete;
  final VoidCallback onRefresh;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // 1. Placeholder Image Section
            Container(
              height: 150,
              width: double.infinity,
              color: const Color(0xFFE8F0FE),
              child: const Icon(
                Icons.image,
                color: Colors.blueAccent,
                size: 50,
              ),
            ),

            // 2. Content Section
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0 ,horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Surface Type:', facility.turfType?.name ?? ''),
                        _buildDetailRow('Duration:', facility.durationHms + ' h'),
                        _buildDetailRow('Indoor:', facility.isIndoor ? 'Yes' : 'No'),
                        _buildDetailRow(
                          'Max players on court:',
                          facility.maxCapacity.toString(),
                        ),
                        _buildDetailRow(
                          'Available Sports:',
                          facility.availableSports
                              .map((s) => s.name ?? '')
                              .join(', '),
                        ),

                        if (facility.isDynamicPricing)
                          ..._buildDynamicPrices(facility.dynamicPrices)
                        else
                           _buildDetailRow('Price:', facility.staticPrice.toString() + ' €'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Action Buttons Section
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // await Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (_) => facilityInsertScreen(
                        //       facility: facility,
                        //     ),
                        //   ),
                        // );
                        // onRefresh();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853), // Green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                              'Are you sure you want to delete this item?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  onDelete(facility.id);
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3D00), // Red/Orange
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayName(DayOfWeek d) => d.name[0].toUpperCase() + d.name.substring(1);

  // Trims to HH:mm:ss in case backend sends fractional seconds.
  String _timeStr(String t) => t.length >= 8 ? t.substring(0, 8) : t;

  List<Widget> _buildDynamicPrices(List<FacilityDynamicPrice> prices) {
    return [
      const Text(
        'Price:',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 2),
      ...prices.map(
        (dp) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            '${_dayName(dp.startDay)} – ${_dayName(dp.endDay)}: '
            '${_timeStr(dp.startTime)} – ${_timeStr(dp.endTime)} '
            '(${dp.pricePerHour.toStringAsFixed(2)} €)',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ),
    ];
  }

  // Helper method to create the info lines
  Widget _buildDetailRow(String label, [String value = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
