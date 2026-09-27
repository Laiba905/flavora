# 🍳 Flavora - Smart Recipe & AI Pantry Assistant

Flavora is a feature-rich, cross-platform mobile and web application built with **Flutter**, powered by **Supabase**, and enhanced with **Gemini AI**. It helps users discover delicious recipes, scale ingredients dynamically, manage favorites offline, and generate instant recipes based on leftover ingredients in their pantry.

---

## ✨ Key Features

- **🔍 Hybrid Search System**: Search through 100+ local recipes instantly via Supabase PostgreSQL ILIKE search, with fallback to external culinary APIs.
- **🤖 Pantry AI Generator**: Input available ingredients in your kitchen and let Google Gemini AI generate a custom recipe instantly.
- **⚖️ Dynamic Portion Scaler**: Scale ingredients up or down effortlessly based on your desired number of servings.
- **🎥 Integrated Video Tutorials**: Watch step-by-step cooking tutorials right inside the app with web-safe embedded YouTube players.
- **❤️ Offline Favorites (Hive)**: Save your favorite recipes locally using Hive database for quick offline access.
- **🔐 Secure Authentication**: Full Email/Password and Google OAuth login managed seamlessly via Supabase Auth.
- **👤 Profile & Cloud Storage**: Customize your profile picture, stored securely locally (for guest users) or on Supabase Cloud Storage (for logged-in users).

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend & Database**: Supabase (PostgreSQL, Auth, Storage)
- **Local Storage**: Hive (NoSQL local database)
- **AI Integration**: Google Gemini AI API (`google_generative_ai`)
- **State Management**: Provider

---

## 📱 App Screenshots / Architecture


## 🚀 Getting Started Locally

Follow these steps to set up and run the project on your local machine:

### Prerequisites
- Flutter SDK installed (`>=3.0.0`)
- Dart SDK
- Supabase Account & Project

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/Laiba905/flavora.git](https://github.com/Laiba905/flavora.git)
   cd flavora
   Install dependencies:

Bash
flutter pub get
Run build runner (for Hive models generation):

Bash
flutter pub run build_runner build --delete-conflicting-outputs
Run the application:

Bash
flutter run

📂 Project Structure
Plaintext
lib/
│
├── core/
│   ├── constants/       # App colors & configuration constants
│   └── theme/           # Global app themes
│
├── models/              # Hive & JSON data models (Recipe, Category, Ingredient)
│
├── services/            # Backend services (Supabase, Hive, Gemini AI, Spoonacular)
│
├── viewmodels/          # Business logic & state management (Provider)
│
└── views/               # UI Screens & Widgets
    ├── auth/            # Login & Sign Up screens
    ├── favorites/       # Saved offline recipes
    ├── home/            # Dashboard & category filters
    ├── pantry_ai/       # AI ingredient-to-recipe generator
    ├── profile/         # User profile & image manager
    └── recipe_detail/   # Detailed view with portion scaler & video player
📄 License
This project is open-source and available under the MIT License.
