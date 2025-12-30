# Boldask

A community engagement platform for polls, circles, and connections.

## Features

- **Polls**: Create and participate in opinion polls
  - Personal Growth & Social+Political categories
  - Tag-based filtering
  - Vote tracking and results visualization

- **Circles**: Join or host community events
  - Online, In-Person, or Hybrid formats
  - Capacity management
  - Scheduled meetings

- **Social**: Connect with like-minded people
  - Follow/unfollow users
  - User profiles
  - Activity feeds

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0+
- Firebase project
- Node.js 18+ (for Firebase CLI)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd boldask

# Install dependencies
flutter pub get

# Configure Firebase
flutterfire configure

# Run the app
flutter run
```

### Deployment

See [docs/implementation.md](docs/implementation.md) for detailed deployment instructions.

## Project Structure

```
lib/
├── config/      # Theme, routes, constants
├── models/      # Data models
├── services/    # Firebase services
├── providers/   # State management
├── widgets/     # Reusable components
├── screens/     # Page screens
└── utils/       # Helpers & validators
```

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
- **State Management**: Provider
- **Routing**: go_router

## License

Proprietary - All rights reserved.

---

Built with Flutter for boldask.com
