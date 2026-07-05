import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/features/booking/booking_flow_notifier.dart';
import 'package:terminba_mobile/screens/reservation/reservation_summary_screen.dart';

class ReservationCreatePostStepScreen extends StatefulWidget {
  const ReservationCreatePostStepScreen({super.key});

  @override
  State<ReservationCreatePostStepScreen> createState() =>
      _ReservationCreatePostStepScreenState();
}

class _ReservationCreatePostStepScreenState
    extends State<ReservationCreatePostStepScreen> {
  static const _skillLevels = ['Beginner', 'Medium', 'Advance'];

  String? _selectedSkillLevel;
  final TextEditingController _descCtrl = TextEditingController();
  int _playersWanted = 1;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _onSkip(BookingFlowNotifier notifier) {
    notifier.setPostDetails(wantsToCreate: false);
    _goToNext(notifier);
  }

  void _onNext(BookingFlowNotifier notifier) {
    if (_selectedSkillLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a skill level or skip.')),
      );
      return;
    }

    notifier.setPostDetails(
      wantsToCreate: true,
      skillLevel: _selectedSkillLevel,
      text: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      playersWanted: _playersWanted,
    );
    _goToNext(notifier);
  }

  void _goToNext(BookingFlowNotifier notifier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: notifier,
          child: const ReservationSummaryScreen(),
        ),
      ),
    );
  }

  Future<bool> _showCancelDialog(BuildContext context, BookingFlowNotifier notifier) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Reservation?'),
          content: const Text('If you go back, your pending reservation will be canceled and the time slot will be freed up for others.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Keep Booking'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      await notifier.cancelPendingReservation();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingFlowNotifier>(
      builder: (context, notifier, _) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final shouldPop = await _showCancelDialog(context, notifier);
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Find Players (Optional)'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  final shouldPop = await _showCancelDialog(context, notifier);
                  if (shouldPop && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => _onSkip(notifier),
                  child: const Text('Skip', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Do you want to create a post to find players for this reservation?',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),

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
                      showCheckmark: false,
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
                    hintText: 'e.g. "Anyone up for a friendly match?"',
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
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: ElevatedButton(
                onPressed: () => _onNext(notifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Next →',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          ),
        );
      },
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
