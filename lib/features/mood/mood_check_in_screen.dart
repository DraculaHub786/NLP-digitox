import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'mood_service.dart';

final moodServiceProvider = ChangeNotifierProvider<MoodService>((ref) {
  return MoodService();
});

class MoodCheckInScreen extends ConsumerStatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  ConsumerState<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends ConsumerState<MoodCheckInScreen> {
  MoodType? _selectedMood;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedTriggers = [];
  int _energyLevel = 5;
  int _stressLevel = 5;

  final List<String> _commonTriggers = [
    'Work',
    'Social Media',
    'News',
    'Relationships',
    'Health',
    'Money',
    'Sleep',
    'Weather',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Check-In'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'How are you feeling?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildMoodSelector(),
          const SizedBox(height: 32),
          const Text(
            'Energy Level',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildSlider(
            value: _energyLevel,
            onChanged: (value) => setState(() => _energyLevel = value),
            min: 1,
            max: 10,
            label: _energyLevel.toString(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Stress Level',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildSlider(
            value: _stressLevel,
            onChanged: (value) => setState(() => _stressLevel = value),
            min: 1,
            max: 10,
            label: _stressLevel.toString(),
          ),
          const SizedBox(height: 24),
          const Text(
            'What triggered this mood?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildTriggerChips(),
          const SizedBox(height: 24),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Additional notes (optional)',
              border: OutlineInputBorder(),
              hintText: 'Any thoughts you want to record...',
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMood == null ? null : _saveMoodCheckIn,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Check-In', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: MoodType.values.map((mood) {
        final isSelected = _selectedMood == mood;
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood),
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? mood.color.withOpacity(0.2) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? mood.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(
                  mood.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? mood.color : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlider({
    required int value,
    required ValueChanged<int> onChanged,
    required int min,
    required int max,
    required String label,
  }) {
    return Row(
      children: [
        Text('Low', style: TextStyle(color: Colors.grey.shade600)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: label,
            onChanged: (newValue) => onChanged(newValue.toInt()),
          ),
        ),
        Text('High', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(width: 8),
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTriggerChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonTriggers.map((trigger) {
        final isSelected = _selectedTriggers.contains(trigger);
        return FilterChip(
          label: Text(trigger),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTriggers.add(trigger);
              } else {
                _selectedTriggers.remove(trigger);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> _saveMoodCheckIn() async {
    if (_selectedMood == null) return;

    final moodService = ref.read(moodServiceProvider);
    await moodService.recordMoodCheckIn(
      mood: _selectedMood!,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      triggers: _selectedTriggers,
      energyLevel: _energyLevel,
      stressLevel: _stressLevel,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood check-in saved!')),
      );

      // Show interventions if needed
      final interventions = moodService.getSuggestedInterventions();
      if (interventions.isNotEmpty) {
        _showInterventionDialog(interventions);
      } else {
        Navigator.pop(context);
      }
    }
  }

  void _showInterventionDialog(List<String> interventions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Helpful Suggestions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: interventions
              .map((intervention) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(child: Text(intervention)),
                      ],
                    ),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
