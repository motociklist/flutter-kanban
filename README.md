
Простое Flutter-приложение с одним экраном и счётчиком.

Как запустить:

1. Убедитесь, что установлен Flutter SDK: https://flutter.dev
2. В корне проекта выполните:

```bash
flutter pub get
flutter run
flutter run -d chrome
git pull origin main

# flutter-kanban

Kanban-проект на Flutter с простой авторизацией через Firebase (email/password) и доской задач (To Do / In Progress / Done).

Ключевые фичи
- Канбан-доска с перетаскиванием задач
- Регистрация и вход через Firebase Authentication
- Простая страница профиля с отображением имени и email текущего пользователя
- Темы и централизованные стили в `lib/styles`

Структура проекта (важные папки)
- `lib/pages/` — экран(ы): `kanban_page.dart`, `login_page.dart`, `register_page.dart`, `profile_page.dart`
- `lib/widgets/` — переиспользуемые виджеты (карточка задачи, колонка)
- `lib/models/` — модели (например, `kanban_task.dart`)
- `lib/services/` — сервисы (например, `firebase_auth_service.dart`)
- `lib/styles/` — тема и стили (barrel: `lib/styles/styles.dart`)

Требования
- Flutter SDK (рекомендуется последняя стабильная версия)
- Firebase project (создайте проект в Firebase и настройте для платформ, которые используете)

Быстрый старт (локально)
1. Установите Flutter: https://flutter.dev
2. В корне проекта выполните:

```bash
flutter pub get
```

```bash
# запуск на вебе
flutter run -d chrome
1@gmail.com
git reset --hard HEAD

# или на подключённом устройстве / эмуляторе
flutter run
```