import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/constants/app_icons.dart';

@immutable
class NoteModel {
  final String id;
  final String title;
  final String content;
  final Color color;
  final IconData icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'colorValue': color.toARGB32(),
      'iconKey': iconKeyOf(icon) ?? 'note_note', // safe default key
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      color: Color(json['colorValue'] as int),
      // New format: 'iconKey' (String). Old format: 'iconCodePoint' (int) —
      // migrated on first load, see Step 3. Once every install has re-saved
      // at least once, the codePoint branch can be deleted.
      icon: json['iconKey'] != null
          ? iconFromKey(json['iconKey'] as String)
          : _legacyIconFromCodePoint(json['iconCodePoint'] as int?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }
}

/// Migration shim for notes saved before icons were stored by key. The
/// stored value is the Fluent glyph codePoint, so it can be matched back to
/// the exact icon the user picked (see [iconFromLegacyCodePoint]). Only if
/// the glyph is no longer in the picker do we fall back to the picker's
/// first option.
IconData _legacyIconFromCodePoint(int? codePoint) {
  return iconFromLegacyCodePoint(
    codePoint,
    fallback: iconFromKey('note_note'),
  );
}
