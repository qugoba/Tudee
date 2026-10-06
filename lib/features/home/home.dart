import 'package:flutter/material.dart';
import 'package:tudee/core/widgets/tudee_app_bar.dart';
import 'package:tudee/data/models/task.dart';
import 'package:tudee/data/services/local_storage_service.dart';
import 'package:tudee/data/services/task_service.dart';
import 'package:tudee/features/home/widgets/empty_tasks_card.dart';
import 'package:tudee/features/home/widgets/summary_card.dart';
import 'package:tudee/features/home/widgets/task_card.dart';
import 'package:tudee/features/task_form/task_form.dart';
import 'package:tudee/features/welcome/welcome.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Task> _tasks = TaskService.getTasks(widget.userName);

  int get _doneCount => _tasks.where((t) => t.isDone).length;
  int get _todoCount => _tasks.length - _doneCount;

  @override
  void initState() {
    super.initState();
    _migrateOldTasks();
  }

  Future<void> _migrateOldTasks() async {
    final migrated = await TaskService.migrateFromPrefs(widget.userName);
    if (migrated) _reloadTasks();
  }

  void _reloadTasks() {
    if (!mounted) return;
    setState(() => _tasks = TaskService.getTasks(widget.userName));
  }

  Future<String?> _askForTitle({String? initialTitle}) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(initialTitle: initialTitle),
      ),
    );
  }

  Future<void> _addTask() async {
    final title = await _askForTitle();
    if (title == null) return;

    await TaskService.addTask(widget.userName, title);
    _reloadTasks();
  }

  Future<void> _editTask(Task task) async {
    final title = await _askForTitle(initialTitle: task.title);
    if (title == null) return;

    await TaskService.updateTitle(task.key, title);
    _reloadTasks();
  }

  Future<void> _toggleTask(Task task) async {
    await TaskService.toggleDone(task.key);
    _reloadTasks();
  }

  Future<void> _logout() async {
    await LocalStorageService.removeUserName();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Welcome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TudeeAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SummaryCard(
              userName: widget.userName,
              doneCount: _doneCount,
              todoCount: _todoCount,
            ),
            const SizedBox(height: 24),
            if (_tasks.isEmpty)
              const EmptyTasksCard()
            else
              for (final task in _tasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TaskCard(
                    task: task,
                    onToggle: () => _toggleTask(task),
                    onEdit: () => _editTask(task),
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add task',
        child: const Icon(Icons.add_task),
      ),
    );
  }
}
