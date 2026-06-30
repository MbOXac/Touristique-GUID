# Firestore + Storage setup for My Trip

The My Trip section now saves trips under each authenticated user:

```text
users/{uid}/trips/{tripId}
```

Each trip document stores:

```js
{
  userId: string,
  title: string,
  destination: string,
  description: string,
  mood: string,
  startDate: Timestamp,
  endDate: Timestamp,
  photoUrls: string[],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

Trip images are uploaded to Firebase Storage:

```text
users/{uid}/trips/{tripId}/{fileName}
```

## Required Flutter packages

Run this after pulling the code:

```bash
flutter pub get
```

The following packages were added to `pubspec.yaml`:

```yaml
firebase_storage: ^13.0.0
image_picker: ^1.1.2
```

## Firestore security rules

Use rules like these so users can only access their own trips:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /trips/{tripId} {
        allow read, create, update, delete: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Firebase Storage security rules

Use rules like these so users can only upload/read/delete their own trip photos:

```js
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/trips/{tripId}/{fileName} {
      allow read, write, delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Platform notes

### Android

`image_picker` usually needs no extra Android permission for gallery on recent versions. If you want reliable camera support, check the official `image_picker` Android setup notes.

### iOS

Add usage descriptions in `ios/Runner/Info.plist` if you use camera/gallery:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app lets you upload trip photos.</string>
<key>NSCameraUsageDescription</key>
<string>This app lets you take photos for your trips.</string>
```

### Web

Image upload uses the browser file picker and uploads bytes with Firebase Storage `putData`, so it works on Flutter Web too.
