import 'package:flutter/material.dart';
import '../models/kanban_task.dart';
import 'kanban_card.dart';

typedef OnTaskDropped = void Function(KanbanTask task, KanbanStatus toStatus);
typedef OnTaskTap = Future<void> Function(KanbanTask task);

class KanbanColumn extends StatelessWidget {
  final String title;
  final KanbanStatus status;
  final List<KanbanTask> tasks;
  final OnTaskDropped onTaskDropped;
  final OnTaskTap? onTaskTap;

  const KanbanColumn({
    Key? key,
    required this.title,
    required this.status,
    required this.tasks,
    required this.onTaskDropped,
    this.onTaskTap,
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
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                CircleAvatar(radius: 12, child: Text('${tasks.length}')),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DragTarget<KanbanTask>(
                onWillAcceptWithDetails: (details) =>
                    details.data.status != status,
                onAcceptWithDetails: (details) {
                  // Вызываем callback для обновления статуса задачи
                  onTaskDropped(details.data, status);
                },
                builder: (context, candidateData, rejectedData) {
                  // Подсвечиваем колонку, когда над ней находится задача
                  final isHovering = candidateData.isNotEmpty;
                  
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isHovering
                          ? Border.all(
                              color: Colors.green,
                              width: 2,
                            )
                          : null,
                      color: isHovering
                          ? Colors.green.withAlpha(25)
                          : Colors.transparent,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: SingleChildScrollView(
                      child: Column(
                        children: tasks
                            .map((t) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Draggable<KanbanTask>(
                                    data: t,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxWidth: 260),
                                        child: KanbanCard(
                                            task: t,
                                            isDragging: true,
                                            colorForStatus: _colorForStatus),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                        opacity: 0.4,
                                        child: KanbanCard(
                                            task: t,
                                            colorForStatus: _colorForStatus)),
                                    onDragStarted: () {
                                      // Визуальная обратная связь при начале перетаскивания
                                      debugPrint(
                                          'Начало перетаскивания: ${t.title}');
                                    },
                                    onDraggableCanceled: (velocity, offset) {
                                      // Отмена перетаскивания
                                      debugPrint(
                                          'Перетаскивание отменено: ${t.title}');
                                    },
                                    child: KanbanCard(
                                        task: t,
                                        colorForStatus: _colorForStatus,
                                        onTap: (task) =>
                                            onTaskTap?.call(task) ??
                                            Future.value()),
                                  ),
                                ))
                            .toList(),
                      ),
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
        return const Color(0xFFE3F2FD); // light blue
      case KanbanStatus.inProgress:
        return const Color(0xFFFFF3E0); // light orange
      case KanbanStatus.done:
        return const Color(0xFFE8F5E9); // light green
      default:
        return Theme.of(context).cardColor;
    }
  }
}
