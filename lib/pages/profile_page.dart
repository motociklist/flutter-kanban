import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import '../styles/styles.dart';
import '../models/kanban_task.dart';
import '../services/theme_service.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onLogout;
  final List<KanbanTask>? tasks;
  final ValueNotifier<ThemeMode>? themeMode;
  const ProfilePage({Key? key, this.onLogout, this.tasks, this.themeMode})
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

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Перезагружаем профиль пользователя, чтобы получить актуальные данные
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser != null && mounted) {
        setState(() {
          _name = updatedUser.displayName ?? 'User';
          _email = updatedUser.email ?? 'demo@example.com';
        });
      }
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: isDark
                ? AppStyles.backgroundGradientDark
                : const LinearGradient(
                    colors: [Color(0xFFF7FAFF), Color(0xFFF0F4FF)])),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppStyles.backgroundGradientDark
                      : AppStyles.backgroundGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.5)
                            : Colors.black12,
                        blurRadius: 8)
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 36,
                        backgroundColor: isDark
                            ? AppStyles.darkTextPrimary.withValues(alpha: 0.18)
                            : const Color.fromRGBO(255, 255, 255, 0.18),
                        child: Text(_name.isNotEmpty ? _name[0] : 'U',
                            style: TextStyle(
                                color: isDark
                                    ? AppStyles.darkTextPrimary
                                    : Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_name,
                                style: TextStyle(
                                    color: isDark
                                        ? AppStyles.darkTextPrimary
                                        : Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(_email,
                                style: TextStyle(
                                    color: isDark
                                        ? AppStyles.darkTextSecondary
                                        : Colors.white70)),
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
                                  }
                                  // Перейти на страницу входа и очистить стек,
                                  // чтобы пользователь не мог вернуться назад.
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => LoginPage(
                                              onLogin: () {},
                                            )),
                                    (route) => false,
                                  );
                                },
                                style: AppStyles.elevatedButtonStyle(
                                    verticalPadding: 10),
                                child: Text('Выйти',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppStyles.darkTextPrimary
                                            : Colors.white)),
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
                    color: isDark ? AppStyles.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.black12,
                          blurRadius: 6)
                    ]),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ваша статистика',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _StatTile(
                                    label: 'К выполнению',
                                    value: todo.toString(),
                                    color: AppStyles.statusColor(
                                        KanbanStatus.todo, context)),
                              ),
                              Expanded(
                                child: _StatTile(
                                    label: 'В процессе',
                                    value: inProgress.toString(),
                                    color: AppStyles.statusColor(
                                        KanbanStatus.inProgress, context)),
                              ),
                              Expanded(
                                child: _StatTile(
                                    label: 'Завершено',
                                    value: done.toString(),
                                    color: AppStyles.statusColor(
                                        KanbanStatus.done, context)),
                              ),
                            ]),
                      )
                    ]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: isDark ? AppStyles.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.black12,
                          blurRadius: 6)
                    ]),
                child: Column(children: [
                  widget.themeMode != null
                      ? ValueListenableBuilder<ThemeMode>(
                          valueListenable: widget.themeMode!,
                          builder: (context, mode, _) {
                            String subtitle;
                            bool switchValue;

                            if (mode == ThemeMode.dark) {
                              subtitle = 'Тёмная';
                              switchValue = true;
                            } else if (mode == ThemeMode.light) {
                              subtitle = 'Светлая';
                              switchValue = false;
                            } else {
                              subtitle = 'Системная';
                              switchValue = Theme.of(context).brightness ==
                                  Brightness.dark;
                            }

                            return ListTile(
                              leading: const Icon(Icons.palette),
                              title: const Text('Тема'),
                              subtitle: Text(subtitle),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    switchValue ? 'Тёмная' : 'Светлая',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: switchValue,
                                    onChanged: (v) async {
                                      // Переключаем между светлой и темной, но не системной
                                      final newMode =
                                          v ? ThemeMode.dark : ThemeMode.light;
                                      widget.themeMode?.value = newMode;
                                      await ThemeService.setThemeModeEnum(
                                          newMode);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () async {
                                // При нажатии на элемент переключаем между тремя режимами
                                ThemeMode newMode;
                                if (mode == ThemeMode.light) {
                                  newMode = ThemeMode.dark;
                                } else if (mode == ThemeMode.dark) {
                                  newMode = ThemeMode.system;
                                } else {
                                  newMode = ThemeMode.light;
                                }
                                widget.themeMode?.value = newMode;
                                await ThemeService.setThemeModeEnum(newMode);
                              },
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
                      style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey[600]))),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppStyles.darkTextPrimary
                        : Colors.black87)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade300
                        : Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis)
          ]),
    );
  }
}
