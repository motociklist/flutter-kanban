import 'package:flutter/material.dart';
import '../models/kanban_task.dart';
import '../widgets/kanban_column.dart';
import '../widgets/today_card.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'profile_page.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_task_service.dart';
import '../styles/styles.dart';
import 'dart:async';

class KanbanPage extends StatefulWidget {
  final ValueNotifier<bool>? firstLaunch;
  final ValueNotifier<ThemeMode>? themeMode;
  final ValueNotifier<int>? selectedTabIndex;
  const KanbanPage(
      {Key? key, this.firstLaunch, this.themeMode, this.selectedTabIndex})
      : super(key: key);

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  late List<KanbanTask> _tasks;
  final _authService = FirebaseAuthService();
  final _taskService = FirestoreTaskService();
  StreamSubscription<List<KanbanTask>>? _tasksSub;
  late final ValueNotifier<int>
      _selectedTabIndex; // Сохраняем индекс вкладки при смене темы

  @override
  void initState() {
    super.initState();
    // Используем переданный selectedTabIndex или создаем новый
    _selectedTabIndex = widget.selectedTabIndex ?? ValueNotifier(0);
    // Initially no local demo tasks — only show tasks coming from Firestore
    _tasks = [];

    // Subscribe to auth state changes to attach/detach Firestore listeners
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _subscribeToTasks();
      } else {
        // on logout, clear tasks — we only display backend tasks
        _unsubscribeFromTasks();
        setState(() {
          _tasks = [];
        });
      }
    });

    // if user already logged in, subscribe immediately
    if (_authService.currentUser != null) {
      _subscribeToTasks();
    }
  }

  @override
  void dispose() {
    // Очищаем ValueNotifier только если мы его создали сами
    if (widget.selectedTabIndex == null) {
      _selectedTabIndex.dispose();
    }
    _unsubscribeFromTasks();
    super.dispose();
  }

  void _subscribeToTasks() {
    // subscribe to Firestore tasks as stream
    _tasksSub?.cancel();
    try {
      _tasksSub = _taskService.tasksStream().listen((tasks) {
        setState(() {
          _tasks = tasks;
        });
      });
    } catch (e) {
      debugPrint('Error subscribing to tasks stream: $e');
    }
  }

  void _unsubscribeFromTasks() {
    _tasksSub?.cancel();
    _tasksSub = null;
  }

  List<KanbanTask> _byStatus(KanbanStatus s) =>
      _tasks.where((t) => t.status == s).toList();

  void _moveTask(KanbanTask task, KanbanStatus to) {
    // Проверяем, что статус действительно изменился
    if (task.status == to) {
      debugPrint('Статус уже $to');
      return;
    }

    // Находим задачу в списке и обновляем её статус
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _tasks[idx].status = to;
      }
    });

    // Обновляем статус на backend
    if (_authService.currentUser != null) {
      try {
        final updated = KanbanTask(
            id: task.id,
            title: task.title,
            description: task.description,
            status: to,
            color: task.color,
            createdAt: task.createdAt,
            deadline: task.deadline,
            createdBy: task.createdBy);
        _taskService.updateTask(updated).then((_) {
          debugPrint('Задача "${task.title}" успешно перемещена в $to');
          // Показываем уведомление пользователю
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Задача "${task.title}" перемещена'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        }).catchError((error) {
          debugPrint('Ошибка при обновлении задачи: $error');
          // Откатываем изменение в UI если произошла ошибка
          setState(() {
            final idx = _tasks.indexWhere((t) => t.id == task.id);
            if (idx != -1) {
              _tasks[idx].status = task.status;
            }
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ошибка при перемещении задачи'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      } catch (e) {
        debugPrint('Ошибка обновления задачи: $e');
        // Откатываем изменение
        setState(() {
          final idx = _tasks.indexWhere((t) => t.id == task.id);
          if (idx != -1) {
            _tasks[idx].status = task.status;
          }
        });
      }
    }
  }

  String _statusLabel(KanbanStatus s) {
    switch (s) {
      case KanbanStatus.todo:
        return 'К выполнению';
      case KanbanStatus.inProgress:
        return 'В процессе';
      case KanbanStatus.done:
        return 'Завершено';
      default:
        return s.name;
    }
  }

  Future<void> _addTaskDialog() async {
    if (_authService.currentUser == null) {
      // If not logged in, prompt to log in before creating tasks. We only allow
      // tasks to be created and displayed when they are stored in Firestore.
      final res = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Требуется вход'),
          content: const Text(
              'Пожалуйста, войдите, чтобы добавить задачи на доску.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена')),
            ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                },
                child: const Text('Войти'))
          ],
        ),
      );
      if (res == true) {
        if (!mounted) return; // проверяем, что виджет ещё в дереве
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => LoginPage(onLogin: () {})),
        );
      }
      return;
    }
    final formKey = GlobalKey<FormState>();
    String title = '';
    String desc = '';
    DateTime? deadline;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, dialogSetState) => AlertDialog(
                title: const Text('Новая задача'),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Название'),
                        onSaved: (v) => title = v ?? '',
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Введите название'
                            : null,
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Описание'),
                        onSaved: (v) => desc = v ?? '',
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                            child: Text(deadline != null
                                ? 'Срок: ${deadline!.toLocal().toIso8601String().split("T").first}'
                                : 'Без срока')),
                        TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                  context: context,
                                  initialDate: deadline ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100));
                              if (picked != null) {
                                dialogSetState(() {
                                  deadline = picked;
                                });
                              }
                            },
                            child: const Text('Выбрать дату')),
                      ]),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Отмена')),
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      formKey.currentState!.save();
                      Navigator.pop(context, true);
                    },
                    child: const Text('Добавить'),
                  ),
                ],
              )),
    );

    if (ok == true) {
      final newTask = KanbanTask(
          id: _id(),
          title: title,
          description: desc,
          status: KanbanStatus.todo,
          deadline: deadline,
          createdBy: _authService.currentUser?.displayName ??
              _authService.currentUser?.uid);
      if (_authService.currentUser != null) {
        try {
          await _taskService.addTask(newTask);
        } catch (e) {
          debugPrint('Failed adding task to Firestore: $e');
          // fallback to local
          setState(() => _tasks.add(newTask));
        }
      } else {
        setState(() => _tasks.add(newTask));
      }
    }
  }

  Future<void> _editTaskDialog(KanbanTask task) async {
    final formKey = GlobalKey<FormState>();
    String title = task.title;
    String desc = task.description ?? '';
    KanbanStatus status = task.status;
    DateTime? deadline = task.deadline;

    final ok = await showDialog<String?>(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, dialogSetState) => AlertDialog(
                title: const Text('Редактировать задачу'),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: title,
                        decoration:
                            const InputDecoration(labelText: 'Название'),
                        onSaved: (v) => title = v ?? '',
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Введите название'
                            : null,
                      ),
                      TextFormField(
                        initialValue: desc,
                        decoration:
                            const InputDecoration(labelText: 'Описание'),
                        onSaved: (v) => desc = v ?? '',
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<KanbanStatus>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'Статус'),
                        items: KanbanStatus.values
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text(_statusLabel(s))))
                            .toList(),
                        onChanged: (v) => status = v ?? status,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: Text(deadline != null
                              ? 'Срок: ${deadline!.toLocal().toIso8601String().split("T").first}'
                              : 'Без срока'),
                        ),
                        TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                  context: context,
                                  initialDate: deadline ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100));
                              if (picked != null) {
                                dialogSetState(() {
                                  deadline = picked;
                                });
                              }
                            },
                            child: const Text('Выбрать дату')),
                      ]),
                      const SizedBox(height: 8),
                      if (task.createdBy != null)
                        Text('Создатель: ${task.createdBy!}',
                            style: const TextStyle(fontSize: 12)),
                      Text(
                          'Создано: ${task.createdAt.toLocal().toIso8601String().split("T").first}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Отмена')),
                  TextButton(
                      onPressed: () async {
                        // delete
                        Navigator.pop(context, 'delete');
                      },
                      child: const Text('Удалить',
                          style: TextStyle(color: Colors.red))),
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      formKey.currentState!.save();
                      Navigator.pop(context, 'save');
                    },
                    child: const Text('Сохранить'),
                  ),
                ],
              )),
    );

    if (ok == 'delete') {
      if (_authService.currentUser != null) {
        try {
          await _taskService.deleteTask(task.id);
        } catch (e) {
          debugPrint('Failed to delete task from Firestore: $e');
        }
      } else {
        setState(() => _tasks.removeWhere((t) => t.id == task.id));
      }
      return;
    }

    if (ok == 'save') {
      final updated = KanbanTask(
          id: task.id,
          title: title,
          description: desc,
          status: status,
          color: task.color,
          createdAt: task.createdAt,
          deadline: deadline,
          createdBy: task.createdBy);
      if (_authService.currentUser != null) {
        try {
          await _taskService.updateTask(updated);
        } catch (e) {
          debugPrint('Failed to update task in Firestore: $e');
          setState(() {
            final idx = _tasks.indexWhere((t) => t.id == updated.id);
            if (idx != -1) _tasks[idx] = updated;
          });
        }
      } else {
        setState(() {
          final idx = _tasks.indexWhere((t) => t.id == updated.id);
          if (idx != -1) _tasks[idx] = updated;
        });
      }
    }
  }

  Color _colorForStatus(KanbanStatus status, BuildContext context) {
    return AppStyles.statusColor(status, context);
  }

  @override
  Widget build(BuildContext context) {
    return _KanbanScaffold(
      onLoginRequested: () async {
        await Navigator.of(context).push<bool>(MaterialPageRoute(
            builder: (_) => LoginPage(onLogin: () {
                  // Firebase handles login automatically
                  // authStateChanges will trigger and refresh the UI
                })));
      },
      onRegisterRequested: () async {
        await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const RegisterPage()));
        // After registration, Firebase authStateChanges will automatically
        // rebuild the app with the new user. No need to show message here.
      },
      onLogout: () {
        _authService.signOut();
      },
      onEditTask: (task) async {
        await _editTaskDialog(task);
      },
      addTask: _addTaskDialog,
      buildBoard: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Мобильная версия: вертикальное расположение колонок
              return Column(
                children: [
                  KanbanColumn(
                      title: 'К выполнению',
                      status: KanbanStatus.todo,
                      tasks: _byStatus(KanbanStatus.todo),
                      onTaskDropped: _moveTask,
                      onTaskTap: _editTaskDialog),
                  const SizedBox(height: 12),
                  KanbanColumn(
                      title: 'В процессе',
                      status: KanbanStatus.inProgress,
                      tasks: _byStatus(KanbanStatus.inProgress),
                      onTaskDropped: _moveTask,
                      onTaskTap: _editTaskDialog),
                  const SizedBox(height: 12),
                  KanbanColumn(
                      title: 'Завершено',
                      status: KanbanStatus.done,
                      tasks: _byStatus(KanbanStatus.done),
                      onTaskDropped: _moveTask,
                      onTaskTap: _editTaskDialog),
                ],
              );
            } else {
              // Десктопная версия: горизонтальное расположение колонок
              return Row(
                children: [
                  KanbanColumn(
                      title: 'К выполнению',
                      status: KanbanStatus.todo,
                      tasks: _byStatus(KanbanStatus.todo),
                      onTaskDropped: _moveTask,
                      onTaskTap: _editTaskDialog),
                  KanbanColumn(
                      title: 'В процессе',
                      status: KanbanStatus.inProgress,
                      tasks: _byStatus(KanbanStatus.inProgress),
                      onTaskDropped: _moveTask,
                      onTaskTap: _editTaskDialog),
                  KanbanColumn(
                      title: 'Завершено',
                      status: KanbanStatus.done,
                      tasks: _byStatus(KanbanStatus.done),
                      onTaskDropped: _moveTask,
                      onTaskTap: _editTaskDialog),
                ],
              );
            }
          },
        ),
      ),
      tasks: _tasks,
      themeMode: widget.themeMode,
      colorForStatus: _colorForStatus,
      selectedTabIndex: _selectedTabIndex,
    );
  }
}

