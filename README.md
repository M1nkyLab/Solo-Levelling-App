# Solo Leveling Fitness: The System

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-%23000000.svg?style=for-the-badge&logo=riverpod&logoColor=white)](https://riverpod.dev)
[![Supabase](https://img.shields.io/badge/Supabase-%233ECF8E.svg?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)

> **"Are you ready to ARISE?"**

Solo Leveling Fitness is a gamified fitness application that transforms your real-world physical effort into digital progression. Inspired by the *Solo Leveling* Shadow Monarch aesthetics, it replaces boring spreadsheets with a sleek, immersive RPG "System" interface.

---

## ⚔️ Core Features

### 🖥️ The System UI
Experience a high-end, dark-mode interface featuring smoky progress bars and Cinzel typography. It's not just a workout tracker; it's your personal status window.

### 📜 Daily Quests
Receive daily objectives tailored to your fitness level. Complete tasks to earn XP and rewards. 
* **Passive Tracking:** Utilizes device sensors (proximity, light, accelerometer) for unique interaction-based trackers (e.g., Nose Tap Tracker, Proximity Hover).
* **Penalty Quests:** Don't miss your goals, or you might find yourself facing the "System's" penalty.

### 🏆 Rank Progression
Start as a humble **E-Rank Hunter** and work your way up to the legendary **S-Rank**. Every push-up, run, and movement counts toward your player rank.

### 🏛️ Trials & Portals
Face unique challenges through the Trials system. Enter portals, complete objectives, and avoid the "Trial Failed" state to earn exclusive rewards.

---

## 🛠️ Tech Stack

*   **Frontend:** [Flutter](https://flutter.dev) (iOS & Android)
*   **State Management:** [Riverpod](https://riverpod.dev)
*   **Backend:** [Supabase](https://supabase.com) (Auth & Data persistence)
*   **Storage:** [Shared Preferences](https://pub.dev/packages/shared_preferences) for offline caching.
*   **Sensors:** 
    *   `proximity_sensor`: For proximity-based tracking.
    *   `sensors_plus`: For movement and orientation.
    *   `light`: For environmental light-based interactions.
*   **Typography:** [Google Fonts](https://pub.dev/packages/google_fonts) (Cinzel, Roboto Mono, Rajdhani).

---

## 📂 Project Structure

```text
lib/
├── core/                # Core logic, theme, and common widgets
│   ├── logic/           # System-wide logic (SystemLogic)
│   ├── theme/           # AppTheme with smoky aesthetics
│   └── widgets/         # Reusable widgets (SmokyProgressBar, RepSlider)
├── features/            # Feature-based modules
│   ├── auth/            # Login and Authentication
│   ├── player/          # Profile, Rank, and Status Header
│   ├── quests/          # Daily Quests, Timers, and Sensor Trackers
│   └── trials/          # Trial Screens and Portal Cards
└── main.dart            # Entry point
```

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (v3.0.0+)
*   A Supabase project (for backend functionality)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/solo_levelling_app.git
    cd solo_levelling_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Setup Supabase:**
    *   Create a new project in [Supabase](https://supabase.com).
    *   Execute the SQL provided in `backend/supabase/schema.sql`.
    *   Update your `main.dart` or environment variables with your Supabase URL and Anon Key.

4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 🤝 Contributing

The System is always evolving. If you wish to contribute:
1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git checkout push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information. (Note: This is a fan-made project inspired by Solo Leveling).

---
*Created by Hunter M1nky*
