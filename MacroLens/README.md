# MacroLens iOS

**See your macros, powered by AI**

MacroLens is an AI-powered nutrition tracking iOS app that helps fitness enthusiasts, bodybuilders, and athletes track their macros effortlessly using computer vision and machine learning.

[![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-lightgrey.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)

---

## 🎯 Features

### Core Features
- ✅ **AI Food Recognition** - Scan food with your camera for instant nutrition data
- ✅ **Manual Food Logging** - Search and log from comprehensive food database
- ✅ **Macro Tracking** - Track calories, protein, carbs, and fats in real-time
- ✅ **Progress Tracking** - Monitor weight, measurements, and goal progress
- ✅ **Water Tracking** - Stay hydrated with daily water intake tracking
- ✅ **Recipe Library** - Discover macro-friendly recipes
- ✅ **HealthKit Integration** - Sync with Apple Health

### Authentication
- Email/Password authentication
- Google Sign-In
- Apple Sign-In
- Biometric authentication (Face ID / Touch ID)

---

## 🛠 Tech Stack

### Languages & Frameworks
- **Swift 5.9+**
- **SwiftUI** + UIKit (Hybrid)
- **iOS 15.0+** deployment target

### Architecture
- **MVVM** + Combine
- Clean Architecture
- Dependency Injection

### Core Technologies
- **Core ML** - Food recognition
- **HealthKit** - Health data integration
- **Core Data** - Local persistence
- **Keychain** - Secure token storage

### Networking & Backend
- **Alamofire** - HTTP networking
- **URLSession** - Native networking
- **RESTful API** - Backend communication

### Third-Party SDKs
- **Firebase** (Analytics, Crashlytics)
- **Google Sign-In**
- **SDWebImageSwiftUI** - Async image loading
- **Lottie** - Animations

---

## 📋 Requirements

### Development Environment
- **macOS:** 13.0+ (Ventura)
- **Xcode:** 15.0+
- **Swift:** 5.9+
- **CocoaPods/SPM:** Latest version

### Apple Developer Account
- Required for testing on physical devices
- Required for App Store submission
- Cost: $99/year

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd MacroLens
```

### 2. Install Dependencies

**Using Swift Package Manager (Recommended):**

Dependencies are managed via SPM and will auto-resolve when you open the project.

**Packages included:**
- Alamofire
- KeychainAccess
- SDWebImageSwiftUI
- GoogleSignIn-iOS
- Lottie
- SwiftUICharts
- Firebase SDK

### 3. Configure Firebase

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to the project root (same level as Info.plist)
3. Ensure it's added to the MacroLens target

### 4. Configure API Endpoint

Update the API base URL in `Config.swift`:

```swift
struct API {
    static var baseURL: String {
        switch environment {
        case .development:
            return "http://localhost:8000"  // Your local backend
        case .production:
            return "https://api.macrolens.in"  // Your production backend
        }
    }
}
```

### 5. Configure Google Sign-In

1. Get your Google Client ID from Google Cloud Console
2. Update `Config.swift`:

```swift
struct OAuth {
    static let googleClientID = "YOUR_GOOGLE_CLIENT_ID"
}
```

3. Update URL scheme in `Info.plist`:
   - Find `CFBundleURLSchemes`
   - Replace with your reversed client ID

### 6. Build & Run

1. Open `MacroLens.xcodeproj` in Xcode
2. Select a simulator or physical device
3. Press `Cmd + R` to build and run

---

## 📁 Project Structure

```
MacroLens/
├── App/
│   └── MacroLensApp.swift           # App entry point
│
├── Core/
│   ├── Networking/                   # API Client, Network Manager
│   ├── Storage/                      # Core Data, UserDefaults, Keychain
│   ├── Analytics/                    # Analytics & Crashlytics managers
│   └── Config.swift                  # Environment configuration
│
├── Models/                           # Data models
│   ├── User.swift
│   ├── AuthModels.swift
│   └── ...
│
├── ViewModels/                       # MVVM ViewModels
│   ├── AuthViewModel.swift
│   └── ...
│
├── Views/                            # SwiftUI Views
│   ├── Auth/                         # Login, Register
│   ├── Home/                         # Dashboard
│   ├── Profile/                      # Settings
│   └── ...
│
├── Services/                         # Business logic
│   ├── AuthService.swift
│   ├── FoodService.swift
│   └── ...
│
├── Components/                       # Reusable UI components
│   ├── Buttons/
│   ├── TextFields/
│   └── ...
│
├── Utilities/                        # Helper functions
│   ├── Validators/
│   ├── Formatters/
│   └── ...
│
├── Resources/                        # Assets, fonts, localization
│   ├── Assets.xcassets/
│   ├── Fonts/
│   └── ...
│
└── Supporting Files/
    ├── Info.plist
    └── GoogleService-Info.plist
```

---

## 🧪 Testing

### Run Unit Tests
```bash
# In Xcode: Cmd + U
# Or via command line:
xcodebuild test -scheme MacroLens -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Run UI Tests
```bash
xcodebuild test -scheme MacroLens -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:MacroLensUITests
```

### Code Coverage
- Xcode → Product → Scheme → Edit Scheme → Test → Options
- Enable "Code Coverage"
- View coverage: Xcode → Report Navigator → Coverage

**Target Coverage:** 80%+

---

## 📦 Build & Deploy

### Debug Build
```bash
xcodebuild -scheme MacroLens -configuration Debug -sdk iphonesimulator
```

### Release Build
```bash
xcodebuild -scheme MacroLens -configuration Release archive -archivePath ./build/MacroLens.xcarchive
```

### TestFlight Distribution
1. Archive app: Product → Archive
2. Distribute → App Store Connect
3. Upload to TestFlight
4. Add testers in App Store Connect

---

## 🐛 Debugging

### Common Issues

**1. Build Failures**
- Clean build folder: `Cmd + Shift + K`
- Delete derived data: `~/Library/Developer/Xcode/DerivedData`
- Reset package cache: File → Packages → Reset Package Caches

**2. GoogleService-Info.plist Not Found**
- Ensure file is added to project
- Check Target Membership is enabled

**3. Signing Errors**
- Check Bundle Identifier matches provisioning profile
- Update signing team in project settings

### Logs
- View console logs: `Cmd + Shift + Y`
- Firebase logs: Firebase Console → Crashlytics
- Analytics: Firebase Console → Analytics

---

## 📝 Code Style & Conventions

- **Swift Style Guide:** Follow [Swift.org API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- **Naming:** Use clear, descriptive names
- **Comments:** Document complex logic
- **SwiftLint:** (Optional) Run `swiftlint` for style enforcement

### Example:
```swift
// MARK: - Properties

/// User authentication state
@Published var isAuthenticated: Bool = false

// MARK: - Methods

/// Authenticate user with email and password
/// - Parameters:
///   - email: User email
///   - password: User password
/// - Throws: AuthError if authentication fails
func login(email: String, password: String) async throws {
    // Implementation
}
```

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

---

## 📄 License

Proprietary - All rights reserved. See [LICENSE](LICENSE) for details.

---

## 👥 Team

- **Developer:** [Your Name]
- **Website:** [macrolens.in](https://macrolens.in)
- **Support:** support@macrolens.in

---

## 🔗 Links

- [Backend API Repository](link-to-backend-repo)
- [Design System](link-to-design-docs)
- [Product Roadmap](link-to-roadmap)
- [API Documentation](link-to-api-docs)

---

## 📱 App Store

Coming soon to the App Store!

---

**Built with ❤️ using Swift & SwiftUI**
