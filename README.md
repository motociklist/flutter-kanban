# Demo Flutter App

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

3. Настройте Firebase для проекта:
	 - Установите и настройте `flutterfire` CLI (опционально):
		 ```bash
		 dart pub global activate flutterfire_cli
		 flutterfire configure
		 ```
	 - Поместите сгенерированный `lib/firebase_options.dart` в проект (если не создан).

4. Запустите приложение:

```bash
# запуск на вебе
flutter run -d chrome
1@gmail.com
git reset --hard HEAD

# или на подключённом устройстве / эмуляторе
flutter run
```

Firestore (правила безопасности)

В этом проекте задачи сохраняются в Firestore по пути `users/{uid}/tasks/{taskId}` — это означает, что каждая задача принадлежит конкретному пользователю.
Чтобы запретить доступ к задачам других пользователей, добавьте в консоли Firebase следующие правила для Firestore:

```firestore
service cloud.firestore {
	match /databases/{database}/documents {
		match /users/{userId}/tasks/{taskId} {
			allow read, write: if request.auth != null && request.auth.uid == userId;
		}
	}
}
```

После этого каждый пользователь сможет создавать, редактировать и удалять только свои задачи, а в UI приложение автоматически показывает только задачи для текущего пользователя.

Где смотреть код
- Точка входа: `lib/main.dart` (инициализация Firebase, StreamBuilder по `authStateChanges`)
- Авторизация: `lib/services/firebase_auth_service.dart` и `lib/pages/login_page.dart` / `lib/pages/register_page.dart`
- Канбан: `lib/pages/kanban_page.dart`, виджеты — `lib/widgets/kanban_card.dart`, `lib/widgets/kanban_column.dart`
- Профиль: `lib/pages/profile_page.dart` (показывает данные `FirebaseAuth.instance.currentUser`)

Советы
- Если после настройки Firebase вход/регистрация не работают — проверьте, что в Firebase Console включены Email/Password провайдеры.
- Для отладки аутентификации используйте логи в консоли и `flutter run -d chrome`.

Если нужно, могу:
- Помочь настроить `flutterfire configure` и `firebase_options.dart`.
- Запустить приложение и проверить flow логина/профиля.
