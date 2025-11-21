import 'package:flutter/material.dart';

enum KanbanStatus { todo, inProgress, done }

class KanbanTask {
  final String id;
  String title;
  String? description;
  KanbanStatus status;
  Color? color;
  DateTime createdAt;

  KanbanTask({
    required this.id,
    required this.title,
    this.description,
    this.status = KanbanStatus.todo,
    this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
