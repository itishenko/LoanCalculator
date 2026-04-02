# 💰 Loan Calculator

An app for calculating loan parameters with a modern UI and Redux architecture.

## 📱 Platforms

- **iOS** (Swift + SwiftUI)
- **Android** (Kotlin + Jetpack Compose)

---

## 🚀 Quick Start

### iOS

#### Run
```bash
cd iOS
open LoanCalculator.xcodeproj
```

In Xcode:
1. Select a simulator or a physical device
2. Press `Cmd + R` to run

#### Tests
```bash
# In Xcode: Cmd + U
# Or via terminal:
xcodebuild test -scheme LoanCalculator \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

### Android

#### Run
```bash
cd Android

# Via Gradle
./gradlew assembleDebug
./gradlew installDebug

# Or open in Android Studio and click Run
```

#### Tests
```bash
cd Android
./gradlew test
./gradlew connectedAndroidTest  # For UI tests
```

---

## Features

### Core functionality
- Sliders for selecting amount (5,000 - 50,000 USD) and term (7, 14, 21, 28 days)
- Submit requests to a mock API
- Loading, success, and error state handling
- Persist last selected values (UserDefaults/SharedPreferences)

### UI/UX
- Modern design with custom 3D sliders
- Dark/light theme support
- Adaptive layout
- Smooth animations and gradients
- Number formatting with separators

### Custom sliders
- 3D effect with shadows and highlights
- Gradient track fill (from dark to light)
- Convex track shape around the thumb (Path with Bezier curves)
- Smooth interaction animations

### Architecture
- Redux/UDF (Store, State, Actions, Reducers)
- Full unit test coverage
- Async/await (iOS) and Coroutines (Android)
- Retrofit for network requests (Android)
- Input validation

---

## 🧪 Test Coverage

### iOS (30+ tests)
- `LoanStateTests` - state and calculation tests
- `LoanReducerTests` - Redux reducer tests
- `NumberFormatterTests` - formatting tests
- `IntegrationTests` - integration tests

### Android (50+ tests)
- `LoanStateTests` - state and calculation tests
- `LoanReducerTests` - Redux reducer tests
- `NumberFormatterTests` - formatting tests
- `IntegrationTests` - integration tests
- `EdgeCasesAndValidationTests` - edge cases and validation

---

## 🛠️ Technologies

### iOS
- Swift 5.9+
- SwiftUI
- Combine
- Async/await
- XCTest

### Android
- Kotlin 1.9.20
- Jetpack Compose (Material 3)
- Coroutines & Flow
- Retrofit + OkHttp
- JUnit 4

