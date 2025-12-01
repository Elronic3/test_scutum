import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scutum/data/models/task_model.dart';
import 'package:scutum/data/repo/task_repo.dart';

enum TaskFilter { all, completed, notCompleted }

/// - Events -
abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskModel task;
  AddTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String id;
  DeleteTask(this.id);
}

class ToggleTask extends TaskEvent {
  final TaskModel task;
  ToggleTask(this.task);
}

class FilterTasks extends TaskEvent {
  final TaskFilter filter;
  FilterTasks(this.filter);
}

/// - States -
abstract class TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> allTasks; // Keeping the full list in memory
  final List<TaskModel> filteredTasks; // Showed list
  final TaskFilter activeFilter; // Current filter setting

  TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.activeFilter = TaskFilter.all,
  });
}

/// - BLoC -
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepo repo;

  TaskBloc(this.repo) : super(TaskLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTask>(_onToggleTask);
    on<FilterTasks>(_onFilterTasks);
  }

  // Handler for initial loading
  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    // Load from SharedPreferences
    final tasks = repo.getTasks();
    final TaskFilter currentFilter = state is TaskLoaded
        ? (state as TaskLoaded).activeFilter
        : TaskFilter.all;

    final filtered = _applyFilter(tasks, currentFilter);

    // Emit loaded state showing all tasks
    emit(
      TaskLoaded(
        allTasks: tasks,
        filteredTasks: filtered,
        activeFilter: currentFilter,
      ),
    );
  }

  // Handler for adding task
  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    await repo.addTask(event.task);
    add(LoadTasks());
  }

  // Handler for deleting task
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    await repo.deleteTask(event.id);
    add(LoadTasks());
  }

  // Handler for checking task
  Future<void> _onToggleTask(ToggleTask event, Emitter<TaskState> emit) async {
    final updated = event.task.copyWith(isCompleted: !event.task.isCompleted);
    await repo.updateTask(updated);
    add(LoadTasks());
  }

  // Handler for filtering
  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final source = currentState.allTasks; // Always filtering from source

      final filtered = _applyFilter(source, event.filter);

      // Emit new state with filtered list
      emit(
        TaskLoaded(
          allTasks: source,
          filteredTasks: filtered,
          activeFilter: event.filter,
        ),
      );
    }
  }

  // additional method for filtering
  List<TaskModel> _applyFilter(List<TaskModel> tasks, TaskFilter filter) {
    switch (filter) {
      case TaskFilter.completed:
        return tasks.where((t) => t.isCompleted).toList();
      case TaskFilter.notCompleted:
        return tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.all:
        return tasks;
    }
  }
}
