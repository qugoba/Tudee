import 'dart:async';

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
  List<Task> _tasks = const [];
  StreamSubscription<List<Task>>? _subscription;

  int get _doneCount => _tasks.where((t) => t.isDone).length;
  int get _todoCount => _tasks.length - _doneCount;

  @override
  void initState() {
    super.initState();
    _subscription = TaskService.watchTasks(widget.userName).listen((tasks) {
      if (mounted) setState(() => _tasks = tasks);
    });
    unawaited(TaskService.migrateFromPrefs(widget.userName));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
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

    unawaited(TaskService.addTask(widget.userName, title));
  }

  Future<void> _editTask(Task task) async {
    final title = await _askForTitle(initialTitle: task.title);
    if (title == null) return;

    unawaited(TaskService.updateTitle(task.id, title));
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(task.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    unawaited(TaskService.deleteTask(task.id));
  }

  void _toggleTask(Task task) {
    unawaited(TaskService.setDone(task.id, isDone: !task.isDone));
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
                    onDelete: () => _deleteTask(task),
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
