/// Represents the execution state of a specific task.
enum TaskStatus { todo, inProgress, done }

/// Data model representing an individual task within a project.
class Task {
  final int id;
  final String title;
  final TaskStatus status;
  final int priority;

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
  });

  /// Constructs a [Task] instance from a database record map.
  /// 
  /// Expects 'status' to be stored as an integer index corresponding 
  /// to the [TaskStatus] enum values.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      status: TaskStatus.values[map['status']],
      priority: map['priority'] ?? 0,
    );
  }
}

/// Data model representing a project container.
class Project {
  final int id;
  final String name;

  Project({
    required this.id,
    required this.name, 
  });

  /// Constructs a [Project] instance from a database record map.
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
    );
  }
}