import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudee/data/services/local_storage_service.dart';
import 'package:tudee/data/services/task_service.dart';

void main() {
  late Box box;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    box = await Hive.openBox('tasks_test', bytes: Uint8List(0));
    TaskService.box = box;
  });

  tearDown(() async {
    await box.close();
  });

  test('addTask stores a not-done task for the user', () async {
    await TaskService.addTask('Sara', 'Buy milk');

    final tasks = TaskService.getTasks('Sara');
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Buy milk');
    expect(tasks.single.isDone, isFalse);
  });

  test('getTasks only returns tasks of the given user', () async {
    await TaskService.addTask('Sara', 'Buy milk');
    await TaskService.addTask('Omar', 'Walk the dog');

    expect(TaskService.getTasks('Sara').single.title, 'Buy milk');
    expect(TaskService.getTasks('Omar').single.title, 'Walk the dog');
    expect(TaskService.getTasks('Nobody'), isEmpty);
  });

  test('updateTitle changes the title and keeps the done state', () async {
    await TaskService.addTask('Sara', 'Buy milk');
    final task = TaskService.getTasks('Sara').single;
    await TaskService.toggleDone(task.key);

    await TaskService.updateTitle(task.key, 'Buy bread');

    final updated = TaskService.getTasks('Sara').single;
    expect(updated.title, 'Buy bread');
    expect(updated.isDone, isTrue);
  });

  test('toggleDone flips the done state', () async {
    await TaskService.addTask('Sara', 'Buy milk');
    final key = TaskService.getTasks('Sara').single.key;

    await TaskService.toggleDone(key);
    expect(TaskService.getTasks('Sara').single.isDone, isTrue);

    await TaskService.toggleDone(key);
    expect(TaskService.getTasks('Sara').single.isDone, isFalse);
  });

  group('migrateFromPrefs', () {
    test('moves old shared_preferences tasks into Hive', () async {
      SharedPreferences.setMockInitialValues({
        'tasks_Sara':
            '[{"title":"Old task","isDone":true},{"title":"Other","isDone":false}]',
      });
      await LocalStorageService.init();

      final migrated = await TaskService.migrateFromPrefs('Sara');

      expect(migrated, isTrue);
      final tasks = TaskService.getTasks('Sara');
      expect(tasks.map((t) => t.title), ['Old task', 'Other']);
      expect(tasks.map((t) => t.isDone), [true, false]);
      expect(LocalStorageService.getString('tasks_Sara'), isNull);
    });

    test('does nothing when there are no old tasks', () async {
      expect(await TaskService.migrateFromPrefs('Sara'), isFalse);
      expect(TaskService.getTasks('Sara'), isEmpty);
    });
  });
}
