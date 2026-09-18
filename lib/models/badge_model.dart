// Model for a badge earned by a user in the leaderboard.
// Stored in `leaderboard/{uid}/badges/{docId}`.
import 'package:cloud_firestore/cloud_firestore.dart';

class Badge {
  final String id;
  final String title;
  final String imageUrl;
  final String period; // 'weekly' or 'monthly'
  final String cycleLabel;
  final String verificationId;
  final DateTime earnedAt;

  const Badge({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.period,
    required this.cycleLabel,
    required this.verificationId,
    required this.earnedAt,
  });

  factory Badge.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Badge(
      id: documentId,
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      period: data['period'] as String? ?? '',
      cycleLabel: data['cycleLabel'] as String? ?? '',
      verificationId: data['verificationId'] as String? ?? '',
      earnedAt: (data['earnedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'period': period,
      'cycleLabel': cycleLabel,
      'verificationId': verificationId,
      'earnedAt': Timestamp.fromDate(earnedAt),
    };
  }

  /// Returns a display-friendly period label (e.g., "Week 37, 2026" or "September 2026").
  String get displayPeriodLabel {
    if (period == 'weekly') {
      // cycleLabel format: "2026-W37"
      return 'Week $cycleLabel';
    } else {
      // cycleLabel format: "2026-09"
      final parts = cycleLabel.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final month = int.tryParse(parts[1]) ?? 1;
        final monthNames = [
          '', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        return '${monthNames[month]} $year';
      }
      return cycleLabel;
    }
  }
}