# GoalBuddy App

A comprehensive mobile application for managing football academy operations, including session planning, attendance tracking, AI-powered lesson plan extraction, and automated notifications.

## Features

- **Multi-Role Support**: Admin, Coach, and Parent user interfaces
- **AI-Powered Features**:
  - PDF lesson plan extraction using Google Gemini AI
  - Drill animation generation
  - Payment receipt scanning
- **Session Management**: Create templates, schedule classes, run sessions with timers
- **Attendance Tracking**: Quick attendance marking with student history
- **Notification System**: Firebase Cloud Messaging for push notifications
- **Finance Tracking**: Payment management with receipt uploads
- **Progress Tracking**: Student badges, attendance statistics, and progress reports

## Prerequisites

- **Flutter SDK**: 3.9.2 or higher
- **Dart SDK**: 3.9.2 or higher
- **Firebase Account**: [firebase.google.com](https://firebase.google.com)
- **Google Gemini API Key**: [aistudio.google.com/apikey](https://aistudio.google.com/apikey)
- **Android Studio** or **VS Code** with Flutter extensions
- **Node.js**: For Firebase Cloud Functions (optional)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd littlekickersapp
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

#### Step 3.1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Enable the following services:
   - Authentication (Email/Password provider)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Messaging (FCM)
   - Cloud Functions (optional)

#### Step 3.2: Download Configuration Files

**For Android:**
1. In Firebase Console, add an Android app
2. Download `google-services.json`
3. Place it in `android/app/google-services.json`

**For iOS (if targeting iOS):**
1. In Firebase Console, add an iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/GoogleService-Info.plist`

**For Web:**
- Firebase web configuration is handled in `lib/firebase_options.dart`

### 4. API Keys Configuration

#### Step 4.1: Create API Keys File

```bash
cp lib/config/api_keys.dart.example lib/config/api_keys.dart
```

#### Step 4.2: Get Your Google Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/apikey)
2. Create a new API key
3. Copy the API key

#### Step 4.3: Update API Keys File

Open `lib/config/api_keys.dart` and replace the placeholder values:

```dart
class ApiKeys {
  // Google Gemini AI API Key
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

  // Firebase Configuration (from your Firebase project)
  static const String firebaseWebApiKey = 'YOUR_FIREBASE_WEB_API_KEY';
  static const String firebaseAndroidApiKey = 'YOUR_FIREBASE_ANDROID_API_KEY';

  static const String projectId = 'your-project-id';
  static const String messagingSenderId = 'your-messaging-sender-id';
  static const String appId = 'your-app-id';
  static const String androidAppId = 'your-android-app-id';
  static const String storageBucket = 'your-project-id.firebasestorage.app';
}
```

**Where to find Firebase values:**
- All values are in the `google-services.json` file you downloaded
- `projectId`: `project_info.project_id`
- `messagingSenderId`: `project_info.project_number`
- `androidAppId`: `client[0].client_info.mobilesdk_app_id`
- API keys: `client[0].api_key[0].current_key`

### 5. Firebase Security Rules

Set up Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Sessions, students, coaches - admin and coach access
    match /{collection}/{document=**} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'coach'];
    }
  }
}
```

### 6. Firebase Cloud Functions (Optional)

If you want to enable automated notifications:

```bash
cd functions
npm install
```

Deploy functions:
```bash
firebase deploy --only functions
```

### 7. Run the Application

#### On Android Emulator/Device:
```bash
flutter run
```

#### On iOS Simulator (macOS only):
```bash
flutter run -d ios
```

#### On Web:
```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── config/
│   └── api_keys.dart              # API keys configuration (gitignored)
├── models/                        # Data models
├── services/
│   ├── auth_service.dart          # Firebase Authentication
│   ├── firestore_service.dart     # Firestore database operations
│   ├── storage_service.dart       # Firebase Storage
│   ├── gemini_pdf_service.dart    # AI PDF extraction
│   ├── gemini_animation_service.dart  # AI animation generation
│   └── gemini_receipt_service.dart    # AI receipt scanning
├── views/
│   ├── admin/                     # Admin screens
│   ├── coach/                     # Coach screens
│   ├── parent/                    # Parent screens
│   └── auth/                      # Authentication screens
├── widgets/                       # Reusable widgets
└── main.dart                      # App entry point

functions/
└── index.js                       # Firebase Cloud Functions

android/
└── app/
    └── google-services.json       # Firebase Android config (gitignored)
```

## Default Test Credentials

After setting up Firebase, create test users in Firebase Authentication:

**Admin:**
- Email: `admin@littlekickers.com`
- Password: (set in Firebase Console)

**Coach:**
- Email: `coach@littlekickers.com`
- Password: (set in Firebase Console)

**Parent:**
- Email: `parent@littlekickers.com`
- Password: (set in Firebase Console)

Then create corresponding user documents in Firestore `users` collection with `role` field set to `admin`, `coach`, or `student_parent`.

## Building for Production

### Android APK:
```bash
flutter build apk --release
```

### Android App Bundle:
```bash
flutter build appbundle --release
```

### iOS (macOS only):
```bash
flutter build ios --release
```

## Troubleshooting

### Issue: "API key not valid"
- Verify your Gemini API key is correct in `lib/config/api_keys.dart`
- Check that the API key has proper permissions in Google Cloud Console

### Issue: Firebase initialization failed
- Ensure `google-services.json` is in the correct location
- Verify all Firebase services are enabled in Firebase Console
- Check that package name matches in `google-services.json` and `android/app/build.gradle`

### Issue: Notifications not working
- Ensure Firebase Cloud Messaging is enabled
- Deploy Firebase Cloud Functions using `firebase deploy --only functions`
- Check that FCM token is being saved to user documents in Firestore

### Issue: Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## Security Notes

**IMPORTANT**: Never commit sensitive files to version control:
- `lib/config/api_keys.dart` - Contains API keys
- `android/app/google-services.json` - Contains Firebase credentials
- `ios/Runner/GoogleService-Info.plist` - Contains Firebase credentials

These files are listed in `.gitignore` to prevent accidental commits.

## License

This project is developed for academic purposes as part of a final year thesis project.

## Contact

For questions or issues, please create an issue in the GitHub repository.
