# 🚖 RideShare - Rapido-like Ride Hailing App

A complete Flutter ride-hailing application with Rider and Driver flows, real-time GPS tracking, Firebase integration, and clean architecture.

## ✨ Features

### 👤 Rider Features
- ✅ User authentication (Sign up/Login)
- ✅ Role-based access (Rider/Driver)
- ✅ Interactive map with current location
- ✅ Pickup and drop location selection
- ✅ Search locations with geocoding
- ✅ Real-time nearby driver discovery
- ✅ Ride request with fare estimation
- ✅ Live driver tracking on map
- ✅ Route visualization with polylines
- ✅ ETA and distance calculation
- ✅ Ride status updates (requested → accepted → started → completed)
- ✅ Driver information display
- ✅ Rating and feedback system
- ✅ Ride history

### 🛵 Driver Features
- ✅ Driver authentication
- ✅ Online/Offline toggle
- ✅ Real-time location tracking
- ✅ Nearby ride request notifications
- ✅ Accept/Reject ride requests
- ✅ Navigation to pickup location
- ✅ Start ride functionality
- ✅ Navigate to drop location
- ✅ Complete ride with fare calculation
- ✅ Rider information display
- ✅ Earnings tracking

### 🗺️ Maps & Tracking
- ✅ Google Maps integration
- ✅ Custom markers (pickup, drop, driver)
- ✅ Real-time driver location updates
- ✅ Smooth animated marker movement
- ✅ Directions API routing
- ✅ Polyline route visualization
- ✅ Auto camera following
- ✅ Distance & ETA calculation

### 📡 Real-Time System
- ✅ Firebase Firestore for data sync
- ✅ Real-time ride status updates
- ✅ Live driver location streaming
- ✅ Rider ↔ Driver state synchronization
- ✅ Nearby driver geo-queries

### 🧠 State Management
- ✅ Riverpod for state management
- ✅ Providers for Auth, Ride, Location
- ✅ Stream providers for real-time data
- ✅ Clean separation of concerns

### 🏗️ Architecture
- ✅ Clean architecture pattern
- ✅ Repository pattern
- ✅ Service layer (Auth, Ride, Location)
- ✅ Modular and scalable code
- ✅ Separate UI for Rider & Driver

## 📦 Tech Stack

- **Framework**: Flutter 3.9+
- **State Management**: Riverpod
- **Maps**: Google Maps Flutter
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Location**: Geolocator
- **Routing**: Directions API
- **Geocoding**: Geocoding package
- **UI**: Material Design 3

## 🚀 Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.9.2 or higher)
- Android Studio / VS Code
- Firebase account
- Google Cloud Platform account (for Maps API)

### 2. Clone the Repository

```bash
git clone <your-repo-url>
cd map_routing
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Firebase Setup

#### A. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android and/or iOS app

#### B. Android Configuration

1. Download `google-services.json`
2. Place it in `android/app/`
3. Update `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

4. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

#### C. iOS Configuration

1. Download `GoogleService-Info.plist`
2. Add to `ios/Runner/` in Xcode
3. Update `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

#### D. Enable Firebase Services

In Firebase Console:
1. **Authentication**: Enable Email/Password
2. **Firestore Database**: Create database in test mode
3. **Storage**: Enable Firebase Storage

#### E. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /rides/{rideId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.riderId == request.auth.uid || 
         resource.data.driverId == request.auth.uid);
    }
  }
}
```

### 5. Google Maps Setup

#### A. Get API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Directions API
   - Geocoding API
   - Places API

4. Create API credentials (API Key)

#### B. Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

#### C. iOS Configuration

Add to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### D. Update API Key in Code

Replace `YOUR_GOOGLE_MAPS_API_KEY` in:
- `lib/features/rider/presentation/pages/ride_tracking_screen.dart`
- `lib/features/driver/presentation/pages/driver_ride_screen.dart`

### 6. Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby drivers and track rides</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to provide real-time tracking</string>
```

### 7. Run the App

```bash
# For Android
flutter run

# For iOS
cd ios && pod install && cd ..
flutter run
```

## 📱 App Flow

### Rider Flow

1. **Sign Up/Login** → Choose "Rider" role
2. **Home Screen** → View map with current location
3. **Select Pickup** → Choose pickup location on map
4. **Select Drop** → Choose destination
5. **Confirm Ride** → View fare estimate and request ride
6. **Track Driver** → Real-time driver location and ETA
7. **Ride Progress** → Track ride from pickup to drop
8. **Rate Ride** → Provide rating and feedback

### Driver Flow

1. **Sign Up/Login** → Choose "Driver" role
2. **Home Screen** → Toggle online/offline
3. **Receive Requests** → View nearby ride requests
4. **Accept Ride** → Accept a ride request
5. **Navigate to Pickup** → Follow route to pickup location
6. **Start Ride** → Begin the ride
7. **Navigate to Drop** → Follow route to destination
8. **Complete Ride** → Finish ride and collect payment

## 🎨 UI Features

- Modern, clean design
- Smooth animations
- Bottom sheet panels
- Custom markers
- Real-time updates
- Loading states
- Error handling
- Responsive layout

## 🔧 Configuration

### Fare Calculation

Edit in `lib/features/driver/presentation/pages/driver_ride_screen.dart`:

```dart
// Current: ₹10 per km + ₹20 base fare
final fare = (distance * 10) + 20;
```

### Location Update Frequency

Edit in `lib/core/services/location_service.dart`:

```dart
const locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 10, // Update every 10 meters
);
```

### Nearby Driver Radius

Edit in `lib/core/providers/ride_provider.dart`:

```dart
return rideService.streamNearbyRideRequests(location, 5.0); // 5km radius
```

## 🐛 Troubleshooting

### Firebase Initialization Error

Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is properly placed.

### Maps Not Showing

1. Check API key is correct
2. Verify billing is enabled on Google Cloud
3. Ensure all required APIs are enabled

### Location Permission Denied

Request permissions manually:
```dart
await Permission.location.request();
```

### Build Errors

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## 📝 Project Structure

```
lib/
├── core/
│   ├── constants/         # App constants and themes
│   ├── models/           # Data models (User, Ride)
│   ├── providers/        # Riverpod providers
│   ├── services/         # Business logic services
│   └── utils/            # Utility functions
├── features/
│   ├── authentication/   # Login, Signup, Role selection
│   ├── rider/           # Rider-specific screens
│   ├── driver/          # Driver-specific screens
│   ├── onboarding/      # Splash, Intro screens
│   └── tracking/        # Shared tracking logic
└── main.dart            # App entry point
```

## 🚀 Future Enhancements

- [ ] Payment gateway integration
- [ ] Push notifications
- [ ] Chat between rider and driver
- [ ] Ride scheduling
- [ ] Multiple vehicle types
- [ ] Promo codes and discounts
- [ ] Ride sharing
- [ ] Driver earnings dashboard
- [ ] Admin panel
- [ ] Analytics and reporting

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For support, email your-email@example.com or create an issue in the repository.

---

**Built with ❤️ using Flutter**