class _KanbanScaffold extends StatefulWidget {
  final VoidCallback onLogout;
  final Future<void> Function(KanbanTask) onEditTask;
  final Future<void> Function() onLoginRequested;
  final Future<void> Function() onRegisterRequested;
  final Future<void> Function() addTask;
  final Widget Function() buildBoard;
  final List<KanbanTask> tasks;
  final Color Function(KanbanStatus, BuildContext) colorForStatus;
  final ValueNotifier<ThemeMode>? themeMode;
  final ValueNotifier<int>
      selectedTabIndex; // Для синхронизации индекса при смене темы

  const _KanbanScaffold({
    Key? key,
    required this.onLogout,
    required this.onEditTask,
    required this.onLoginRequested,
    required this.onRegisterRequested,
    required this.addTask,
    required this.buildBoard,
    required this.tasks,
    required this.colorForStatus,
    required this.selectedTabIndex,
    this.themeMode,
  }) : super(key: key);

  @override
  State<_KanbanScaffold> createState() => _KanbanScaffoldState();
}

class _KanbanScaffoldState extends State<_KanbanScaffold> {
  @override
  void initState() {
    super.initState();
    // Слушаем изменения индекса из _KanbanPageState
    widget.selectedTabIndex.addListener(_onSelectedTabChanged);
  }

