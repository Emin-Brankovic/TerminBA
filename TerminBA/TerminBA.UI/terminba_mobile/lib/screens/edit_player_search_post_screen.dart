import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terminba_mobile/model/post_response.dart';
import 'package:terminba_mobile/providers/post_provider.dart';

class EditPlayerSearchPostScreen extends StatefulWidget {
  final PostResponse post;

  const EditPlayerSearchPostScreen({super.key, required this.post});

  @override
  State<EditPlayerSearchPostScreen> createState() =>
      _EditPlayerSearchPostScreenState();
}

class _EditPlayerSearchPostScreenState extends State<EditPlayerSearchPostScreen> {
  static const _skillLevels = ['Beginner', 'Medium', 'Advance'];

  String? _selectedSkillLevel;
  late TextEditingController _descCtrl;
  int _playersWanted = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing post details
    _selectedSkillLevel = widget.post.skillLevel?.capitalizeFirstLetter();
    if (!_skillLevels.contains(_selectedSkillLevel)) {
      _selectedSkillLevel = null;
    }
    _descCtrl = TextEditingController(text: widget.post.text ?? '');
    _playersWanted = widget.post.numberOfPlayersWanted ?? 1;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_selectedSkillLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a skill level.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final req = {
        'SkillLevel': _selectedSkillLevel,
        'Text': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'NumberOfPlayersWanted': _playersWanted,
      };

      await context.read<PostProvider>().update(widget.post.id, req);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true indicating success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            onPressed: _isSubmitting ? null : _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
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
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
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

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
