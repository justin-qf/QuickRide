# 📱 RideShare App - Feature Guide

## 🎯 Quick Start

### For Riders
1. **Sign Up** → Choose "Rider" role
2. **Select Pickup** → Tap "Pickup Location" button
3. **Select Drop** → Tap "Drop Location" button
4. **Request Ride** → Confirm fare and request
5. **Track Driver** → Watch driver arrive in real-time
6. **Complete Ride** → Rate your experience

### For Drivers
1. **Sign Up** → Choose "Driver" role
2. **Go Online** → Toggle switch to online
3. **Accept Rides** → View and accept nearby requests
4. **Navigate** → Follow route to pickup
5. **Start Ride** → Begin journey to destination
6. **Complete** → Finish ride and collect payment

---

## 🚀 Feature Breakdown

### 1. Authentication System

#### Sign Up
- **Location**: `lib/features/authentication/presentation/pages/signup_screen.dart`
- **Features**:
  - Email/password registration
  - Role selection (Rider/Driver)
  - Form validation
  - Firebase integration
  - Auto-navigation to home screen

#### Login
- **Location**: `lib/features/authentication/presentation/pages/login_screen.dart`
- **Features**:
  - Email/password authentication
  - Role-based navigation
  - Remember me functionality
  - Password reset option

#### Role Selection
- **Location**: `lib/features/authentication/presentation/pages/role_selection_screen.dart`
- **Features**:
  - Beautiful card-based UI
  - Rider/Driver selection
  - Gradient background

---

### 2. Rider Features

#### Home Screen
- **Location**: `lib/features/rider/presentation/pages/rider_home_screen.dart`
- **Features**:
  - Google Maps integration
  - Current location display
  - Pickup/Drop selection buttons
  - Active ride detection
  - Auto-navigation to tracking

#### Location Selection
- **Location**: `lib/features/rider/presentation/pages/select_location_screen.dart`
- **Features**:
  - Interactive map
  - Search functionality
  - Address geocoding
  - Center marker for selection
  - Confirm location button

#### Ride Request
- **Location**: `lib/features/rider/presentation/pages/ride_request_screen.dart`
- **Features**:
  - Map preview with markers
  - Fare estimation
  - Distance calculation
  - Ride confirmation
  - Loading states

#### Ride Tracking
- **Location**: `lib/features/rider/presentation/pages/ride_tracking_screen.dart`
- **Features**:
  - Real-time driver location
  - Route polylines
  - ETA display
  - Driver information
  - Call driver button
  - Status updates
  - Auto-navigation to rating

#### Rating Screen
- **Location**: `lib/features/rider/presentation/pages/ride_rating_screen.dart`
- **Features**:
  - Star rating (1-5)
  - Feedback text input
  - Ride summary
  - Skip option
  - Firebase submission

---

### 3. Driver Features

#### Home Screen
- **Location**: `lib/features/driver/presentation/pages/driver_home_screen.dart`
- **Features**:
  - Online/Offline toggle
  - Real-time location tracking
  - Nearby ride requests
  - Request cards with details
  - Accept ride functionality
  - Active ride detection

#### Ride Management
- **Location**: `lib/features/driver/presentation/pages/driver_ride_screen.dart`
- **Features**:
  - Route to pickup/drop
  - Real-time location updates
  - Status progression:
    - Accepted → Going to pickup
    - Arrived → Start ride
    - Started → Complete ride
  - Fare calculation
  - Distance tracking
  - Rider information
  - Call rider button

---

### 4. Core Services

#### Authentication Service
- **Location**: `lib/core/services/auth_service.dart`
- **Functions**:
  - `signUp()` - Create new user
  - `signIn()` - Login user
  - `signOut()` - Logout
  - `getUserData()` - Fetch user profile
  - `updateUserData()` - Update profile
  - `updateDriverStatus()` - Online/offline

#### Ride Service
- **Location**: `lib/core/services/ride_service.dart`
- **Functions**:
  - `createRide()` - Request new ride
  - `acceptRide()` - Driver accepts
  - `updateRideStatus()` - Change status
  - `updateDriverLocation()` - Live tracking
  - `updateRideFare()` - Calculate fare
  - `submitRating()` - Rate ride
  - `streamRide()` - Real-time updates
  - `streamNearbyRideRequests()` - For drivers
  - `streamRiderActiveRide()` - For riders
  - `streamDriverActiveRide()` - For drivers

#### Location Service
- **Location**: `lib/core/services/location_service.dart`
- **Functions**:
  - `getCurrentLocation()` - Get GPS position
  - `getAddressFromCoordinates()` - Reverse geocoding
  - `getCoordinatesFromAddress()` - Forward geocoding
  - `streamLocationUpdates()` - Real-time GPS
  - `calculateDistance()` - Distance between points
  - `calculateBearing()` - Direction calculation

---

### 5. Data Models

#### User Model
- **Location**: `lib/core/models/user_model.dart`
- **Fields**:
  - `id` - User ID
  - `name` - Full name
  - `email` - Email address
  - `phone` - Phone number
  - `role` - Rider/Driver
  - `profileImage` - Avatar URL
  - `rating` - Average rating
  - `totalRides` - Ride count
  - `isOnline` - Driver status
  - `createdAt` - Registration date

#### Ride Model
- **Location**: `lib/core/models/ride_model.dart`
- **Fields**:
  - `id` - Ride ID
  - `riderId` - Rider user ID
  - `driverId` - Driver user ID
  - `pickupLocation` - Start point
  - `dropLocation` - End point
  - `status` - Current status
  - `requestedAt` - Request time
  - `acceptedAt` - Accept time
  - `startedAt` - Start time
  - `completedAt` - End time
  - `fare` - Total fare
  - `distance` - Trip distance
  - `eta` - Estimated time
  - `rating` - Ride rating
  - `driverCurrentLocation` - Live position

