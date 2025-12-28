import 'package:flutter/material.dart';
import '../models/kanban_task.dart';

typedef TodayCardTap = Future<void> Function(KanbanTask task);

class TodayCard extends StatelessWidget {
  final KanbanTask task;
  final Color Function(KanbanStatus, BuildContext) colorForStatus;
  final TodayCardTap? onTap;

  const TodayCard(
      {Key? key, required this.task, required this.colorForStatus, this.onTap})
      : super(key: key);

  String _formatDate(DateTime d) =>
      d.toLocal().toIso8601String().split('T').first;

  Color _vividColorForStatus(KanbanStatus status) {
    switch (status) {
      case KanbanStatus.todo:
        return const Color(0xFF1976D2); // vivid blue
      case KanbanStatus.inProgress:
        return const Color(0xFFFF8F00); // vivid orange
      case KanbanStatus.done:
        return const Color(0xFF2E7D32); // vivid green
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use more vivid saturated colors for Today cards (do not rely on
    // the pastel `colorForStatus` used elsewhere).
    final statusColor = _vividColorForStatus(task.status);

    // nicer accent gradient tuned to app
    const accent = LinearGradient(
      colors: [Color(0xFFFFB74D), Color(0xFF7E57C2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final bg = Theme.of(context).colorScheme.surface;
    final brightness = ThemeData.estimateBrightnessForColor(bg);
    final titleColor =
        brightness == Brightness.dark ? Colors.white : Colors.black87;

    // deadline urgency
    Color? deadlineColor;
    String? deadlineText;
    if (task.deadline != null) {
      final now = DateTime.now();
      final diff = task.deadline!.difference(now).inDays;
      if (diff < 0) {
        deadlineColor = Colors.redAccent;
        deadlineText = 'Просрочено ${_formatDate(task.deadline!)}';
      } else if (diff <= 2) {
        deadlineColor = Colors.orangeAccent;
        deadlineText = 'До: ${_formatDate(task.deadline!)}';
      } else {
        deadlineColor = Colors.green;
        deadlineText = 'До: ${_formatDate(task.deadline!)}';
      }
    }

    final createdByInitial = (task.createdBy ?? 'U').isNotEmpty
        ? (task.createdBy ?? 'U')[0].toUpperCase()
        : 'U';

    return Material(
      color: Colors.transparent,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (onTap != null) onTap!(task);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: accent,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              // make inner panel slightly translucent on light theme so
              // gradient shows through and overall colors feel richer
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: statusColor,
                  child: Text(createdByInitial,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                // main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(task.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: titleColor)),
                          ),
                          const SizedBox(width: 8),
                          // status chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: statusColor,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Text(
                              _statusLabel(task.status),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(task.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(color: titleColor.withValues(alpha: 0.85))),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (deadlineText != null) ...[
                            Builder(builder: (_) {
                              final dc = deadlineColor!;
                              final dt = deadlineText!;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: dc.withAlpha(180),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: dc),
                                ),
                                child: Row(children: [
                                  Icon(Icons.calendar_today,
                                      size: 14, color: dc),
                                  const SizedBox(width: 6),
                                  Text(dt,
                                      style:
                                          TextStyle(fontSize: 12, color: dc)),
                                ]),
                              );
                            }),
                            const SizedBox(width: 12),
                          ],
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text('Создано: ${_formatDate(task.createdAt)}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: titleColor.withValues(alpha: 0.7))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(task.createdBy ?? '',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: titleColor.withValues(alpha: 0.6))),
                          const Row(children: [
                            Icon(Icons.edit, size: 14, color: Colors.grey),
                            SizedBox(width: 6),
                            Text('Редактировать',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey))
                          ])
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(KanbanStatus status) {
    switch (status) {
      case KanbanStatus.todo:
        return 'К выполнению';
      case KanbanStatus.inProgress:
        return 'В процессе';
      case KanbanStatus.done:
        return 'Завершено';
    }
  }
}
