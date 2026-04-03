import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'focus_session_service.dart';
import 'white_noise_player.dart';

final focusSessionServiceProvider = ChangeNotifierProvider<FocusSessionService>((ref) {
  return FocusSessionService();
});

class FocusSessionScreen extends ConsumerStatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  ConsumerState<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends ConsumerState<FocusSessionScreen> {
  final WhiteNoisePlayer _whiteNoisePlayer = WhiteNoisePlayer();
  bool _isNoiseEnabled = false;

  @override
  void dispose() {
    _whiteNoisePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(focusSessionServiceProvider);
    final currentSession = service.currentSession;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Session'),
        actions: [
          if (currentSession != null && !currentSession.isCompleted)
            IconButton(
              icon: Icon(_isNoiseEnabled ? Icons.volume_up : Icons.volume_off),
              onPressed: () async {
                if (_isNoiseEnabled) {
                  await _whiteNoisePlayer.stop();
                } else {
                  await _whiteNoisePlayer.play();
                }
                setState(() => _isNoiseEnabled = !_isNoiseEnabled);
              },
            ),
        ],
      ),
      body: currentSession == null || currentSession.isCompleted
          ? _buildGoalSelection()
          : _buildActiveSession(currentSession),
    );
  }

  Widget _buildGoalSelection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Start a Focus Session',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Choose your goal and duration to begin'),
        const SizedBox(height: 24),
        _buildGoalCard(
          'Study Session',
          FocusGoalType.study,
          Icons.school,
          Colors.blue,
          'Deep focus for learning',
        ),
        _buildGoalCard(
          'Work Session',
          FocusGoalType.work,
          Icons.work,
          Colors.green,
          'Productive work time',
        ),
        _buildGoalCard(
          'Reading',
          FocusGoalType.read,
          Icons.book,
          Colors.orange,
          'Focused reading time',
        ),
        _buildGoalCard(
          'Meditation',
          FocusGoalType.meditation,
          Icons.spa,
          Colors.purple,
          'Mindful meditation',
        ),
        _buildGoalCard(
          'Exercise',
          FocusGoalType.exercise,
          Icons.fitness_center,
          Colors.red,
          'Physical activity',
        ),
        _buildGoalCard(
          'Creative Work',
          FocusGoalType.creative,
          Icons.palette,
          Colors.pink,
          'Creative expression',
        ),
      ],
    );
  }

  Widget _buildGoalCard(String title, FocusGoalType type, IconData icon, Color color, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showDurationPicker(title, type, color),
      ),
    );
  }

  void _showDurationPicker(String title, FocusGoalType type, Color color) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DurationPickerSheet(
        title: title,
        type: type,
        color: color,
        onStart: (goal) {
          Navigator.pop(context);
          ref.read(focusSessionServiceProvider).startSession(goal);
        },
      ),
    );
  }

  Widget _buildActiveSession(FocusSession session) {
    final progress = session.elapsed.inSeconds / session.goal.targetDuration.inSeconds;
    final remainingTime = session.goal.targetDuration - session.elapsed;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              session.goal.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(session.goal.color),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(remainingTime),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: session.goal.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'remaining',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            if (session.distractionCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Distractions: ${session.distractionCount}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ref.read(focusSessionServiceProvider).completeSession(),
                  icon: const Icon(Icons.check),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _confirmCancel(),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Session?'),
        content: const Text('Are you sure you want to cancel this focus session? Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Going'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(focusSessionServiceProvider).cancelSession();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Session'),
          ),
        ],
      ),
    );
  }
}

class _DurationPickerSheet extends StatefulWidget {
  final String title;
  final FocusGoalType type;
  final Color color;
  final Function(FocusGoal) onStart;

  const _DurationPickerSheet({
    required this.title,
    required this.type,
    required this.color,
    required this.onStart,
  });

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  int _selectedMinutes = 25;
  final List<int> _durations = [15, 25, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Set Duration for ${widget.title}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _durations.map((minutes) {
              final isSelected = minutes == _selectedMinutes;
              return ChoiceChip(
                label: Text('$minutes min'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedMinutes = minutes);
                },
                selectedColor: widget.color.withOpacity(0.3),
                labelStyle: TextStyle(
                  color: isSelected ? widget.color : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final goal = FocusGoal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: widget.title,
                  type: widget.type,
                  targetDuration: Duration(minutes: _selectedMinutes),
                  createdAt: DateTime.now(),
                  color: widget.color,
                );
                widget.onStart(goal);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start Session', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
