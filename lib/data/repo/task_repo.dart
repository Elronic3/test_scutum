import 'dart:convert'; // jsonDecode
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scutum/data/models/task_model.dart';
import 'package:scutum/core/constants/app_constants.dart';

/// Storing tasks in local storage using SharedPreferences
class TaskRepo {
  final SharedPreferences _prefs;

  TaskRepo(this._prefs);

  /// Getting list of tasks from storage
  List<TaskModel> getTasks() {
    /// Receiving list of JSON or null
    final List<String>? tasksJson = _prefs.getStringList(
      AppConstants.taskStorageKey,
    );
    if (tasksJson == null) return [];

    // Mapping JSON to Task
    return tasksJson
        .map((str) => TaskModel.fromJson(json.decode(str)))
        .toList();
  }

  /// Saving list of tasks to storage, overwriting previous list
  Future<void> _saveTasks(List<TaskModel> tasks) async {
    final List<String> tasksJson = tasks
        .map((task) => json.encode(task.toJson()))
        .toList();
    // Saving to storage
    await _prefs.setStringList(AppConstants.taskStorageKey, tasksJson);
  }

  /// Adding new task and saving
  Future<void> addTask(TaskModel task) async {
    final tasks = getTasks();
    tasks.add(task);
    await _saveTasks(tasks);
  }

  /// Removing task by ID and saving
  Future<void> deleteTask(String id) async {
    final tasks = getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _saveTasks(tasks);
  }

  /// Updating existing task
  Future<void> updateTask(TaskModel updatedTask) async {
    final tasks = getTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);

    if (index != -1) {
      tasks[index] = updatedTask;
      await _saveTasks(tasks);
    }
  }
}
