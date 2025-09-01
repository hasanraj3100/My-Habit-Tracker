# 🌱 My Habit Tracker

A simple yet powerful **habit tracking app** built with Flutter and Firebase.  
This app helps you build better routines, stay consistent, and stay motivated with daily quotes.

---

## ✨ Features

- **User Authentication**
    - Sign up, login, and logout with Firebase Authentication.
    - Securely store habits and personal data in Firestore.

- **Habit Management**
    - Add, edit, and delete habits easily.
    - Set frequency: daily, weekly, or custom weekdays.
    - Track daily completions with a simple tap.

- **Motivational Quotes**
    - Get a new inspirational quote every day.
    - Save your favourite quotes for later.
    - Dedicated screen to view all favourite quotes.

- **Progress Tracking**
    - View your habit streaks and completion history.
    - Calendar-based overview to visualize progress.
    - Success rate statistics to measure growth.

- **Profile Management**
    - Edit profile information (name, gender, birthday).
    - Validations:
        - Name must be at least 3 characters.
        - Birthday cannot be a future date.
        - Timezone validation for accurate logs.
    - Logout option conveniently placed at the bottom.

- **UI/UX**
    - Clean Material UI with Flutter.
    - Confirmation dialogs for deletions.
    - Smooth navigation and responsive layout.

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase Firestore
- **Authentication:** Firebase Auth
- **State Management:** Provider
- **Other Tools:** Intl, Cloud Firestore, Material Design

---

## 🚀 Getting Started

### Prerequisites
- Install [Flutter](https://docs.flutter.dev/get-started/install) (latest stable).
- Set up a Firebase project and enable:
    - Firestore Database
    - Firebase Authentication (Email/Password)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/habit-tracker-app.git

# Navigate to the project folder
cd habit-tracker-app

# Install dependencies
flutter pub get

# Run the app
flutter run
