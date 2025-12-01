import 'package:flutter/material.dart';
import '../models/kanban_task.dart';

typedef CardTapCallback = Future<void> Function(KanbanTask task);

class KanbanCard extends StatelessWidget {
  final KanbanTask task;
  final bool isDragging;
  final CardTapCallback? onTap;
  final Color Function(KanbanStatus, BuildContext) colorForStatus;

  const KanbanCard(
      {Key? key,
      required this.task,
      this.isDragging = false,
      this.onTap,
      required this.colorForStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = task.color ?? colorForStatus(task.status, context);
    final textColor =
        ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!(task);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isDragging
              ? [const BoxShadow(color: Colors.black26, blurRadius: 8)]
              : [const BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            if (task.description != null) ...[
              const SizedBox(height: 6),
              Text(task.description!,
                  style:
                      TextStyle(fontSize: 13, color: textColor.withAlpha(230))),
            ]
            ,
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Created: ${task.createdAt.toLocal().toIso8601String().split("T").first}',
                    style: TextStyle(fontSize: 11, color: textColor.withAlpha(200)),
                  ),
                ),
                if (task.deadline != null)
                  Text('Due: ${task.deadline!.toLocal().toIso8601String().split("T").first}',
                      style: TextStyle(fontSize: 11, color: textColor.withAlpha(200))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.createdBy ?? '', style: TextStyle(fontSize: 11, color: textColor.withAlpha(200))),
                Text(task.status.name, style: TextStyle(fontSize: 11, color: textColor.withAlpha(200))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
