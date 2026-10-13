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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Photo Section
            SizedBox(
              height: 130,
              width: double.infinity,
              child: _buildPhoto(),
            ),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Facility Header: Name + Indoor/Outdoor badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.facility.name ?? '',
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: widget.facility.isIndoor ? const Color(0xFFEFF6FF) : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: widget.facility.isIndoor ? const Color(0xFFBFDBFE) : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.facility.isIndoor ? Icons.roofing_outlined : Icons.wb_sunny_outlined,
                                  size: 12,
                                  color: widget.facility.isIndoor ? const Color(0xFF1D4ED8) : const Color(0xFFB45309),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  widget.facility.isIndoor ? 'Indoor' : 'Outdoor',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: widget.facility.isIndoor ? const Color(0xFF1D4ED8) : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Grouped Specifications Unit
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildSpecItem(Icons.schedule_rounded, '${widget.facility.durationHms} h'),
                                const SizedBox(width: 8),
                                _buildSpecItem(Icons.groups_outlined, '${widget.facility.maxCapacity} players'),
                              ],
                            ),
                            if ((widget.facility.turfType?.name ?? '').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildSpecItem(Icons.grass_outlined, widget.facility.turfType!.name),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sports Tags
                      if (widget.facility.availableSports.isNotEmpty) ...[
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: widget.facility.availableSports.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Text(
                                s.name ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1D4ED8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Pricing Section
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 10),
                      if (widget.facility.isDynamicPricing)
                        _buildDynamicPrices(widget.facility.dynamicPrices)
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRICE',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'per slot',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${widget.facility.staticPrice?.toStringAsFixed(2)} KM',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text('Edit', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await ConfirmationDialog.show(
                          context,
                          title: 'Delete Facility',
                          message: 'Are you sure you want to delete this facility? This action cannot be undone.',
                          confirmText: 'Delete',
                          cancelText: 'Cancel',
                          confirmButtonColor: const Color(0xFFDC2626),
                        );

                        if (confirmed) {
                          widget.onDelete(widget.facility.id);
                        }
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 15),
                      label: const Text('Delete', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        backgroundColor: const Color(0xFFFEF2F2),
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
          'ACTIVE PRICES',
          style: TextStyle(
            fontSize: 10.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        ...activePrices.map(
          (dp) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${_dayName(dp.startDay)}–${_dayName(dp.endDay)} ${_timeStr(dp.startTime)}–${_timeStr(dp.endTime)}',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${dp.price.toStringAsFixed(2)} KM',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
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

