import 'package:flutter/material.dart';
import '../models/kanban_task.dart';
import '../widgets/kanban_column.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'profile_page.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_task_service.dart';
import 'dart:async';

class KanbanPage extends StatefulWidget {
  final ValueNotifier<bool>? firstLaunch;
  final ValueNotifier<bool>? isDark;
  const KanbanPage({Key? key, this.firstLaunch, this.isDark}) : super(key: key);

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  late List<KanbanTask> _tasks;
  final _authService = FirebaseAuthService();
  final _taskService = FirestoreTaskService();
  StreamSubscription<List<KanbanTask>>? _tasksSub;

  @override
  void initState() {
    super.initState();
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
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) _tasks[idx].status = to;
    });
    if (_authService.currentUser != null) {
      // update on the backend
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
        _taskService.updateTask(updated);
      } catch (e) {
        debugPrint('Error updating task status: $e');
      }
    }
  }

  Future<void> _addTaskDialog() async {
    if (_authService.currentUser == null) {
      // If not logged in, prompt to log in before creating tasks. We only allow
      // tasks to be created and displayed when they are stored in Firestore.
      final res = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login required'),
          content: const Text('Please log in to add tasks to your board.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                },
                child: const Text('Login'))
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
        title: const Text('New task'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (v) => title = v ?? '',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter title' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => desc = v ?? '',
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: Text(deadline != null
                        ? 'Due: ${deadline!.toLocal().toIso8601String().split("T").first}'
                        : 'No deadline')),
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
                    child: const Text('Pick date')),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();
              Navigator.pop(context, true);
            },
            child: const Text('Add'),
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
        title: const Text('Edit task'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (v) => title = v ?? '',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter title' : null,
              ),
              TextFormField(
                initialValue: desc,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => desc = v ?? '',
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<KanbanStatus>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: KanbanStatus.values
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => status = v ?? status,
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Text(deadline != null
                      ? 'Due: ${deadline!.toLocal().toIso8601String().split("T").first}'
                      : 'No deadline'),
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
                    child: const Text('Pick date')),
              ]),
              const SizedBox(height: 8),
              if (task.createdBy != null)
                Text('Creator: ${task.createdBy!}',
                    style: const TextStyle(fontSize: 12)),
              Text('Created: ${task.createdAt.toLocal().toIso8601String().split("T").first}',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () async {
                // delete
                Navigator.pop(context, 'delete');
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();
              Navigator.pop(context, 'save');
            },
            child: const Text('Save'),
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
    switch (status) {
      case KanbanStatus.todo:
        return const Color(0xFFE3F2FD);
      case KanbanStatus.inProgress:
        return const Color(0xFFFFF3E0);
      case KanbanStatus.done:
        return const Color(0xFFE8F5E9);
      default:
        return Theme.of(context).cardColor;
    }
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
      addTask: _addTaskDialog,
      buildBoard: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          children: [
            KanbanColumn(
                title: 'To Do',
                status: KanbanStatus.todo,
                tasks: _byStatus(KanbanStatus.todo),
                onTaskDropped: _moveTask,
                onTaskTap: _editTaskDialog),
            KanbanColumn(
                title: 'In Progress',
                status: KanbanStatus.inProgress,
                tasks: _byStatus(KanbanStatus.inProgress),
                onTaskDropped: _moveTask,
                onTaskTap: _editTaskDialog),
            KanbanColumn(
                title: 'Done',
                status: KanbanStatus.done,
                tasks: _byStatus(KanbanStatus.done),
                onTaskDropped: _moveTask,
                onTaskTap: _editTaskDialog),
          ],
        ),
      ),
      tasks: _tasks,
      themeNotifier: widget.isDark,
      colorForStatus: _colorForStatus,
    );
  }
}

class _KanbanScaffold extends StatefulWidget {
  final VoidCallback onLogout;
  final Future<void> Function() onLoginRequested;
  final Future<void> Function() onRegisterRequested;
  final Future<void> Function() addTask;
  final Widget Function() buildBoard;
  final List<KanbanTask> tasks;
  final Color Function(KanbanStatus, BuildContext) colorForStatus;
  final ValueNotifier<bool>? themeNotifier;

  const _KanbanScaffold({
    Key? key,
    required this.onLogout,
    required this.onLoginRequested,
    required this.onRegisterRequested,
    required this.addTask,
    required this.buildBoard,
    required this.tasks,
    required this.colorForStatus,
    this.themeNotifier,
  }) : super(key: key);

  @override
  State<_KanbanScaffold> createState() => _KanbanScaffoldState();
}

class _KanbanScaffoldState extends State<_KanbanScaffold> {
  int _selectedIndex = 0;
  final _authService = FirebaseAuthService();

  void _onTap(int idx) async {
    // tabs mapping:
    // 0 - Board
    // 1 - Today
    // 2 - Completed
    // 3 - Account
    if (idx == 3) {
      if (_authService.currentUser != null) {
        // Open full Profile page
        if (mounted) {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ProfilePage(
                  onLogout: widget.onLogout,
                  tasks: widget.tasks,
                  themeNotifier: widget.themeNotifier)));
        }
      } else {
        await widget.onLoginRequested();
      }
      return;
    }
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Kanban', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient:
                //fixme
                LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF7E57C2)]),
          ),
        ),
        actions: [
          if (_authService.currentUser != null)
            IconButton(
                icon: const Icon(Icons.logout), onPressed: widget.onLogout),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFF3F7FF), Color(0xFFE8F5FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // Board
            widget.buildBoard(),
            // Today: tasks created today
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
            // Account (static page)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFFFA726),
                        child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              _authService.currentUser?.displayName ??
                                  'Demo User',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_authService.currentUser != null
                              ? 'Logged in'
                              : 'Not logged in')
                        ])
                  ]),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _authService.currentUser != null
                          ? widget.onLogout
                          : widget.onLoginRequested,
                      icon: Icon(_authService.currentUser != null
                          ? Icons.logout
                          : Icons.login),
                      label: Text(_authService.currentUser != null
                          ? 'Logout'
                          : 'Login')),
                  const SizedBox(height: 12),
                  const Text('About',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                      'This is a demo Kanban app with a vibrant UI. Use the Board tab to drag & drop tasks.'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.view_kanban_outlined), label: 'Board'),
          BottomNavigationBarItem(
              icon: Icon(Icons.today, color: Colors.deepOrange),
              label: 'Today'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline, color: Colors.green),
              label: 'Completed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.addTask,
        backgroundColor: const Color(0xFFFFA726),
        child: const Icon(Icons.add),
      ),
    );
  }
}
