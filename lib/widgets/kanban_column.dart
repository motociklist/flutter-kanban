import 'package:flutter/material.dart';
import '../models/kanban_task.dart';
import 'kanban_card.dart';

typedef OnTaskDropped = void Function(KanbanTask task, KanbanStatus toStatus);

class KanbanColumn extends StatelessWidget {
  final String title;
  final KanbanStatus status;
  final List<KanbanTask> tasks;
  final OnTaskDropped onTaskDropped;

  const KanbanColumn({
    Key? key,
    required this.title,
    required this.status,
    required this.tasks,
    required this.onTaskDropped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Spacer(),
                CircleAvatar(radius: 12, child: Text('${tasks.length}')),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: DragTarget<KanbanTask>(
                onWillAcceptWithDetails: (details) => details.data.status != status,
                onAcceptWithDetails: (details) => onTaskDropped(details.data, status),
                builder: (context, candidateData, rejectedData) {
                  return SingleChildScrollView(
                    child: Column(
                      children: tasks
                          .map((t) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: LongPressDraggable<KanbanTask>(
                                  data: t,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 260),
                                      child: KanbanCard(task: t, isDragging: true, colorForStatus: _colorForStatus),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(opacity: 0.4, child: KanbanCard(task: t, colorForStatus: _colorForStatus)),
                                  child: KanbanCard(task: t, colorForStatus: _colorForStatus),
                                ),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Color _colorForStatus(KanbanStatus status, BuildContext context) {
    switch (status) {
      case KanbanStatus.todo:
        return Color(0xFFE3F2FD); // light blue
      case KanbanStatus.inProgress:
        return Color(0xFFFFF3E0); // light orange
      case KanbanStatus.done:
        return Color(0xFFE8F5E9); // light green
      default:
        return Theme.of(context).cardColor;
    }
  }
}
