# Tudee

A simple to-do app built with Flutter.

## Features

- Enter your name once; it is remembered between launches.
- Add tasks, edit their title, and tap a task to mark it Done / TODO.
- Summary card with the number of done and pending tasks.
- Log out to switch to another name. Tasks are kept per name.

## Storage

| Data       | Storage                                                                  |
| ---------- | ------------------------------------------------------------------------ |
| User name  | [`shared_preferences`](https://pub.dev/packages/shared_preferences)      |
| Tasks      | [`hive`](https://pub.dev/packages/hive)                                  |

Tasks saved by older versions in `shared_preferences` are migrated to Hive
automatically the first time the home screen opens.

## Project structure

```
lib/
  main.dart                          App entry, storage initialisation
  core/
    theme/app_theme.dart             Colors and the shared Material theme
    widgets/tudee_app_bar.dart       App bar used by every screen
  data/
    models/task.dart                 Task model
    services/
      local_storage_service.dart     User name storage (shared_preferences)
      task_service.dart              Task storage (Hive)
  features/
    welcome/welcome.dart             Name entry screen
    home/
      home.dart                      Task list screen and its logic
      widgets/                       summary_card, task_card, empty_tasks_card
    task_form/task_form.dart         Add / edit task screen
```

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter analyze
flutter test
```
