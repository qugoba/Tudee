import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudee/data/models/task.dart';
import 'package:tudee/data/services/local_storage_service.dart';
import 'package:tudee/data/services/task_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    TaskService.firestore = FakeFirebaseFirestore();
  });

  Future<List<Task>> tasksOf(String userName) {
    return TaskService.watchTasks(userName).first;
  }

  test('addTask stores a not-done task for the user', () async {
    await TaskService.addTask('Sara', 'Buy milk');

    final tasks = await tasksOf('Sara');
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Buy milk');
    expect(tasks.single.isDone, isFalse);
  });

  test('watchTasks only returns tasks of the given user', () async {
    await TaskService.addTask('Sara', 'Buy milk');
    await TaskService.addTask('Omar', 'Walk the dog');

    expect((await tasksOf('Sara')).single.title, 'Buy milk');
    expect((await tasksOf('Omar')).single.title, 'Walk the dog');
    expect(await tasksOf('Nobody'), isEmpty);
  });

  test('updateTitle changes the title and keeps the done state', () async {
    await TaskService.addTask('Sara', 'Buy milk');
    final task = (await tasksOf('Sara')).single;
    await TaskService.setDone(task.id, isDone: true);

    await TaskService.updateTitle(task.id, 'Buy bread');

    final updated = (await tasksOf('Sara')).single;
    expect(updated.title, 'Buy bread');
    expect(updated.isDone, isTrue);
  });

  test('setDone changes the done state', () async {
    await TaskService.addTask('Sara', 'Buy milk');
    final id = (await tasksOf('Sara')).single.id;

    await TaskService.setDone(id, isDone: true);
    expect((await tasksOf('Sara')).single.isDone, isTrue);

    await TaskService.setDone(id, isDone: false);
    expect((await tasksOf('Sara')).single.isDone, isFalse);
  });

  test('deleteTask removes the task', () async {
    await TaskService.addTask('Sara', 'Buy milk');
    final id = (await tasksOf('Sara')).single.id;

    await TaskService.deleteTask(id);

    expect(await tasksOf('Sara'), isEmpty);
  });

  group('migrateFromPrefs', () {
    test('moves old shared_preferences tasks into Firestore', () async {
      SharedPreferences.setMockInitialValues({
        'tasks_Sara':
            '[{"title":"Old task","isDone":true},{"title":"Other","isDone":false}]',
      });
      await LocalStorageService.init();

      final migrated = await TaskService.migrateFromPrefs('Sara');

      expect(migrated, isTrue);
      final tasks = await tasksOf('Sara');
      expect(tasks.map((t) => t.title), unorderedEquals(['Old task', 'Other']));
      expect(tasks.where((t) => t.isDone).single.title, 'Old task');
      expect(LocalStorageService.getString('tasks_Sara'), isNull);
    });

    test('does nothing when there are no old tasks', () async {
      expect(await TaskService.migrateFromPrefs('Sara'), isFalse);
      expect(await tasksOf('Sara'), isEmpty);
    });
  });
}
