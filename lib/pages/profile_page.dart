import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles/styles.dart';
import '../models/kanban_task.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onLogout;
  final List<KanbanTask>? tasks;
  final ValueNotifier<bool>? themeNotifier;
  const ProfilePage({Key? key, this.onLogout, this.tasks, this.themeNotifier})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Demo User';
  String _email = 'demo@example.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _name = user.displayName ?? 'User';
        _email = user.email ?? 'demo@example.com';
      });
    }
  }

  void _editProfile() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController(text: _name);
        final emailCtrl = TextEditingController(text: _email);
        return AlertDialog(
          title: const Text('Редактировать профиль'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Имя')),
              TextField(
                  controller: emailCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Электронная почта')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'name': nameCtrl.text.trim(),
                'email': emailCtrl.text.trim()
              }),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _name = result['name']!.isEmpty ? _name : result['name']!;
        _email = result['email']!.isEmpty ? _email : result['email']!;
      });
    }
  }

  int _countByStatus(KanbanStatus s) {
    if (widget.tasks == null) return 0;
    return widget.tasks!.where((t) => t.status == s).length;
  }

  @override
  Widget build(BuildContext context) {
    final todo = _countByStatus(KanbanStatus.todo);
    final inProgress = _countByStatus(KanbanStatus.inProgress);
    final done = _countByStatus(KanbanStatus.done);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFFF7FAFF), Color(0xFFF0F4FF)])),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppStyles.backgroundGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8)
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 36,
                        backgroundColor:
                            const Color.fromRGBO(255, 255, 255, 0.18),
                        child: Text(_name.isNotEmpty ? _name[0] : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(_email,
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: _editProfile,
                                    style: AppStyles.elevatedButtonStyle(
                                        verticalPadding: 10),
                                    child: const Text('Редактировать')),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (widget.onLogout != null) {
                                    widget.onLogout!();
                                    Navigator.pop(context);
                                  }
                                },
                                style: AppStyles.elevatedButtonStyle(
                                    verticalPadding: 10),
                                child: const Text('Выйти',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ])
                          ]),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ]),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ваша статистика',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatTile(
                                label: 'К выполнению',
                                value: todo.toString(),
                                color: const Color(0xFFE3F2FD)),
                            _StatTile(
                                label: 'В процессе',
                                value: inProgress.toString(),
                                color: const Color(0xFFFFF3E0)),
                            _StatTile(
                                label: 'Завершено',
                                value: done.toString(),
                                color: const Color(0xFFE8F5E9)),
                          ])
                    ]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ]),
                child: Column(children: [
                  widget.themeNotifier != null
                      ? ValueListenableBuilder<bool>(
                          valueListenable: widget.themeNotifier!,
                          builder: (context, isDark, _) {
                            return ListTile(
                              leading: const Icon(Icons.palette),
                              title: const Text('Тема'),
                              subtitle: Text(isDark ? 'Тёмная' : 'Светлая'),
                              trailing: Switch(
                                  value: isDark,
                                  onChanged: (v) =>
                                      widget.themeNotifier?.value = v),
                            );
                          },
                        )
                      : ListTile(
                          leading: const Icon(Icons.palette),
                          title: const Text('Тема'),
                          subtitle: const Text('Светлая / Тёмная (заглушка)'),
                          onTap: () {}),
                  const Divider(),
                  ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Сменить пароль'),
                      onTap: () {}),
                  const Divider(),
                  ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Помощь и обратная связь'),
                      onTap: () {}),
                ]),
              ),
              const SizedBox(height: 24),
              Center(
                  child: Text('Сделано с ❤️ — Kanban+',
                      style: TextStyle(color: Colors.grey[600]))),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile(
      {Key? key, required this.label, required this.value, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.black54))
        ]),
      ),
    );
  }
}
