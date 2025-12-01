import 'package:flutter/material.dart';

enum KanbanStatus { todo, inProgress, done }

class KanbanTask {
  final String id;
  String title;
  String? description;
  KanbanStatus status;
  Color? color;
  DateTime createdAt;
  DateTime? deadline;
  String? createdBy; // uid or display name

  KanbanTask({
    required this.id,
    required this.title,
    this.description,
    this.status = KanbanStatus.todo,
    this.color,
    DateTime? createdAt,
    this.deadline,
    this.createdBy,
  }) : createdAt = createdAt ?? DateTime.now();
}
