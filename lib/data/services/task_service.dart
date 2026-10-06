import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:tudee/data/models/task.dart';
import 'package:tudee/data/services/local_storage_service.dart';

/// Persists tasks in a Hive box. Each entry is a map holding the owner's
/// name, the task title and its done state, keyed by an auto-increment id.
///
/// [Hive.initFlutter] must be called before [init].
class TaskService {
  static const _boxName = 'tasks';

  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  @visibleForTesting
  static set box(Box value) => _box = value;

  static List<Task> getTasks(String userName) {
    return [
      for (final entry in _box.toMap().entries)
        if (entry.value['userName'] == userName)
          Task(
            key: entry.key as int,
            title: entry.value['title'] as String,
            isDone: entry.value['isDone'] as bool,
          ),
    ];
  }

  static Future<void> addTask(String userName, String title) {
    return _box.add({'userName': userName, 'title': title, 'isDone': false});
  }

  static Future<void> updateTitle(int key, String title) {
    return _box.put(key, {..._box.get(key), 'title': title});
  }

  static Future<void> toggleDone(int key) {
    final task = _box.get(key);
    return _box.put(key, {...task, 'isDone': !(task['isDone'] as bool)});
  }

  /// Moves tasks saved by older versions (JSON in shared_preferences) into
  /// Hive. Returns whether anything was migrated.
  static Future<bool> migrateFromPrefs(String userName) async {
    final prefsKey = 'tasks_$userName';
    final oldJson = LocalStorageService.getString(prefsKey);
    if (oldJson == null) return false;

    for (final item in jsonDecode(oldJson) as List<dynamic>) {
      await _box.add({
        'userName': userName,
        'title': item['title'],
        'isDone': item['isDone'] == true,
      });
    }
    await LocalStorageService.remove(prefsKey);
    return true;
  }
}