  @override
  void dispose() {
    widget.selectedTabIndex.removeListener(_onSelectedTabChanged);
    super.dispose();
  }

  void _onSelectedTabChanged() {
    setState(() {}); // Перестраиваем UI при изменении индекса
  }

  void _onTap(int idx) async {
    // tabs mapping:
    // 0 - Board
    // 1 - Today
    // 2 - Completed
    // 3 - Account/Profile
    if (idx == 3) {
      final authService = FirebaseAuthService();
      if (authService.currentUser == null) {
        await widget.onLoginRequested();
        return;
      }
    }
    widget.selectedTabIndex.value = idx;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Канбан', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1E1B2E), Color(0xFF2D1B3E)])
                : const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF7E57C2)]),
          ),
        ),
        // actions removed: logout button hidden from the top app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppStyles.backgroundGradientDark
              : const LinearGradient(
                  colors: [Color(0xFFF3F7FF), Color(0xFFE8F5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
        ),
        child: IndexedStack(
          index: widget.selectedTabIndex.value,
          children: [
            // Board
            widget.buildBoard(),
            // Today: задачи, созданные сегодня — показываем в виде информативных карточек
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: widget.tasks
                    .where((t) {
                      final now = DateTime.now();
                      return t.createdAt.year == now.year &&
                          t.createdAt.month == now.month &&
                          t.createdAt.day == now.day;
                    })
                    .map((t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: TodayCard(
                            task: t,
                            colorForStatus: widget.colorForStatus,
                            onTap: (task) async {
                              await widget.onEditTask(task);
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
            // Completed
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: widget.tasks
                    .where((t) => t.status == KanbanStatus.done)
                    .map((t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: widget.colorForStatus(t.status, context),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 4)
                                ]),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  if (t.description != null)
                                    Text(t.description!,
                                        style: const TextStyle(
                                            color: Colors.black54))
                                ]),
                          ),
                        ))
                    .toList(),
              ),
            ),
            // Account (Profile)
            ProfilePage(
              onLogout: widget.onLogout,
              tasks: widget.tasks,
              themeMode: widget.themeMode,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.selectedTabIndex.value,
        onTap: _onTap,
        selectedItemColor: isDark
            ? AppStyles.primaryDark
            : const Color(0xFF6A1B9A),
        unselectedItemColor: isDark
            ? AppStyles.darkTextSecondary
            : Colors.black54,
        backgroundColor: isDark
            ? AppStyles.darkSurface
            : Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.view_kanban_outlined), label: 'Доска'),
          BottomNavigationBarItem(
              icon: Icon(Icons.today, color: Colors.deepOrange),
              label: 'Сегодня'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline, color: Colors.green),
              label: 'Завершено'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Аккаунт'),
        ],
      ),
      floatingActionButton: (widget.selectedTabIndex.value == 0 ||
              widget.selectedTabIndex.value == 1)
          ? FloatingActionButton(
              onPressed: widget.addTask,
              backgroundColor: const Color(0xFFFFA726),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
