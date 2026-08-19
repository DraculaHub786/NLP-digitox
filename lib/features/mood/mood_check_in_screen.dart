import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/common/pill_button.dart';
import 'package:nlp_digitox/ui/common/treated_background_image.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text('Mood Check-In'),
      ),
      body: TreatedBackgroundImage(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              elevation: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: DesignType.titleStyle(context, size: 22),
                  ),
                  const SizedBox(height: 20),
                  _buildMoodSelector(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              elevation: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Energy Level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  _buildSlider(
                    value: _energyLevel,
                    onChanged: (value) => setState(() => _energyLevel = value),
                    min: 1,
                    max: 10,
                    label: _energyLevel.toString(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Stress Level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  _buildSlider(
                    value: _stressLevel,
                    onChanged: (value) => setState(() => _stressLevel = value),
                    min: 1,
                    max: 10,
                    label: _stressLevel.toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              elevation: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What triggered this mood?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildTriggerChips(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Additional notes (optional)',
                      hintText: 'Any thoughts you want to record...',
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.xl),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.xl),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.xl),
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 1.5),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: PillButton(
                      label: 'Save Check-In',
                      onPressed: _selectedMood == null ? null : _saveMoodCheckIn,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    final colorScheme = Theme.of(context).colorScheme;
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
              color: isSelected
                  ? mood.color.withValues(alpha: 0.2)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(
                color: isSelected
                    ? mood.color
                    : colorScheme.outline.withValues(alpha: 0.18),
                width: isSelected ? 2 : 1,
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
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? mood.color
                        : colorScheme.onSurface.withValues(alpha: 0.75),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          'Low',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
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
        Text(
          'High',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonTriggers.map((trigger) {
        final isSelected = _selectedTriggers.contains(trigger);
        return FilterChip(
          label: Text(trigger),
          selected: isSelected,
          selectedColor: colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: colorScheme.primary,
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
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
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
        backgroundColor: (Theme.of(context).brightness == Brightness.dark ? DesignPalette.darkGlassFill : DesignPalette.lightGlassFill),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
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
