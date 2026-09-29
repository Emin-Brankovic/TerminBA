import 'package:flutter/material.dart';
import 'package:terminba_admin_desktop/enums/day_of_week_enum.dart';
import 'package:terminba_admin_desktop/model/sport_center.dart';
import 'package:terminba_admin_desktop/model/working_hours.dart';
import 'package:terminba_admin_desktop/screens/sport_center_insert_screen.dart';
import 'package:terminba_admin_desktop/widgets/confirmation_dialog.dart';

class SportCenterCard extends StatefulWidget {
  const SportCenterCard({
    super.key,
    required this.sportCenter,
    required this.onDelete,
    required this.onRefresh,
  });

  final SportCenter sportCenter;
  final Function(int id) onDelete;
  final VoidCallback onRefresh;

  @override
  State<SportCenterCard> createState() => _SportCenterCardState();
}

class _SportCenterCardState extends State<SportCenterCard> {
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
              height: 140,
              width: double.infinity,
              child: _buildPhoto(),
            ),

            // 2. Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sportCenter.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.sportCenter.city?.name != null)
                      Text(
                        widget.sportCenter.city!.name,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIconRow(Icons.location_on, widget.sportCenter.address),
                            _buildIconRow(Icons.phone, widget.sportCenter.phoneNumber),
                            if ((widget.sportCenter.contactEmail ?? '').trim().isNotEmpty)
                              _buildIconRow(Icons.email, widget.sportCenter.contactEmail!.trim()),
                            if (widget.sportCenter.workingHours.isNotEmpty)
                              _buildWorkingHoursCompact(widget.sportCenter.workingHours),
                            if (widget.sportCenter.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.sportCenter.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                            const SizedBox(height: 8),
                            _buildTags(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 3. Action Buttons Section
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SportCenterInsertScreen(
                                    sportCenter: widget.sportCenter,
                                  ),
                                ),
                              );
                              widget.onRefresh();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853), // Green
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Edit', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final confirmed = await ConfirmationDialog.show(
                                context,
                                title: 'Delete Sport Center',
                                message: 'Are you sure you want to delete this sport center? This action cannot be undone.',
                                confirmText: 'Delete',
                                cancelText: 'Cancel',
                                confirmButtonColor: const Color(0xFFFF3D00),
                              );

                              if (confirmed) {
                                widget.onDelete(widget.sportCenter.id);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3D00), // Red/Orange
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Delete', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayName(DayOfWeek d) => d.name[0].toUpperCase() + d.name.substring(1);

  String _timeStr(String t) => t.length >= 5 ? t.substring(0, 5) : t;

  Widget _buildIconRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursCompact(List<WorkingHours> hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: hours.map((wh) {
                return Text(
                  '${_dayName(wh.startDay)} – ${_dayName(wh.endDay)}: ${_timeStr(wh.openingHours)} – ${_timeStr(wh.closeingHours)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    final List<Widget> sections = [];

    if (widget.sportCenter.isEquipmentProvided) {
      sections.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: _buildTag('Equipment Provided', Colors.green.shade50, Colors.green.shade700),
        ),
      );
    }

    final sportsTags = widget.sportCenter.availableSports
        .where((s) => s.name?.isNotEmpty ?? false)
        .map((s) => _buildTag(s.name!, Colors.blue.shade50, Colors.blue.shade700))
        .toList();
    if (sportsTags.isNotEmpty) {
      sections.add(_buildTagSection('Sports', Icons.sports, sportsTags));
    }

    final amenitiesTags = widget.sportCenter.availableAmenities
        .where((a) => a.name.isNotEmpty)
        .map((a) => _buildTag(a.name, Colors.orange.shade50, Colors.orange.shade800))
        .toList();
    if (amenitiesTags.isNotEmpty) {
      sections.add(_buildTagSection('Amenities', Icons.star_border, amenitiesTags));
    }

    if (sections.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  Widget _buildTagSection(String title, IconData icon, List<Widget> tags) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: tags,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w600),
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
    if (widget.sportCenter.photos.isEmpty) {
      return const [];
    }

    return widget.sportCenter.photos.where((p) => (p.url?.isNotEmpty ?? false)).map((p) => p.url!).toList();
  }
}

