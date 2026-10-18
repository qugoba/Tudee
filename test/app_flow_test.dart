import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudee/data/services/local_storage_service.dart';
import 'package:tudee/main.dart';
import 'package:tudee/data/services/task_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    TaskService.firestore = FakeFirebaseFirestore();
  });

  testWidgets('shows the welcome screen when no name is saved', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text("Let's get started"), findsOneWidget);
  });

  testWidgets('shows the home screen when a name is saved', (tester) async {
    await tester.pumpWidget(const MyApp(userName: 'Sara'));

    expect(find.text('Welcome Sara'), findsOneWidget);
    expect(find.text('No tasks for today!'), findsOneWidget);
  });

  testWidgets('saves the entered name and opens the home screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), '  Sara ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Sara'), findsOneWidget);
    expect(LocalStorageService.getUserName(), 'Sara');
  });

  testWidgets('does not continue when the name is empty', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text("Let's get started"), findsOneWidget);
    expect(LocalStorageService.getUserName(), isNull);
  });

  testWidgets('adds, edits and completes a task', (tester) async {
    await tester.pumpWidget(const MyApp(userName: 'Sara'));


    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add Task'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('TODO'), findsOneWidget);


    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Buy milk'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Buy bread');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Buy milk'), findsNothing);
    expect(find.text('Buy bread'), findsOneWidget);


    await tester.tap(find.text('Buy bread'));
    await tester.pumpAndSettle();
    expect(find.text('TODO'), findsNothing);
    expect(find.text('Done'), findsNWidgets(2));
  });

  testWidgets('deletes a task after confirming', (tester) async {
    await TaskService.addTask('Sara', 'Buy milk');
    await tester.pumpWidget(const MyApp(userName: 'Sara'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Buy milk'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Buy milk'), findsNothing);
    expect(find.text('No tasks for today!'), findsOneWidget);
  });

  testWidgets('logging out clears the name and returns to welcome', (
    tester,
  ) async {
    await LocalStorageService.saveUserName('Sara');
    await tester.pumpWidget(const MyApp(userName: 'Sara'));

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text("Let's get started"), findsOneWidget);
    expect(LocalStorageService.getUserName(), isNull);
  });
}