---

### 6. State Management (Riverpod)

#### Auth Providers
- **Location**: `lib/core/providers/auth_provider.dart`
- **Providers**:
  - `authServiceProvider` - Auth service instance
  - `authStateProvider` - Firebase auth stream
  - `appUserProvider` - User data
  - `currentUserProvider` - Current user state

#### Ride Providers
- **Location**: `lib/core/providers/ride_provider.dart`
- **Providers**:
  - `rideServiceProvider` - Ride service instance
  - `locationServiceProvider` - Location service
  - `currentLocationProvider` - GPS position
  - `riderActiveRideProvider` - Rider's active ride
  - `driverActiveRideProvider` - Driver's active ride
  - `nearbyRideRequestsProvider` - Nearby requests
  - `rideStreamProvider` - Single ride updates

---

### 7. Real-Time Features

#### Live Driver Tracking
- Updates every 10 meters
- Smooth marker animation
- Auto camera following
- Polyline route updates

#### Ride Status Sync
- Firestore real-time listeners
- Instant status updates
- Automatic UI refresh
- Error handling

#### Nearby Driver Discovery
- Geo-queries (5km radius)
- Real-time driver list
- Distance calculation
- Auto-refresh

---

### 8. UI Components

#### Custom Widgets
- `CustomButton` - Styled button with loading
- `CustomTextField` - Input field with icons
- `_LocationButton` - Location selection card
- `_RideRequestCard` - Ride request display
- `_RideDetailRow` - Info row display
- `_SummaryRow` - Summary information

#### Themes
- **Location**: `lib/core/constants/app_theme.dart`
- **Colors**: Primary, background, input fill
- **Text Styles**: Heading1-3, body1-2, button
- **Font**: SchibstedGrotesk

---

### 9. Maps Integration

#### Features Used
- ✅ Map display
- ✅ Custom markers
- ✅ Polylines
- ✅ Camera control
- ✅ Gestures
- ✅ My location button
- ✅ Zoom controls

#### APIs Used
- **Maps SDK** - Map display
- **Directions API** - Route calculation
- **Geocoding API** - Address conversion
- **Places API** - Location search

---

### 10. Fare Calculation

#### Formula
```dart
Base Fare: ₹20
Per KM: ₹10
Total = (Distance × 10) + 20
```

#### Example
- Distance: 5 km
- Fare: (5 × 10) + 20 = ₹70

#### Customization
Edit in `driver_ride_screen.dart`:
```dart
final fare = (distance * YOUR_RATE) + YOUR_BASE_FARE;
```

---

### 11. Testing Guide

#### Test Rider Flow
1. Sign up as Rider
2. Select pickup (use search or map)
3. Select drop location
4. Confirm ride request
5. Check Firestore for ride document
6. Manually update ride status in Firestore
7. Verify UI updates in real-time

#### Test Driver Flow
1. Sign up as Driver
2. Toggle online
3. Create ride request (as rider in another device/emulator)
4. Accept ride as driver
5. Update location (should reflect in rider app)
6. Progress through statuses
7. Complete ride

#### Test Real-Time Sync
1. Open rider app on Device A
2. Open driver app on Device B
3. Request ride from Device A
4. Accept from Device B
5. Verify both apps update in real-time

---

### 12. Debugging Tips

#### Enable Debug Logs
```dart
// In services
print('Debug: $variableName');
```

#### Check Firestore Data
1. Open Firebase Console
2. Go to Firestore Database
3. Check `users` and `rides` collections
4. Verify data structure

#### Test Location
Use Android Studio emulator:
1. Extended Controls (...)
2. Location
3. Set custom coordinates

#### Monitor API Calls
1. Google Cloud Console
2. APIs & Services
3. Dashboard
4. View usage graphs

---

### 13. Performance Optimization

#### Tips
- Cache map tiles
- Limit location update frequency
- Use indexes for Firestore queries
- Optimize marker icons
- Debounce search inputs
- Lazy load ride history

#### Current Settings
- Location updates: Every 10 meters
- Nearby radius: 5 km
- Map zoom: 15
- Marker size: 70-80 pixels

---

### 14. Security Best Practices

#### Implemented
- ✅ Firebase Auth for users
- ✅ Firestore security rules
- ✅ User-specific data access
- ✅ Ride ownership validation

#### TODO for Production
- [ ] API key restrictions
- [ ] Rate limiting
- [ ] Input validation
- [ ] HTTPS only
- [ ] App Check
- [ ] Encrypted storage

---

### 15. Customization Guide

#### Change Colors
Edit `lib/core/constants/app_theme.dart`:
```dart
static const Color primary = Color(0xFFFF6B35); // Your color
```

#### Change Fonts
1. Add fonts to `assets/fonts/`
2. Update `pubspec.yaml`
3. Update `main.dart` theme

#### Change Fare Logic
Edit `driver_ride_screen.dart`:
```dart
final fare = YOUR_CUSTOM_CALCULATION;
```

#### Change Location Update Frequency
Edit `location_service.dart`:
```dart
distanceFilter: YOUR_METERS,
```

---

## 📞 Support

For issues or questions:
1. Check README.md
2. Check FIREBASE_SETUP.md
3. Review code comments
4. Check Firebase/Google Cloud logs

---

**Happy Riding! 🚗💨**
