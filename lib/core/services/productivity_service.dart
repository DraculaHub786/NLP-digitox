// Copyright (c) 2026 NLP digitox

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/models/habit_model.dart';
import 'package:nlp_digitox/models/task_model.dart';
import 'package:nlp_digitox/models/note_model.dart';

class ProductivityService {
  static const String _habitsKey = 'user_habits';
  static const String _tasksKey = 'user_tasks';
  static const String _notesKey = 'user_notes';

  static ProductivityService? _instance;
  static ProductivityService get instance {
    _instance ??= ProductivityService._();
    return _instance!;
  }

  ProductivityService._();

  // Habits Methods
  Future<List<HabitModel>> getHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString(_habitsKey);
      if (habitsJson == null) return [];

      final List<dynamic> decoded = jsonDecode(habitsJson);
      return decoded.map((json) => HabitModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading habits: $e');
      return [];
    }
  }

  Future<bool> saveHabits(List<HabitModel> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = jsonEncode(habits.map((h) => h.toJson()).toList());
      return await prefs.setString(_habitsKey, habitsJson);
    } catch (e) {
      debugPrint('Error saving habits: $e');
      return false;
    }
  }

  Future<bool> addHabit(HabitModel habit) async {
    final habits = await getHabits();
    habits.add(habit);
    return await saveHabits(habits);
  }

  Future<bool> updateHabit(HabitModel habit) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      habits[index] = habit;
      return await saveHabits(habits);
    }
    return false;
  }

  Future<bool> deleteHabit(String id) async {
    final habits = await getHabits();
    habits.removeWhere((h) => h.id == id);
    return await saveHabits(habits);
  }

  // Tasks Methods
  Future<List<TaskModel>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      if (tasksJson == null) return [];

      final List<dynamic> decoded = jsonDecode(tasksJson);
      return decoded.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return [];
    }
  }

  Future<bool> saveTasks(List<TaskModel> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
      return await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
      return false;
    }
  }

  Future<bool> addTask(TaskModel task) async {
    final tasks = await getTasks();
    tasks.add(task);
    return await saveTasks(tasks);
  }

  Future<bool> updateTask(TaskModel task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      return await saveTasks(tasks);
    }
    return false;
  }

  Future<bool> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    return await saveTasks(tasks);
  }

  // Notes Methods
  Future<List<NoteModel>> getNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_notesKey);
      if (notesJson == null) return [];

      final List<dynamic> decoded = jsonDecode(notesJson);
      return decoded.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading notes: $e');
      return [];
    }
  }

  Future<bool> saveNotes(List<NoteModel> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = jsonEncode(notes.map((n) => n.toJson()).toList());
      return await prefs.setString(_notesKey, notesJson);
    } catch (e) {
      debugPrint('Error saving notes: $e');
      return false;
    }
  }

  Future<bool> addNote(NoteModel note) async {
    final notes = await getNotes();
    notes.add(note);
    return await saveNotes(notes);
  }

  Future<bool> updateNote(NoteModel note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      return await saveNotes(notes);
    }
    return false;
  }

  Future<bool> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    return await saveNotes(notes);
  }
}
