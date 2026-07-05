import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/post_insert_request.dart';
import 'package:terminba_mobile/model/reservation_response.dart';
import 'package:terminba_mobile/providers/post_provider.dart';

/// Screen for creating a player-search post linked to an existing reservation.
class CreatePlayerSearchPostScreen extends StatefulWidget {
  final ReservationResponse reservation;

  const CreatePlayerSearchPostScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<CreatePlayerSearchPostScreen> createState() =>
      _CreatePlayerSearchPostScreenState();
}

class _CreatePlayerSearchPostScreenState
    extends State<CreatePlayerSearchPostScreen> {
  static const _skillLevels = ['Beginner', 'Medium', 'Advance'];

  String? _selectedSkillLevel;
  final TextEditingController _descCtrl = TextEditingController();
  int _playersWanted = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return '—';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return d;
    }
  }

  String _formatTime(String? t) {
    if (t == null || t.isEmpty) return '—';
    return t.length >= 5 ? t.substring(0, 5) : t;
  }

  Future<void> _submit() async {
    if (_selectedSkillLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a skill level.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final req = PostInsertRequest(
        skillLevel: _selectedSkillLevel!,
        text: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        reservationId: widget.reservation.id,
        numberOfPlayersWanted: _playersWanted,
      );

      await context.read<PostProvider>().insert(req.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created! Players can now find you.'),
            backgroundColor: Color(0xFF00C875),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.reservation;
    final facility = res.facility;
    final sport = res.chosenSport;
    final city = facility?.sportCenter?.city?.name ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Players'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Reservation summary card ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C875).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.sports,
                          color: Color(0xFF00C875),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility?.name ?? 'Facility',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              city,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  _InfoRow(icon: Icons.sports_soccer_outlined,
                      label: 'Sport', value: sport?.name ?? '—'),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.calendar_today_outlined,
                      label: 'Date', value: _formatDate(res.reservationDate)),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value:
                        '${_formatTime(res.startTime)} – ${_formatTime(res.endTime)}',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.attach_money_outlined,
                    label: 'Cost',
                    value:
                        res.price != null ? '${res.price!.toStringAsFixed(2)} BAM' : '—',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- Players wanted stepper ---
            const Text(
              'Players Wanted',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _CounterButton(
                  icon: Icons.remove,
                  onTap: _playersWanted > 1
                      ? () => setState(() => _playersWanted--)
                      : null,
                ),
                const SizedBox(width: 16),
                Text(
                  '$_playersWanted',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                _CounterButton(
                  icon: Icons.add,
                  onTap: _playersWanted < 20
                      ? () => setState(() => _playersWanted++)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Skill level ---
            const Text(
              'Skill Level',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _skillLevels.map((level) {
                final selected = _selectedSkillLevel == level;
                return ChoiceChip(
                  label: Text(level),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedSkillLevel = level),
                  selectedColor: const Color(0xFF00C875),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF00C875)
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // --- Description ---
            const Text(
              'Description (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'e.g. "Anyone up for a friendly 5v5 this weekend?"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF00C875), width: 1.5),
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // --- Sticky Post button ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C875),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Post',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFF00C875).withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onTap != null
                ? const Color(0xFF00C875).withOpacity(0.4)
                : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? const Color(0xFF00C875) : Colors.grey.shade400,
        ),
      ),
    );
  }
}
