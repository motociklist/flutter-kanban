# Kanban+ - Flutter App с Firebase Authentication

Приложение Kanban с аутентификацией через Firebase, drag-and-drop для управления задачами и красивым интерфейсом.

## 🚀 Быстрый старт

### 1. Установка зависимостей
```bash
flutter pub get
```

### 2. Настройка Firebase (ВАЖНО!)

Для работы аутентификации нужно настроить Firebase:

```bash
# Если flutterfire не установлена:
dart pub global activate flutterfire_cli

# Конфигурация Firebase (интерактивный режим)
flutterfire configure --android-package-name=com.example.flutterkanban
```

**Альтернативно**, заполните вручную в `lib/firebase_options.dart`:
- Замените `YOUR_WEB_API_KEY`, `YOUR_ANDROID_API_KEY`, и т.д. на реальные ключи
- Получите ключи на [Firebase Console](https://console.firebase.google.com)

### 3. Запуск приложения

```bash
# Для веб-браузера (рекомендуется для тестирования)
flutter run -d chrome

# Для Android эмулятора
flutter emulators --launch <emulator-id>
flutter run

# Для физического устройства
flutter run
```

## ✨ Особенности

- **Firebase Authentication** — регистрация и вход по email/пароль
- **Kanban Board** — три колонки (To Do, In Progress, Done)
- **Drag & Drop** — перетаскивание задач между колонками
- **Tab Navigation** — 4 вкладки (Board, Today, Completed, Account)
- **Обработка ошибок** — русские сообщения об ошибках регистрации/входа
- **Красивый UI** — градиенты, карточки, плавные анимации

## 📁 Структура проекта

```
lib/
├── main.dart                      — точка входа приложения
├── firebase_options.dart          — конфигурация Firebase
├── login_page.dart                — страница входа
├── register_page.dart             — страница регистрации
├── pages/
│   └── kanban_page.dart           — главная страница с Kanban
├── services/
│   └── firebase_auth_service.dart — сервис аутентификации
├── models/
│   └── kanban_task.dart           — модель задачи
├── widgets/
│   ├── kanban_card.dart           — компонент карточки
│   └── kanban_column.dart         — компонент колонки
└── styles.dart                    — стили и палитра цветов
```

## 🔐 Процесс аутентификации

1. **При первом запуске** — показывается страница входа
2. **Регистрация** — создание аккаунта с email/пароль
3. **После успешной регистрации** — автоматический вход и переход на главную
4. **Главная страница** — Kanban Board с управлением задачами
5. **Выход** — кнопка Logout в AppBar или Account вкладке

## 🛠️ Требования

- Flutter: >=2.5.0
- Dart: >=2.17.0
- Firebase Core: ^3.0.0
- Firebase Auth: ^5.0.0

## ✅ Проверка

```bash
# Анализ кода
flutter analyze

# Форматирование
dart format lib/
```

---

Made with ❤️ using Flutter & Firebase

