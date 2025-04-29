# 💰 PennyGuard

PennyGuard is a simple yet powerful personal finance app built using SwiftUI, SwiftData, and The Composable Architecture (TCA). Track your income and expenses effortlessly with a modern UI and robust architecture.

## 🛠 Features

- 📈 Track income and expenses by category
- 💸 View transactions with custom notes, dates, and types
- 🧠 Categorize transactions (e.g., Food, Travel, Salary)
- 🗓 Filter data by time frames (Week, Month, Year, All)
- 💾 Built using native **SwiftData** persistence
- 🧩 Modular & testable architecture powered by **TCA**

## 📱 Screenshots

| Dashboard | Add Transaction | Transaction List |
|:---------:|:----------------:|:----------------:|
| <img src="PennyGaurd/Screenshots/Simulator Screenshot - iPhone 16 Pro - 2025-04-29 at 21.56.32.png" width="200" /> | <img src="PennyGaurd/Screenshots/Simulator Screenshot - iPhone 16 Pro - 2025-04-29 at 21.56.44.png" width="200" /> | <img src="PennyGaurd/Screenshots/Simulator Screenshot - iPhone 16 Pro - 2025-04-29 at 21.56.35.png" width="200" /> |

## 🚀 Architecture

PennyGuard follows a **modular and scalable structure** using:

- ✅ **SwiftUI** for declarative UI
- ✅ **SwiftData** for local persistence
- ✅ **The Composable Architecture (TCA)** for predictable state management
- ✅ **Dependency injection** for database handling
- ✅ **Model-driven views** and testable reducers

## 🧱 Tech Stack

| Layer          | Framework / Tool          |
|----------------|---------------------------|
| UI             | SwiftUI                   |
| State          | The Composable Architecture (TCA) |
| Persistence    | SwiftData (`ModelContext`) |
| Testing        | XCTest, TCA TestSupport   |

## 🧪 Tests

Includes unit tests for the reducer logic and business rules.

To run tests:

```bash
Cmd + U (in Xcode)
