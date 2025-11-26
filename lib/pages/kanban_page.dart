import 'package:flutter/material.dart';
import '../models/kanban_task.dart';
import '../widgets/kanban_column.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'profile_page.dart';
import '../services/firebase_auth_service.dart';

class KanbanPage extends StatefulWidget {
  final ValueNotifier<bool>? firstLaunch;
  final ValueNotifier<bool>? isDark;
  const KanbanPage({Key? key, this.firstLaunch, this.isDark})
      : super(key: key);

  @override
  _KanbanPageState createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  late List<KanbanTask> _tasks;
  final _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _tasks = [
      KanbanTask(
          id: _id(),
          title: 'Design app shell',
          description: 'Create basic routes and appbar',
          status: KanbanStatus.todo,
          color: Colors.white,
          createdAt: DateTime.now()),
      KanbanTask(
          id: _id(),
          title: 'Auth flow',
          description: 'Login / Logout screens',
          status: KanbanStatus.inProgress,
          color: Colors.white,
          createdAt: DateTime.now().subtract(const Duration(days: 1))),
      KanbanTask(
          id: _id(),
          title: 'Write tests',
          description: 'Add basic widget tests',
          status: KanbanStatus.done,
          color: Colors.white,
          createdAt: DateTime.now()),
    ];
  }

  List<KanbanTask> _byStatus(KanbanStatus s) =>
      _tasks.where((t) => t.status == s).toList();

  void _moveTask(KanbanTask task, KanbanStatus to) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) _tasks[idx].status = to;
    });
  }

  Future<void> _addTaskDialog() async {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String desc = '';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );

    if (ok == true) {
      setState(() {
        _tasks.add(KanbanTask(
            id: _id(),
            title: title,
            description: desc,
            status: KanbanStatus.todo));
      });
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
        await Navigator.of(context).push<bool>(
            MaterialPageRoute(
                builder: (_) =>
                    LoginPage(onLogin: () {
                      // Firebase handles login automatically
                      // authStateChanges will trigger and refresh the UI
                    })));
      },
      onRegisterRequested: () async {
        await Navigator.of(context)
            .push<bool>(MaterialPageRoute(builder: (_) => const RegisterPage()));
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
                onTaskDropped: _moveTask),
            KanbanColumn(
                title: 'In Progress',
                status: KanbanStatus.inProgress,
                tasks: _byStatus(KanbanStatus.inProgress),
                onTaskDropped: _moveTask),
            KanbanColumn(
                title: 'Done',
                status: KanbanStatus.done,
                tasks: _byStatus(KanbanStatus.done),
                onTaskDropped: _moveTask),
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
        title: const Text('Kanban', style: TextStyle(fontWeight: FontWeight.bold)),
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
            IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout),
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
                                        style: const TextStyle(color: Colors.black54))
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
                                        style: const TextStyle(color: Colors.black54))
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
                    CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFFFA726),
                        child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_authService.currentUser?.displayName ?? 'Demo User',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_authService.currentUser != null ? 'Logged in' : 'Not logged in')
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
                      icon: Icon(_authService.currentUser != null ? Icons.logout : Icons.login),
                      label: Text(_authService.currentUser != null ? 'Logout' : 'Login')),
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
