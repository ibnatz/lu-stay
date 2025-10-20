# 🏠 LUStay: A student accommodation finder, for the smaller communities and institutions like Leading University, and especially for girls 🎀

A Flutter-based mobile application that helps students find and list rental accommodations. Built with Firebase backend for real-time data synchronization.

## 📱 App Features

### 🔐 Authentication & User Management
- **Email/Password Registration & Login**
- **User Profile Management**
- **Secure Firebase Authentication**
- **Session Persistence**

### 🏠 Accommodation Listings
- **Browse Available Accommodations** - View admin data listings
- **Smart Filtering System** - Filter by location, room type, and amenities
- **Favorite Listings** - Save preferred accommodations
- **Detailed Accommodation Cards** - Complete information with images

### 📝 Personal Listings Management
- **Create & Manage Listings** - Users can post their own accommodations
- **Edit & Delete Functionality** - Full CRUD operations for user listings
- **Rich Listing Forms** - Comprehensive accommodation details
- **Real-time Updates** - Instant synchronization with Firebase

### 🎨 User Experience
- **Modern Material Design UI**
- **Responsive Layout** - Optimized for mobile devices
- **Intuitive Navigation** - Bottom navigation bar
- **Loading States & Error Handling** - Smooth user experience

## 🛠 Technical Stack

### Frontend
- **Flutter Framework** - Cross-platform mobile development
- **Dart Programming Language**
- **Material Design Components**
- **Provider State Management**

### Backend & Services
- **Firebase Authentication** - User management & security
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - Image storage (ready for implementation)

### Dependencies Used
```yaml
# Firebase Core
firebase_core: ^3.6.0      # Firebase initialization
firebase_auth: ^5.3.1      # User authentication
cloud_firestore: ^5.4.3    # Real-time database

# State Management
provider: ^6.1.1           # Dependency injection & state management

# UI & Utilities
cupertino_icons: ^1.0.8    # iOS-style icons
email_validator: ^2.1.17   # Email validation
shared_preferences: ^2.2.2 # Local storage
flutter_dotenv: ^5.1.0     # Environment variables
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0+)
- Dart SDK (3.0.0+)
- Android Studio / VS Code
- Firebase Project

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd accom_project
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password)
   - Create Firestore Database
   - Add Android app to Firebase project
   - Download `google-services.json` to `android/app/`

4. **Environment Setup**
   - Create a `.env` file in the root directory
   - Add your Firebase configuration (if needed)

5. **Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Accommodations (dummy data) - public read
       match /accomodations/{document} {
         allow read: if true;
         allow write: if false; // Admin only
       }
       
       // User listings - authenticated users only
       match /user_listings/{document} {
         allow read, write: if request.auth != null 
           && request.auth.uid == resource.data.ownerId;
       }
       
       // Users collection
       match /users/{document} {
         allow read, write: if request.auth != null 
           && request.auth.uid == request.auth.uid;
       }
     }
   }
   ```

6. **Required Firestore Indexes**
   Create composite index for user listings:
   - Collection: `user_listings`
   - Fields: 
     - `ownerId` (Ascending)
     - `createdAt` (Descending) 
     - `__name__` (Descending)

7. **Generate App Icons** (Optional)
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

8. **Run the Application**
   ```bash
   flutter run
   ```

## 🎯 Key Features Implementation

### Authentication Flow
- Stream-based auth state management using `firebase_auth`
- Automatic redirect based on login status
- Secure token handling with `shared_preferences`

### Data Management
- **Admin Data**: Pre-loaded accommodations in `accomodations` collection using `cloud_firestore`
- **User Data**: Real-time user-generated listings in `user_listings` collection
- **Separation of Concerns**: Clear distinction between demo and user content

### Real-time Features
- Live updates for new listings using Firestore streams
- Instant favorite toggling with Provider state management
- Real-time filtering with Firestore queries

## 🎨 UI/UX Design

### Color Scheme
- **Primary**: `#FFFF6B6B` (Coral Red)
- **Background**: White
- **Text**: Dark gray with proper contrast ratios
- **Accents**: Subtle opacity variations for visual hierarchy

### Navigation
- Bottom navigation bar for main sections
- Consistent back button behavior
- Modal routes for forms and filters

## 🔄 State Management

### Provider Pattern
- `AuthService` - User authentication state with `firebase_auth`
- `AccommodationService` - Admin data stream with `cloud_firestore`
- `UserListingService` - User CRUD operations with Firestore
- `FavoriteService` - Favorites management with local state

### Data Flow
1. **Stream Builders** for real-time Firestore data
2. **Provider Consumers** for state access with `provider` package
3. **Service Methods** for Firestore operations
4. **Error Boundaries** for graceful failure handling

## 📊 Firebase Collections

### `accomodations` (Admin Data)
```dart
{
  title: String,
  location: String,
  rent: Number,
  roomType: String,
  genderPreference: String,
  amenities: Array<String>,
  imageUrl: String,
  ownerId: String,
  postedDate: Timestamp
}
```

### `user_listings` (User Data)
```dart
{
  title: String,
  description: String,
  location: String,
  rent: Number,
  roomType: String,
  genderPreferences: String,
  amenities: Array<String>,
  imageUrl: String,
  ownerId: String,
  ownerName: String,
  createdAt: String
}
```

### `users` (User Profiles)
```dart
{
  uid: String,
  email: String,
  fullName: String,
  createdAt: Timestamp
}
```

## 🚀 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### Generate Icons for Production
```bash
flutter pub run flutter_launcher_icons:main
```

## 🔮 Future Enhancements

### Planned Features
- **Image Upload** - Firebase Storage integration
- **Push Notifications** - New listing alerts
- **Messaging System** - Landlord-tenant communication
- **Map Integration** - Location-based browsing
- **Advanced Search** - Price range, distance filters
- **Reviews & Ratings** - User feedback system

### Potential Dependency Additions
```yaml
# For future features
firebase_storage: ^11.0.0    # Image uploads
google_maps_flutter: ^2.2.0  # Map integration
image_picker: ^1.0.4         # Camera/gallery access
url_launcher: ^6.1.10        # Phone calls/emails
```

## 🐛 Troubleshooting

### Common Issues

1. **Firestore Permission Denied**
   - Check security rules in Firebase Console
   - Verify authentication state
   - Ensure proper collection names (`accomodations` with one 'm')

2. **Missing Dependencies**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Build Errors**
   - Ensure Flutter channel is stable: `flutter channel stable`
   - Check Dart SDK compatibility (requires 3.0.0+)

4. **Firebase Configuration**
   - Verify `google-services.json` is in `android/app/`
   - Check Firebase project configuration
   - Ensure all required services are enabled

### Debug Mode
Enable debug prints in services for real-time monitoring:
```dart
// Services include comprehensive logging
print('✅ Firestore query successful: ${snapshot.docs.length} documents');
```

## 📱 Platform Support

- **Android**: Fully supported (min SDK 21)
- **iOS**: Potential for future expansion
- **Web**: Potential for future expansion

## 👥 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 🙏 Acknowledgments

### Development Team
- **Ibnat Zareen** - Full-stack Flutter development & Firebase architecture
- **Tahsina Hasnat (@tahsinadia)** - UI/UX design, app icon creation, and visual design system

### Technologies & Resources


- Flutter Team for the amazing framework
- Firebase for backend services
- Material Design for UI components
- Provider package for state management

---

**Built with ❤️ using Flutter & Firebase**

*Version: 1.0.0+1 | Flutter: >=3.0.0 | Dart: >=3.0.0*
