# Internovate - The Ultimate Internship Companion App 🚀

Welcome to the official repository for the **Internovate Mobile App**. This cross-platform application, built with Flutter, is the ultimate companion for students and aspiring professionals. It provides a complete ecosystem for internees to discover opportunities, manage their progress, and build their careers with powerful AI-driven tools, all within a beautiful and intuitive user interface.

<p align="center">
  <img src="assets/readme_images/3.jpg" width="300" alt="Home Screen">
</p>

---

## ✨ Core Features

This app is packed with features to empower internees on their career journey:

- **🔐 Secure & Easy Authentication:** Simple and secure user registration and login using Firebase Authentication (Email/Password & Google Sign-In).
- **🏠 Dynamic Home Screen:** A personalized dashboard that displays promotional banners, internship categories, and the latest hackathons.
- **🗂️ Complete Internship Journey:** From application to certification, the app manages the entire lifecycle.
- **📊 Real-time Progress Tracking:** Monitor your internship completion with a clear and intuitive UI, including a detailed monthly progress graph.
- **🤖 Powerful AI-Powered Tools:**
    - **🧠 AI Resume Builder:** Automatically generates a professional, well-formatted resume based on user profile data.
    - **🎓 AI Course Generator:** Creates custom, structured course outlines on any topic to help users upskill.
- **🔔 Real-time Notifications:** Receive instant updates from the admin regarding application status, task reminders, and more, powered by OneSignal.
- **🏆 Hackathon & Job Hub:** Discover and apply for hackathons and jobs directly within the app.
- **📱 Professional & Responsive UI:** A consistent, beautiful, and user-friendly interface that works flawlessly on both Android and iOS.

---

## 🛠️ Technology Stack

- **Framework:** **Flutter** - For beautiful, fast, and native-feeling apps on both Android and iOS.
- **State Management:** **GetX** - For powerful and lightweight state, dependency, and route management.
- **Backend:** **Firebase**
    - **Firestore:** As the primary NoSQL database for real-time data.
    - **Authentication:** For secure user management.
- **Push Notifications:** **OneSignal** - For reliable and targeted user engagement.
- **AI Integration:** **Google's Gemini API** (via Firebase Cloud Functions) - To power the AI Resume Builder and Course Generator.

---

## 📸 Application Screenshots

A visual tour of the Internovate mobile app.

#### Onboarding & Authentication
A smooth and secure entry point for users.

<p align="center">
  <img src="assets/readme_images/40.jpg" width="250" alt="Splash Screen">
  <img src="assets/readme_images/39.jpg" width="250" alt="Onboarding Screen">
  <img src="assets/readme_images/38.jpg" width="250" alt="Welcome Screen">
</p>
<p align="center">
  <img src="assets/readme_images/36.jpg" width="250" alt="Register Screen">
  <img src="assets/readme_images/37.jpg" width="250" alt="Sign In Screen">
  <img src="assets/readme_images/35.jpg" width="250" alt="Google Sign-In">
</p>

#### Main Hub & Navigation
The central dashboard and easy navigation through a clean drawer.

<p align="center">
  <img src="assets/readme_images/3.jpg" width="250" alt="Home Screen">
  <img src="assets/readme_images/32.jpg" width="250" alt="Drawer Menu">
</p>

#### Internship Journey
From applying to completing tasks, the entire process is streamlined.

<p align="center">
  <img src="assets/readme_images/31.jpg" width="250" alt="Internship List">
  <img src="assets/readme_images/30.jpg" width="250" alt="Application Form Part 1">
  <img src="assets/readme_images/29.jpg" width="250" alt="Application Form Part 2">
</p>
<p align="center">
  <img src="assets/readme_images/4.jpg" width="250" alt="Your Internship Progress">
  <img src="assets/readme_images/5.jpg" width="250" alt="Task List">
  <img src="assets/readme_images/8.jpg" width="250" alt="Task Description">
  <img src="assets/readme_images/6.jpg" width="250" alt="Task Submission Form">
</p>

#### AI Resume Builder
Build a professional resume with the help of AI.

<p align="center">
  <img src="assets/readme_images/20.jpg" width="250" alt="AI Resume Home">
  <img src="assets/readme_images/24.jpg" width="250" alt="Resume Builder Form 1">
  <img src="assets/readme_images/22.jpg" width="250" alt="Resume Builder Form 2">
</p>
<p align="center">
  <img src="assets/readme_images/23.jpg" width="250" alt="Resume Builder Skills">
  <img src="assets/readme_images/25.jpg" width="250" alt="Resume Builder Sections">
  <img src="assets/readme_images/21.jpg" width="250" alt="Generated Resume">
</p>

#### AI Course Generator
Generate custom course outlines on any topic instantly.

<p align="center">
  <img src="assets/readme_images/19.jpg" width="250" alt="AI Course Empty State">
  <img src="assets/readme_images/7.jpg" width="250" alt="AI Course Main Screen">
  <img src="assets/readme_images/18.jpg" width="250" alt="Create Course Step 1">
</p>
<p align="center">
  <img src="assets/readme_images/17.jpg" width="250" alt="Create Course Step 2">
  <img src="assets/readme_images/16.jpg" width="250" alt="Create Course Step 3">
  <img src="assets/readme_images/14.jpg" width="250" alt="Course Layout">
  <img src="assets/readme_images/15.jpg" width="250" alt="Course Layout with Chapters">
</p>
<p align="center">
  <img src="assets/readme_images/12.jpg" width="250" alt="Course Content with Video">
  <img src="assets/readme_images/13.jpg" width="250" alt="Course Content Selected Chapter">
  <img src="assets/readme_images/11.jpg" width="250" alt="Course Content Text">
  <img src="assets/readme_images/10.jpg" width="250" alt="Course Content Code Block">
  <img src="assets/readme_images/9.jpg" width="250" alt="Video Player">
</p>

#### Other Core Features
Job portal, hackathons, notifications, and more.

<p align="center">
  <img src="assets/readme_images/26.jpg" width="250" alt="Job Portal">
  <img src="assets/readme_images/27.jpg" width="250" alt="Job Portal Filters">
  <img src="assets/readme_images/33.jpg" width="250" alt="Hackathons Screen">
  <img src="assets/readme_images/34.jpg" width="250" alt="Hackathons on Home">
</p>
<p align="center">
  <img src="assets/readme_images/1.jpg" width="250" alt="Notifications Screen">
  <img src="assets/readme_images/42.jpg" width="250" alt="User Profile & Progress">
  <img src="assets/readme_images/43.jpg" width="250" alt="Progress Graph">
  <img src="assets/readme_images/41.jpg" width="250" alt="Edit Profile">
  <img src="assets/readme_images/28.jpg" width="250" alt="Contact Us">
  <img src="assets/readme_images/2.jpg" width="250" alt="Certificate">
</p>

---

## 🚀 Getting Started

Follow these steps to get a local copy up and running.

1.  **Clone the Repository:**
    ```bash
    git clone <your-repository-url>
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Environment:**
    - Add your Firebase configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS).
    - Create a file `lib/api_key.dart` for sensitive keys (OneSignal, Gemini API) and add it to `.gitignore`.

4.  **Run the App:**
    ```bash
    flutter run
    ```