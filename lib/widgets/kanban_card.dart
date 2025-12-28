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

  String _getStatusLabel(KanbanStatus status) {
    switch (status) {
      case KanbanStatus.todo:
        return 'К выполнению';
      case KanbanStatus.inProgress:
        return 'В процессе';
      case KanbanStatus.done:
        return 'Завершено';
    }
  }

  Color _getStatusColor(KanbanStatus status) {
    switch (status) {
      case KanbanStatus.todo:
        return Colors.blue;
      case KanbanStatus.inProgress:
        return Colors.orange;
      case KanbanStatus.done:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = task.color ?? colorForStatus(task.status, context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? (isDark
            ? const Color(0xFFE8E8E8) // Светло-серый вместо белого для темной темы
            : Colors.white)
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
            ],
            const SizedBox(height: 8),
            // Статус тег
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(task.status).withAlpha(180),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusLabel(task.status),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFE8E8E8)
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Создано: ${task.createdAt.toLocal().toIso8601String().split("T").first}',
                    style:
                        TextStyle(fontSize: 11, color: textColor.withAlpha(200)),
                  ),
                ),
                if (task.deadline != null)
                  Text(
                      'До: ${task.deadline!.toLocal().toIso8601String().split("T").first}',
                      style: TextStyle(
                          fontSize: 11, color: textColor.withAlpha(200))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.createdBy ?? '',
                    style:
                        TextStyle(fontSize: 11, color: textColor.withAlpha(200))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
