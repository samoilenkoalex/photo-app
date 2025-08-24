# Photo App
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)]()
[![Maintaner](https://img.shields.io/static/v1?label=Oleksandr%20Samoilenko&message=Maintainer&color=red)](mailto:oleksandr.samoileko@gmail.com)
[![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)]()
![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)
![GitHub release](https://img.shields.io/badge/release-v1.0.0-blue)

A Flutter application for capturing and uploading photos with offline support and automatic retry capabilities.

## Preview


**Internet connected**

https://github.com/user-attachments/assets/9b77276b-26e4-45bc-a742-44d6234f41ea


**Internet disconnected**

https://github.com/user-attachments/assets/1bcbc096-6921-4abb-a32a-f0b90109c669



## Features

-   **Photo Capture**

    -   Take photos using device camera
    -   Automatic EXIF data capture
    -   Location tagging

-   **Smart Upload Management**

    -   Offline queue support
    -   Automatic upload retry
    -   Background upload processing
    -   Queue persistence across app restarts

-   **Network Handling**
    -   Automatic connectivity monitoring
    -   Smart retry on connection restore
    

-   **User Experience**
    -   Real-time upload status
    -   Connection status indicator
    -   Upload progress tracking
    -   Failed upload management

## Getting Started

### Prerequisites

-   Flutter SDK (>=3.2.0)
-   Dart SDK (>=3.2.0)
-   iOS 11.0 or higher (for iOS)
-   Android 5.0 (API 21) or higher (for Android)

### Installation

1. Clone the repository:

```bash
git clone [repository-url]
cd photo_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Dependencies

-   **State Management**
    -   `flutter_bloc`
    -   `get_it`
    -   `equatable`
    -   `google_fonts`
    -   `cupertino_icons`
    -   `camera`
    -   `native_exif`
    -   `geolocator`
    -   `permission_handler`
    -   `connectivity_plus`
    -   `http`
    -   `path_provider`

## Architecture

The app follows a clean architecture pattern with the following structure:

```
lib/
├── features/
│   ├── camera/
│   │   ├── cubit/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── upload/
│   │   ├── cubit/
│   │   ├── models/
│   │   ├── services/
│   │   └── repositories/
│   └── connectivity/
│       └── widgets/
├── network/
├── common/
└── main.dart
```

### Key Components

-   **UploadPhotoQueueService**: Manages photo upload queue with retry capabilities and offline support
-   **ApiClient**: Handles HTTP communication with the backend
-   **UploaderCubit**: Manages upload state and coordinates with the queue service
-   **PermissionCubit**: Handles permissions and status
-   **PhotoTakerCubit**: Manages taking photos, and retrieving them to queue

## Features in Detail

### Photo Upload Queue

The app implements an upload queue system that:

-   Persists queue state across app restarts
-   Automatically retries failed uploads
-   Handles offline scenarios gracefully
-   Provides detailed upload status and progress

Example usage:

```dart
final queueService = UploadPhotoQueueService();

// Add photo to queue
queueService.addToQueue(photoPath);

// Process queue
final result = await queueService.processUploadQueue();
```

### Network Handling

The app monitors network connectivity and:

-   Automatically pauses uploads when offline
-   Resumes uploads when connection is restored
-   Persists queue during offline periods

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Created by Oleksandr Samoilenko, 2025
