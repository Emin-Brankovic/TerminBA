import 'package:flutter/material.dart';
import 'package:terminba_sport_center_desktop/enums/day_of_week_enum.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/facility_dynamic_price.dart';
import 'package:terminba_sport_center_desktop/screens/facility_insert_screen.dart';
// import 'package:terminba_admin_desktop/enums/day_of_week_enum.dart';
// import 'package:terminba_admin_desktop/model/sport_center.dart';
// import 'package:terminba_admin_desktop/model/working_hours.dart';
// import 'package:terminba_admin_desktop/screens/sport_center_insert_screen.dart';

class FacilityCard extends StatefulWidget {
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
  State<FacilityCard> createState() => _FacilityCardState();
}

class _FacilityCardState extends State<FacilityCard> {
  late final PageController _photoController;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _photoController = PageController();
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

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
            // 1. Photo Section
            SizedBox(
              height: 150,
              width: double.infinity,
              child: _buildPhoto(),
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
                          widget.facility.name ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Surface Type:',
                          widget.facility.turfType?.name ?? '',
                        ),
                        _buildDetailRow('Duration:', widget.facility.durationHms + ' h'),
                        _buildDetailRow(
                          'Indoor:',
                          widget.facility.isIndoor ? 'Yes' : 'No',
                        ),
                        _buildDetailRow(
                          'Max players on court:',
                          widget.facility.maxCapacity.toString(),
                        ),
                        _buildDetailRow(
                          'Available Sports:',
                          widget.facility.availableSports
                              .map((s) => s.name ?? '')
                              .join(', '),
                        ),

                        if (widget.facility.isDynamicPricing)
                          ..._buildDynamicPrices(widget.facility.dynamicPrices)
                        else
                           _buildDetailRow(
                             'Price:',
                             widget.facility.staticPrice.toString() + ' €',
                           ),
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
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => FacilityInsertScreen(
                              facility: widget.facility,
                            ),
                          ),
                        );

                        if (updated == true) {
                          widget.onRefresh();
                        }
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
                                  widget.onDelete(widget.facility.id);
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

  Widget _buildPhoto() {
    final photoUrls = _buildPhotoUrls();
    if (photoUrls.isEmpty) {
      return Container(
        color: const Color(0xFFE8F0FE),
        child: const Icon(
          Icons.image,
          color: Colors.blueAccent,
          size: 50,
        ),
      );
    }

    if (photoUrls.length == 1) {
      return _buildPhotoImage(photoUrls.first);
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _photoController,
          itemCount: photoUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentPhotoIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return _buildPhotoImage(photoUrls[index]);
          },
        ),
        Positioned(
          left: 8,
          top: 0,
          bottom: 0,
          child: _buildNavButton(
            icon: Icons.chevron_left,
            onPressed: () => _goToPhoto(photoUrls.length, -1),
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: _buildNavButton(
            icon: Icons.chevron_right,
            onPressed: () => _goToPhoto(photoUrls.length, 1),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: _buildDots(photoUrls.length),
        ),
      ],
    );
  }

  Widget _buildPhotoImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFE8F0FE),
          child: const Icon(
            Icons.broken_image,
            color: Colors.blueAccent,
            size: 50,
          ),
        );
      },
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onPressed}) {
    return Center(
      child: Material(
        color: Colors.black.withOpacity(0.35),
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPhotoIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 10 : 6,
          height: isActive ? 10 : 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white70,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  void _goToPhoto(int total, int step) {
    if (total <= 1) {
      return;
    }

    final nextIndex = (_currentPhotoIndex + step) % total;
    _photoController.animateToPage(
      nextIndex < 0 ? total - 1 : nextIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  List<String> _buildPhotoUrls() {
    if (widget.facility.photos.isEmpty) {
      return const [];
    }

    final mainPhotos = widget.facility.photos
        .where((p) => p.isMain == true && (p.url?.isNotEmpty ?? false))
        .map((p) => p.url!)
        .toList();

    final otherPhotos = widget.facility.photos
        .where((p) => p.isMain != true && (p.url?.isNotEmpty ?? false))
        .map((p) => p.url!)
        .toList();

    return [...mainPhotos, ...otherPhotos];
  }
}
