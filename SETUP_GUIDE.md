# Sustainable Living Guide - Setup & Deployment Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Firestore Schema](#firestore-schema)
4. [Project Setup](#project-setup)
5. [Running the App](#running-the-app)
6. [Building APK](#building-apk)
7. [Deployment](#deployment)

---

## Prerequisites

- Flutter SDK 3.1+ (latest stable)
- Dart SDK 3.1+
- Firebase CLI
- Android Studio or VS Code
- A Firebase project

---

## Firebase Setup

### Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add Project" and name it "Sustainable Living Guide"
3. Enable Google Analytics (optional)
4. Create the project

### Step 2: Add FlutterFire Configuration
```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Navigate to project directory
cd sustainable_living_guide

# Configure Firebase
flutterfire configure
```

This will generate `firebase_options.dart` in the `lib/` directory.

### Step 3: Update main.dart
Uncomment the Firebase options line in `lib/main.dart`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

And add the import:
```dart
import 'firebase_options.dart';
```

### Step 4: Enable Firebase Services

#### Authentication
1. Go to Firebase Console > Authentication > Sign-in method
2. Enable "Email/Password" provider
3. Configure email templates as needed

#### Cloud Firestore
1. Go to Firebase Console > Firestore Database
2. Click "Create Database"
3. Select "Start in production mode"
4. Choose your nearest region

#### Firebase Storage
1. Go to Firebase Console > Storage
2. Click "Get Started"
3. Set up security rules

---

## Firestore Schema

### Collections and Documents

#### `users`
```
{
  name: string,
  email: string,
  phone: string?,
  photoUrl: string?,
  role: "user" | "admin",
  sustainabilityScore: number,
  totalCarbonSaved: number,
  totalWasteReduced: number,
  challengesCompleted: number,
  badges: [string],
  createdAt: timestamp,
  lastLogin: timestamp?,
  isEmailVerified: boolean
}
```

#### `products`
```
{
  name: string,
  description: string,
  category: "Reusable Products" | "Organic Food" | "Eco Appliances" | "Zero Waste Products",
  imageUrl: string,
  sustainabilityRating: number (1-5),
  buyLink: string,
  price: number,
  isActive: boolean,
  createdAt: timestamp
}
```

#### `challenges`
```
{
  title: string,
  description: string,
  category: string,
  durationDays: number,
  imageUrl: string,
  pointsReward: number,
  badgeName: string,
  tasks: [string],
  isActive: boolean,
  startDate: timestamp,
  endDate: timestamp,
  participants: number
}
```

#### `challenge_participations`
```
{
  userId: string,
  challengeId: string,
  completedTasks: number,
  totalTasks: number,
  isCompleted: boolean,
  joinedAt: timestamp,
  completedAt: timestamp?
}
```

#### `recipes`
```
{
  title: string,
  description: string,
  category: "plant_based" | "organic" | "low_carbon",
  imageUrl: string,
  ingredients: [string],
  instructions: [string],
  prepTime: number,
  cookTime: number,
  servings: number,
  carbonFootprint: number,
  createdAt: timestamp
}
```

#### `posts`
```
{
  userId: string,
  userName: string,
  userPhoto: string?,
  content: string,
  imageUrl: string?,
  likes: number,
  likedBy: [string],
  commentCount: number,
  createdAt: timestamp
}
```

#### `comments`
```
{
  postId: string,
  userId: string,
  userName: string,
  userPhoto: string?,
  content: string,
  createdAt: timestamp
}
```

#### `articles`
```
{
  title: string,
  content: string,
  category: string,
  imageUrl: string,
  authorName: string,
  readTime: number,
  tags: [string],
  createdAt: timestamp
}
```

#### `carbon_records`
```
{
  userId: string,
  category: "transport" | "electricity" | "food" | "water",
  subcategory: string,
  amount: number,
  emissions: number,
  date: timestamp,
  notes: string?
}
```

#### `waste_records`
```
{
  userId: string,
  category: "recycled" | "composting" | "plastic_reduction" | "paper_reduction",
  item: string,
  weight: number,
  date: timestamp,
  notes: string?
}
```

#### `certifications`
```
{
  name: string,
  description: string,
  logoUrl: string,
  benefits: [string],
  usage: string,
  category: string
}
```

#### `energy_tips`
```
{
  title: string,
  description: string,
  category: "home_energy" | "appliances" | "solar" | "water_conservation",
  iconUrl: string,
  potentialSavings: number
}
```

#### `eco_travel`
```
{
  title: string,
  description: string,
  category: "hotels" | "public_transport" | "carpool" | "tips",
  imageUrl: string,
  location: string,
  ecoRating: number,
  link: string
}
```

#### `contact_messages`
```
{
  name: string,
  email: string,
  phone: string,
  message: string,
  createdAt: timestamp
}
```

### Firestore Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Public read, authenticated write for content
    match /products/{docId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /challenges/{docId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /carbon_records/{docId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    
    match /waste_records/{docId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    
    match /posts/{docId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    match /comments/{docId} {
      allow read: if true;
      allow create: if request.auth != null;
    }
    
    // Public read for educational content
    match /articles/{docId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /recipes/{docId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /certifications/{docId} { allow read: if true; }
    match /energy_tips/{docId} { allow read: if true; }
    match /eco_travel/{docId} { allow read: if true; }
    
    match /contact_messages/{docId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## Project Setup

### 1. Install Dependencies
```bash
cd sustainable_living_guide
flutter pub get
```

### 2. Platform Configuration

#### Android
- Update `android/app/build.gradle` minSdkVersion to 21+
- Enable multidex if needed
- Add Firebase google-services.json to `android/app/`

#### iOS
- Add Firebase GoogleService-Info.plist to `ios/Runner/`
- Update `ios/Podfile` minimum iOS version to 12.0
- Run `cd ios && pod install`

### 3. Generate Platform-Specific Files
```bash
flutter create .
```

---

## Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device_id>

# Run in release mode
flutter run --release
```

---

## Building APK

### Debug APK
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Split APKs by ABI (smaller file size)
```bash
flutter build apk --split-per-abi --release
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## Deployment

### Google Play Store
1. Create a developer account at https://play.google.com/console
2. Create a new app listing
3. Upload the AAB file
4. Fill in store listing details
5. Submit for review

### Apple App Store
1. Enroll in Apple Developer Program
2. Create app in App Store Connect
3. Build iOS archive: `flutter build ios --release`
4. Upload via Xcode or Transporter
5. Submit for review

### Firebase Hosting (for web version)
```bash
flutter build web
firebase deploy --only hosting
```

---

## Admin Setup

To set a user as admin, manually update their role in Firestore:
1. Go to Firebase Console > Firestore Database
2. Find the user document in the `users` collection
3. Change `role` field from `"user"` to `"admin"`

---

## Troubleshooting

### Common Issues

1. **Firebase not initializing**: Ensure `flutterfire configure` was run and `firebase_options.dart` exists
2. **Build failures**: Run `flutter clean && flutter pub get`
3. **Android build errors**: Ensure minSdkVersion >= 21 in `android/app/build.gradle`
4. **iOS build errors**: Run `cd ios && pod install --repo-update`
5. **Authentication errors**: Verify Email/Password provider is enabled in Firebase Console

---

## Architecture Overview

```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── routes/         # Navigation routes
│   ├── theme/          # Theme configuration
│   ├── utils/          # Helpers & validators
│   └── widgets/        # Reusable widgets
├── models/             # Data models
├── services/           # Firebase & SQLite services
├── repositories/       # Repository pattern layer
├── providers/          # State management (Provider)
├── screens/            # All UI screens
│   ├── admin/
│   ├── auth/
│   ├── carbon_tracker/
│   ├── certifications/
│   ├── challenges/
│   ├── contact/
│   ├── eco_travel/
│   ├── educational/
│   ├── energy_tips/
│   ├── forum/
│   ├── gallery/
│   ├── general/
│   ├── home/
│   ├── onboarding/
│   ├── products/
│   ├── progress_dashboard/
│   ├── recipes/
│   ├── splash/
│   └── waste_tracker/
└── main.dart           # App entry point
```

### Design Patterns Used
- **Clean Architecture**: Separation of concerns across layers
- **MVVM Pattern**: Provider-based state management
- **Repository Pattern**: Data abstraction layer
- **Service Layer**: Firebase and SQLite encapsulation
- **Provider Pattern**: Reactive state management
