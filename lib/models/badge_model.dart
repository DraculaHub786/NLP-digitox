// Model for a badge earned by a user in the leaderboard.
// Stored in `badges/{uid}_{period}_{cycle}`, written by n8n.
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
      earnedAt: _asDate(data['earnedAt']),
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

  /// Returns a display-friendly period label (e.g., "Week 37, 2026" or
  /// "September 2026").
  String get displayPeriodLabel {
    if (period == 'weekly') {
      // cycleLabel format: "2026-W37" — ISO week-year and ISO week number,
      // exactly what n8n writes with Luxon's `kkkk-'W'WW`. Rendered as a
      // readable label rather than echoing the raw id.
      final match = RegExp(r'^(\d{4})-W(\d{2})$').firstMatch(cycleLabel);
      if (match != null) {
        return 'Week ${int.parse(match.group(2)!)}, ${match.group(1)}';
      }
      return cycleLabel;
    } else {
      // cycleLabel format: "2026-09"
      final parts = cycleLabel.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final month = int.tryParse(parts[1]) ?? 1;
        final safeMonth = (month >= 1 && month <= 12) ? month : 1;
        final monthNames = [
          '', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        return '${monthNames[safeMonth]} $year';
      }
      return cycleLabel;
    }
  }
}

/// Reads an `earnedAt` value in whatever shape it arrived — a Firestore
/// [Timestamp], a [DateTime], an epoch-milliseconds `int` or an ISO [String].
/// Anything unreadable falls back to "now" so a badge is never dropped just
/// because its timestamp was written oddly.
DateTime _asDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
