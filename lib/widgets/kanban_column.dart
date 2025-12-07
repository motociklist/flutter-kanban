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
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(isMobile ? 4 : 8),
        padding: EdgeInsets.all(isMobile ? 4 : 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
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
                    style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                CircleAvatar(
                    radius: isMobile ? 10 : 12,
                    child: Text('${tasks.length}',
                        style: TextStyle(fontSize: isMobile ? 12 : 14))),
              ],
            ),
            SizedBox(height: isMobile ? 4 : 8),
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
                        children: tasks.map((t) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Builder(builder: (context) {
                              if (!isMobile) {
                                return Draggable<KanbanTask>(
                                  data: t,
                                  dragAnchorStrategy: pointerDragAnchorStrategy,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 260),
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
                                    debugPrint(
                                        'Начало перетаскивания: ${t.title}');
                                  },
                                  onDraggableCanceled: (velocity, offset) {
                                    debugPrint(
                                        'Перетаскивание отменено: ${t.title}');
                                  },
                                  child: KanbanCard(
                                      task: t,
                                      colorForStatus: _colorForStatus,
                                      onTap: (task) =>
                                          onTaskTap?.call(task) ??
                                          Future.value()),
                                );
                              }

                              // Mobile: показываем карточку с отдельной кнопкой-рукоятью,
                              // по долгому нажатию на которую начинается перетаскивание.
                              return Stack(
                                children: [
                                  KanbanCard(
                                      task: t,
                                      colorForStatus: _colorForStatus,
                                      onTap: (task) =>
                                          onTaskTap?.call(task) ??
                                          Future.value()),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Draggable<KanbanTask>(
                                      data: t,
                                      dragAnchorStrategy:
                                          pointerDragAnchorStrategy,
                                      feedback: Material(
                                        elevation: 6,
                                        borderRadius: BorderRadius.circular(10),
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
                                        opacity: 0.3,
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withAlpha(30),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      onDragStarted: () {
                                        debugPrint(
                                            'Начало перетаскивания (ручка): ${t.title}');
                                      },
                                      onDraggableCanceled: (v, o) {
                                        debugPrint(
                                            'Перетаскивание отменено (ручка): ${t.title}');
                                      },
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          customBorder: const CircleBorder(),
                                          onLongPress: null,
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 2)
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.drag_handle,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }),
                          );
                        }).toList(),
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
