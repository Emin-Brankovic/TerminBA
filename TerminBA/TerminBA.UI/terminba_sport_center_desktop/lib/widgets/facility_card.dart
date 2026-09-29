import 'package:flutter/material.dart';
import 'package:terminba_sport_center_desktop/enums/day_of_week_enum.dart';
import 'package:terminba_sport_center_desktop/model/facility.dart';
import 'package:terminba_sport_center_desktop/model/facility_dynamic_price.dart';
import 'package:terminba_sport_center_desktop/screens/facility_insert_screen.dart';
import 'package:terminba_sport_center_desktop/widgets/confirmation_dialog.dart';


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

            SizedBox(
              height: 120,
              width: double.infinity,
              child: _buildPhoto(),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.facility.name ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildIconDetail(Icons.timer_outlined, '${widget.facility.durationHms} h'),
                            _buildIconDetail(Icons.groups_outlined, '${widget.facility.maxCapacity} max'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildIconDetail(Icons.grass_outlined, widget.facility.turfType?.name ?? ''),
                            _buildIconDetail(
                              widget.facility.isIndoor ? Icons.roofing_outlined : Icons.wb_sunny_outlined,
                              widget.facility.isIndoor ? 'Indoor' : 'Outdoor',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.facility.availableSports.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Text(
                                s.name ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        if (widget.facility.isDynamicPricing)
                          _buildDynamicPrices(widget.facility.dynamicPrices)
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Price', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                              Text(
                                '${widget.facility.staticPrice?.toStringAsFixed(2)} KM',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 75, 204, 103),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

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
                        backgroundColor: const Color(0xFF00C853),
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
                      onPressed: () async {
                        final confirmed = await ConfirmationDialog.show(
                          context,
                          title: 'Delete Facility',
                          message: 'Are you sure you want to delete this facility? This action cannot be undone.',
                          confirmText: 'Delete',
                          cancelText: 'Cancel',
                          confirmButtonColor: const Color(0xFFFF3D00),
                        );

                        if (confirmed) {
                          widget.onDelete(widget.facility.id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3D00),
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

  String _timeStr(String t) => t.length >= 8 ? t.substring(0, 8) : t;

  bool _isActiveToday(FacilityDynamicPrice dp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = DateTime(dp.validFrom.year, dp.validFrom.month, dp.validFrom.day);
    if (from.isAfter(today)) return false;
    if (dp.validTo != null) {
      final to = DateTime(dp.validTo!.year, dp.validTo!.month, dp.validTo!.day);
      if (to.isBefore(today)) return false;
    }
    return true;
  }

  Widget _buildDynamicPrices(List<FacilityDynamicPrice> prices) {
    final activePrices = prices.where(_isActiveToday).toList();
    if (activePrices.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Prices',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        ...activePrices.map(
          (dp) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${_dayName(dp.startDay)}–${_dayName(dp.endDay)}: ${_timeStr(dp.startTime)}–${_timeStr(dp.endTime)}',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 17),
                Text(
                  '${dp.price.toStringAsFixed(2)} KM',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:Color.fromARGB(255, 75, 204, 103)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconDetail(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

    return widget.facility.photos.where((p) => (p.url?.isNotEmpty ?? false)).map((p) => p.url!).toList();
  }
}

