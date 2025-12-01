import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scutum/core/constants/app_constants.dart';
import 'package:scutum/data/models/task_model.dart';
import 'package:scutum/logic/task_manager.dart';
import 'package:scutum/logic/weather_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger data loading when screen is built
    context.read<WeatherBloc>().add(LoadWeather('Kyiv'));
    context.read<TaskBloc>().add(LoadTasks());

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do & Weather'),
        actions: [
          // FilterButton
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              context.read<TaskBloc>().add(
                FilterTasks(filter),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskFilter.all,
                child: Text('Show All'),
              ),
              const PopupMenuItem(
                value: TaskFilter.completed,
                child: Text('Completed'),
              ),
              const PopupMenuItem(
                value: TaskFilter.notCompleted,
                child: Text('Not completed'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Weather Widget
          const _WeatherSection(),
          const Divider(),
          // Task List
          Expanded(child: const _TaskListSection()),
        ],
      ),
      // Floating button to add task
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Task Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                // Creating new task
                // Generating ID using DateTime
                final newTask = TaskModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  descr: 'No description',
                  category: 'General',
                );
                // Send event to BLoC
                context.read<TaskBloc>().add(AddTask(newTask));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// - Weather Widget -
class _WeatherSection extends StatelessWidget {
  const _WeatherSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoading) {
          return const Padding(
            padding: EdgeInsets.all(AppConstants.padding),
            child: CircularProgressIndicator(),
          );
        } else if (state is WeatherLoaded) {
          // Constructing icon URL by OpenWeather
          final iconUrl =
              'https://openweathermap.prg/img/wn/${state.weather.iconCode}@2x.png';

          return Card(
            margin: const EdgeInsets.all(AppConstants.margin),
            child: ListTile(
              leading: Image.network(
                iconUrl,
                width: 50,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.cloud),
              ),
              title: Text(
                AppConstants.defaultCity,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${state.weather.temperature.toStringAsFixed(1)}°С - ${state.weather.description}',
              ),
              trailing: const Icon(Icons.wb_sunny_outlined),
            ),
          );
        } else if (state is WeatherError) {
          return Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Text(
              'Weather Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// --- Task List Widget ---
class _TaskListSection extends StatelessWidget {
  const _TaskListSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoaded) {
          final tasks = state.filteredTasks;

          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks found'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: Key(task.id),
                background: Container(color: Colors.red),
                onDismissed: (_) {
                  context.read<TaskBloc>().add(DeleteTask(task.id));
                },
                child: CheckboxListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    context.read<TaskBloc>().add(ToggleTask(task));
                  },
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
