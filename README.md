# Ksynic Seller iOS

iOS-приложение продавца для маркетплейса Ksynic. Порт Android-приложения `KsynicAndroidByerApp`.

## Требования

- macOS 13.0+
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+

## Стек

- SwiftUI
- URLSession + Codable
- UserDefaults + Keychain (сессия)
- MVVM + ObservableObject

## Сборка и запуск

1. Откройте `KsynicIOSByerApp.xcodeproj` в Xcode.
2. Выберите target `KsynicIOSByerApp`.
3. Убедитесь, что signing team выбрана (или задайте свою в `Signing & Capabilities`).
4. Выберите симулятор или подключённое устройство.
5. Нажмите `Cmd+R` для сборки и запуска.

## Конфигурация сервера

Базовый URL API задан в `KsynicIOSByerApp/Network/NetworkConfig.swift`:

```swift
static let apiBaseURL = "http://82.202.143.20/api"
static let mediaBaseURL = "http://82.202.143.20"
```

Для работы с HTTP-сервером в `Info.plist` (генерируемом) включен `NSAllowsArbitraryLoads`.

## Структура проекта

```
KsynicIOSByerApp/
├── App/                  // Точка входа
├── Data/DTOs/            // Модели Codable
├── Network/              // URLSession API сервис
├── Session/              // Хранение сессии
├── State/                // ViewModel
├── UI/                   // Экраны и компоненты
├── Utils/                // Утилиты и расширения
└── Resources/            // Assets
```

## Функциональность

- Авторизация по телефону (SMS / пароль) и регистрация
- Dashboard с метриками и заказами
- Список товаров, создание, редактирование, удаление
- Загрузка документов и отправка на верификацию
- Профиль, смена телефона, выбор ПВЗ
- Отзывы и ближайшие к отправке
- Локальные уведомления о новых заказах

## Важно

- `serverMvp/` и Android-приложение не изменяются.
- Иконка приложения сгенерирована как чёрный квадрат для соответствия Android-версии. При необходимости замените `Assets.xcassets/AppIcon.appiconset/AppIcon.png` на финальный вариант.
