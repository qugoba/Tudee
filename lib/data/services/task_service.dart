import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tudee/data/models/task.dart';
import 'package:tudee/data/services/local_storage_service.dart';

class TaskService {
  static const _collectionName = 'tasks';

  static FirebaseFirestore? _firestore;

  @visibleForTesting
  static set firestore(FirebaseFirestore value) => _firestore = value;

  static CollectionReference<Map<String, dynamic>> get _tasks =>
      (_firestore ?? FirebaseFirestore.instance).collection(_collectionName);

  static Stream<List<Task>> watchTasks(String userName) {
    return _tasks.where('userName', isEqualTo: userName).snapshots().map((
      snapshot,
    ) {
      final docs = [...snapshot.docs]
        ..sort((a, b) => _createdAt(a).compareTo(_createdAt(b)));
      return [
        for (final doc in docs)
          Task(
            id: doc.id,
            title: doc['title'] as String,
            isDone: doc['isDone'] as bool,
          ),
      ];
    });
  }

  static DateTime _createdAt(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final value = doc.data()['createdAt'];
    return value is Timestamp ? value.toDate() : DateTime.now();
  }

  static Future<void> addTask(
    String userName,
    String title, {
    bool isDone = false,
  }) {
    return _tasks.add({
      'userName': userName,
      'title': title,
      'isDone': isDone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateTitle(String id, String title) {
    return _tasks.doc(id).update({'title': title});
  }

  static Future<void> deleteTask(String id) {
    return _tasks.doc(id).delete();
  }

  static Future<void> setDone(String id, {required bool isDone}) {
    return _tasks.doc(id).update({'isDone': isDone});
  }

  static Future<bool> migrateFromPrefs(String userName) async {
    final prefsKey = 'tasks_$userName';
    final oldJson = LocalStorageService.getString(prefsKey);
    if (oldJson == null) return false;

    for (final item in jsonDecode(oldJson) as List<dynamic>) {
      await addTask(
        userName,
        item['title'] as String,
        isDone: item['isDone'] == true,
      );
    }
    await LocalStorageService.remove(prefsKey);
    return true;
  }
}
