class TaskModel {
  final int? id;
  final String title;
  final String description;
  final String category; // WORK, PERSONAL, STUDY
  final String priority; // LOW, MEDIUM, HIGH
  final DateTime? dueDate;
  final bool isCompleted;

  TaskModel({
    this.id,
    required this.title,
    this.description = '',
    this.category = 'PERSONAL',
    this.priority = 'MEDIUM',
    this.dueDate,
    this.isCompleted = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'PERSONAL',
      priority: json['priority'] as String? ?? 'MEDIUM',
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date']) : null,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'is_completed': isCompleted,
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}