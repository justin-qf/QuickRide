# 🔥 Firebase Setup Guide

## Quick Setup Steps

### 1. Create Firebase Project

1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: "RideShare" (or your choice)
4. Disable Google Analytics (optional)
5. Click "Create Project"

### 2. Add Android App

1. In Firebase Console, click "Add app" → Android icon
2. **Android package name**: `com.app.quickride` (check `android/app/build.gradle`)
3. Download `google-services.json`
4. Place in: `android/app/google-services.json`

### 3. Add iOS App (Optional)

1. Click "Add app" → iOS icon
2. **iOS bundle ID**: `com.example.mapRouting` (check `ios/Runner.xcodeproj`)
3. Download `GoogleService-Info.plist`
4. Add to Xcode project in `ios/Runner/`

### 4. Enable Firebase Services

#### Authentication
1. Go to "Authentication" → "Sign-in method"
2. Enable "Email/Password"
3. Click "Save"

#### Firestore Database
1. Go to "Firestore Database"
2. Click "Create database"
3. Select "Start in test mode"
4. Choose location (closest to your users)
5. Click "Enable"

#### Security Rules (Important!)
1. Go to "Firestore Database" → "Rules"
2. Replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Rides collection
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

3. Click "Publish"

#### Storage (Optional)
1. Go to "Storage"
2. Click "Get started"
3. Use default rules
4. Click "Done"

### 5. Google Maps API Setup

#### Create/Select GCP Project
1. Visit [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Link to Firebase project (optional)

#### Enable APIs
1. Go to "APIs & Services" → "Library"
2. Search and enable:
   - ✅ Maps SDK for Android
   - ✅ Maps SDK for iOS
   - ✅ Directions API
   - ✅ Geocoding API
   - ✅ Places API

#### Create API Key
1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API Key"
3. Copy the API key
4. Click "Restrict Key" (recommended)
5. Under "API restrictions", select:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Directions API
   - Geocoding API
   - Places API
6. Click "Save"

#### Enable Billing
⚠️ **Important**: Google Maps requires billing to be enabled
1. Go to "Billing"
2. Link a billing account
3. Don't worry - Google provides $200 free credit monthly

### 6. Update Code with API Key

Replace `YOUR_GOOGLE_MAPS_API_KEY` in these files:

1. **Android**: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

2. **iOS**: `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

3. **Ride Tracking**: `lib/features/rider/presentation/pages/ride_tracking_screen.dart`
```dart
final result = await polylinePoints.getRouteBetweenCoordinates(
  'YOUR_ACTUAL_API_KEY_HERE', // Line ~107
  // ...
);
```

4. **Driver Ride**: `lib/features/driver/presentation/pages/driver_ride_screen.dart`
```dart
final result = await polylinePoints.getRouteBetweenCoordinates(
  'YOUR_ACTUAL_API_KEY_HERE', // Line ~95
  // ...
);
```

### 7. Test Your Setup

#### Test Firebase
```bash
flutter run
```

Try to:
1. Sign up a new user
2. Check Firebase Console → Authentication (user should appear)
3. Check Firestore Database (user document should be created)

#### Test Maps
1. Login as rider
2. Map should load with your current location
3. If map shows, Google Maps is working!

### 8. Common Issues

#### Firebase not initialized
**Error**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution**:
- Ensure `google-services.json` is in `android/app/`
- Run `flutter clean && flutter pub get`

#### Maps not showing
**Error**: Blank map or "For development purposes only" watermark

**Solution**:
- Check API key is correct
- Verify billing is enabled
- Ensure all required APIs are enabled
- Wait 5-10 minutes for API key activation

#### Location permission denied
**Solution**:
- Check `AndroidManifest.xml` has location permissions
- Check `Info.plist` has location usage descriptions
- Manually grant permission in device settings

### 9. Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules to production mode
- [ ] Restrict API key to your app's package name
- [ ] Enable App Check for Firebase
- [ ] Set up proper error logging (Crashlytics)
- [ ] Test on real devices
- [ ] Set up API key restrictions by IP/referrer
- [ ] Monitor API usage in Google Cloud Console
- [ ] Set up billing alerts

### 10. Cost Optimization

**Firebase**: Free tier includes:
- 50K reads/day
- 20K writes/day
- 1GB storage

**Google Maps**: Free tier includes:
- $200 monthly credit
- ~28,000 map loads
- ~40,000 directions requests

**Tips**:
- Cache map tiles
- Batch Firestore operations
- Use indexes for queries
- Monitor usage in consoles

---

## Need Help?

- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Documentation](https://developers.google.com/maps/documentation)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)

---

**Happy Coding! 🚀**
