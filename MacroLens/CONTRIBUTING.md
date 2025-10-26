# Contributing to MacroLens iOS

Thank you for your interest in contributing to MacroLens! This document provides guidelines and instructions for contributing to the project.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)

---

## 🤝 Code of Conduct

### Our Pledge
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior
- Harassment or discriminatory language
- Trolling or insulting comments
- Public or private harassment
- Publishing others' private information

---

## 🚀 Getting Started

### Prerequisites
1. **macOS** 13.0+ (Ventura)
2. **Xcode** 15.0+
3. **Git** installed
4. **Apple Developer Account** (for testing on device)

### Setup Development Environment

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/MacroLens.git
   cd MacroLens
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/MacroLens.git
   ```

4. **Install dependencies**
   - Open `MacroLens.xcodeproj` in Xcode
   - Dependencies will auto-resolve via SPM

5. **Configure Firebase**
   - Download `GoogleService-Info.plist`
   - Add to project (ask maintainers for dev credentials)

6. **Build the project**
   ```bash
   # In Xcode: Cmd + B
   ```

---

## 🔄 Development Workflow

### Branch Strategy

- **main** - Production-ready code
- **develop** - Integration branch for features
- **feature/*** - Feature branches
- **bugfix/*** - Bug fix branches
- **hotfix/*** - Urgent production fixes

### Creating a Feature Branch

```bash
# Update develop branch
git checkout develop
git pull upstream develop

# Create feature branch
git checkout -b feature/your-feature-name
```

### Working on Your Feature

1. **Make changes** in your feature branch
2. **Commit frequently** with clear messages
3. **Keep branch updated** with develop:
   ```bash
   git fetch upstream
   git rebase upstream/develop
   ```

4. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

---

## 📝 Coding Standards

### Swift Style Guide

Follow [Swift.org API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

### Naming Conventions

**Variables & Constants:**
```swift
// Use camelCase
let userName = "John"
var isAuthenticated = false

// Bool should be prefixed with is/has/should
let isEnabled = true
let hasAccess = false
```

**Functions:**
```swift
// Use descriptive names
func authenticateUser(email: String, password: String) async throws
func fetchUserProfile(userId: String) async -> User?
```

**Classes & Structs:**
```swift
// Use PascalCase
class AuthViewModel: ObservableObject { }
struct UserProfile: Codable { }
```

### Code Organization

```swift
// MARK: - Properties

@Published var user: User?
private let authService = AuthService.shared

// MARK: - Initialization

init() {
    setupViewModel()
}

// MARK: - Public Methods

func login() async { }

// MARK: - Private Methods

private func setupViewModel() { }

// MARK: - Helper Methods

private func validateEmail() -> Bool { }
```

### Documentation

**Always document:**
- Public APIs
- Complex logic
- Non-obvious behavior

```swift
/// Authenticate user with email and password
///
/// - Parameters:
///   - email: User's email address
///   - password: User's password
/// - Returns: Authenticated user object
/// - Throws: AuthError if authentication fails
func login(email: String, password: String) async throws -> User {
    // Implementation
}
```

### Error Handling

```swift
// Use typed errors
enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network connection failed"
        case .serverError(let message):
            return message
        }
    }
}

// Always handle errors gracefully
do {
    try await login(email: email, password: password)
} catch {
    print("Login failed: \(error.localizedDescription)")
}
```

### SwiftUI Best Practices

```swift
// Extract complex views into separate components
struct LoginView: View {
    var body: some View {
        VStack {
            HeaderView()
            LoginFormView()
            FooterView()
        }
    }
}

// Use @ViewBuilder for conditional views
@ViewBuilder
func headerView() -> some View {
    if showHeader {
        HeaderView()
    }
}

// Prefer environment objects over passing props deeply
.environmentObject(authViewModel)
```

---

## 💬 Commit Messages

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **style:** Code style changes (formatting, missing semicolons, etc.)
- **refactor:** Code refactoring
- **test:** Adding or updating tests
- **chore:** Maintenance tasks

### Examples

```bash
feat(auth): add Google Sign-In integration

- Integrated GoogleSignIn SDK
- Added Google auth button to login screen
- Updated AuthService with Google auth method

Closes #123
```

```bash
fix(dashboard): resolve crash on nil nutrition data

Fixed crash that occurred when user had no food logs for the day.
Added nil check and default empty state.

Fixes #456
```

---

## 🔀 Pull Request Process

### Before Submitting

1. **Test your changes**
   - Run unit tests: `Cmd + U`
   - Run UI tests
   - Manual testing on simulator and device

2. **Code quality**
   - No compiler warnings
   - No SwiftLint violations (if configured)
   - Code is documented

3. **Update documentation**
   - Update README if needed
   - Add/update code comments
   - Document breaking changes

### Creating a Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open PR on GitHub**
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Base: `develop` ← Compare: `feature/your-feature-name`

3. **Fill PR template**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   - [ ] Unit tests added/updated
   - [ ] UI tests added/updated
   - [ ] Manual testing completed
   
   ## Screenshots (if applicable)
   
   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] No new warnings
   ```

4. **Wait for review**
   - Maintainers will review your PR
   - Address feedback if requested
   - Make changes in your branch and push

5. **Merge**
   - Once approved, maintainers will merge
   - Delete your feature branch after merge

---

## 🧪 Testing Guidelines

### Unit Tests

**Location:** `MacroLensTests/`

```swift
import XCTest
@testable import MacroLens

class AuthServiceTests: BaseTestCase {
    
    var authService: AuthService!
    
    override func setUp() {
        super.setUp()
        authService = AuthService.shared
    }
    
    func testLoginSuccess() {
        assertAsync {
            let (user, _) = try await self.authService.login(
                email: "test@example.com",
                password: "Password123!"
            )
            XCTAssertNotNil(user)
        }
    }
}
```

### UI Tests

**Location:** `MacroLensUITests/`

```swift
class LoginUITests: BaseUITestCase {
    
    func testLoginFlow() {
        let emailField = textField(withPlaceholder: "Email")
        let passwordField = secureTextField(withPlaceholder: "Password")
        let loginButton = button(withLabel: "Sign In")
        
        typeText("test@example.com", into: emailField)
        typeText("Password123!", into: passwordField)
        loginButton.tap()
        
        let homeTab = app.tabBars.buttons["Home"]
        assertExists(homeTab)
    }
}
```

### Test Coverage

- Aim for **80%+ coverage**
- Focus on critical paths: Auth, Food Logging, API calls
- Test edge cases and error scenarios

---

## 📚 Documentation

### Code Documentation

```swift
/// Brief description of what this does
///
/// Longer description if needed with usage examples:
/// ```
/// let result = try await fetchData()
/// ```
///
/// - Parameters:
///   - param1: Description
///   - param2: Description
/// - Returns: Description of return value
/// - Throws: Description of errors
func exampleFunction(param1: String, param2: Int) async throws -> Result {
    // Implementation
}
```

### README Updates

- Update README.md for new features
- Add setup instructions for new dependencies
- Document configuration changes

### API Documentation

- Document new API endpoints used
- Update backend integration docs
- Note breaking API changes

---

## ❓ Questions?

- **Slack:** #macrolens-dev (if applicable)
- **Email:** dev@macrolens.in
- **GitHub Issues:** [Create an issue](https://github.com/owner/MacroLens/issues)

---

## 🙏 Thank You!

Your contributions make MacroLens better for everyone. We appreciate your time and effort!

---

**Happy Coding! 🚀**
