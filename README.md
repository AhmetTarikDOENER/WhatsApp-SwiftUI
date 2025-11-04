## 🔐 Firebase Configuration Setup

This project uses Firebase with secure configuration management.

### First Time Setup

1. **Clone the repository**
```bash
   git clone https://github.com/AhmetTarikDOENER/WhatsApp-SwiftUI
   cd WhatsApp-SwiftUI
```

2. **Set up Firebase configuration**
```bash
   cp Secrets.xcconfig.template Secrets.xcconfig
```

3. **Add your Firebase credentials**
   - Open `Secrets.xcconfig`
   - Replace all placeholder values with your actual Firebase project values
   - You can find these values in your `GoogleService-Info.plist` from Firebase Console

4. **Download GoogleService-Info.plist** (optional, for reference)
   - Go to Firebase Console → Project Settings
   - Download your iOS app's `GoogleService-Info.plist`
   - Place it in the project root (it's gitignored)

5. **Build and run**
   - Open the `.xcodeproj` or `.xcworkspace` in Xcode
   - Press `Cmd + R` to build and run

### Configuration Files

- `Secrets.xcconfig` - Your actual Firebase keys (gitignored, not committed)
- `Secrets.xcconfig.template` - Template with placeholders (committed to Git)
- `FirebaseConfig.swift` - Helper to read configuration values
