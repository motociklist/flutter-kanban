import 'package:flutter/material.dart';
import '../models/kanban_task.dart';

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
                                      child: _buildCard(context, t, isDragging: true),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(opacity: 0.4, child: _buildCard(context, t)),
                                  child: _buildCard(context, t),
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

  Widget _buildCard(BuildContext context, KanbanTask task, {bool isDragging = false}) {
    final bg = task.color ?? _colorForStatus(task.status, context);
    final textColor = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isDragging ? [BoxShadow(color: Colors.black26, blurRadius: 8)] : [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
          if (task.description != null) ...[
            SizedBox(height: 6),
            Text(task.description!, style: TextStyle(fontSize: 13, color: textColor.withAlpha(230))),
          ]
        ],
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
