/// Model for Task
class TaskModel {
  final String id;
  final String title;
  final String descr;
  final bool isCompleted;
  final String category;

  TaskModel({
    required this.id,
    required this.title,
    required this.descr,
    this.isCompleted = false, // in default not completed
    required this.category,
  });

  /// Creating as copy of the task with updated fields, so that the data does not change
  TaskModel copyWith({bool? isCompleted}) {
    return TaskModel(
      id: id,
      title: title,
      descr: descr,
      category: category,
      // Using new data if provided, otherwise keeping old data
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Converting task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'descr': descr,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  /// Creating task from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      descr: json['descr'],
      isCompleted: json['isCompleted'] ?? false,
      category: json['category'],
    );
  }
}
