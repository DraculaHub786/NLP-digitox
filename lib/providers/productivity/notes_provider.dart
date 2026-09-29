// Copyright (c) 2026 NLP digitox

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/models/note_model.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';

class NotesNotifier extends StateNotifier<AsyncValue<List<NoteModel>>> {
  NotesNotifier() : super(const AsyncValue.loading()) {
    loadNotes();
  }

  final _service = ProductivityService.instance;

  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    try {
      final notes = await _service.getNotes();
      state = AsyncValue.data(notes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addNote(NoteModel note) async {
    await _service.addNote(note);
    await loadNotes();
  }

  Future<void> updateNote(NoteModel note) async {
    await _service.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _service.deleteNote(id);
    await loadNotes();
  }
}

final notesProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<NoteModel>>>((ref) {
  return NotesNotifier();
});
