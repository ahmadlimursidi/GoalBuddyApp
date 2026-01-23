# Chapter 5: System Implementation and Discussion

## 5.1 Introduction

This chapter presents the implementation details of the GoalBuddy - Little Kickers Coach Companion application, documenting the translation of the system design into a functional mobile application. The chapter begins with a comprehensive overview of the hardware and software environments utilized during development, followed by a detailed explanation of how the system design maps to the actual implementation. Subsequently, the testing methodologies employed to validate the system's functionality and usability are discussed, including manual testing, static code analysis, and User Acceptance Testing (UAT). The chapter concludes with a presentation and analysis of the testing results, including the System Usability Scale (SUS) evaluation and user feedback collected during the testing phase.

## 5.2 System Hardware and Software

This section describes the development environment, including the hardware specifications and software tools employed throughout the implementation phase of the GoalBuddy application.

### 5.2.1 Hardware Environment

The development of the GoalBuddy application was conducted using a personal desktop computer with specifications adequate for Flutter development, Android emulation, and concurrent execution of development tools.

**Table 5.1: Development Hardware Specifications**

| Component | Specification |
|-----------|---------------|
| Device Name | DESKTOP-3AKAJB7 |
| Processor | AMD Ryzen 5 7500F 6-Core Processor @ 3.70 GHz |
| Installed RAM | 32.0 GB (31.6 GB usable) |
| Storage | 954 GB SSD Apacer AS350 1TB + 932 GB SSD ADATA LEGEND 860 + 954 GB SSD Apacer AS350 1TB |
| Graphics Card | Intel Arc B580 Graphics (12 GB VRAM) |
| System Type | 64-bit operating system, x64-based processor |
| Operating System | Windows 11 |

The high RAM capacity (32 GB) enabled smooth operation of multiple development tools simultaneously, including Visual Studio Code, Android emulator, Chrome DevTools for Firebase debugging, and Flutter's hot reload functionality. The multi-SSD configuration provided fast read/write speeds essential for Flutter's compilation process and project file management.

**Table 5.2: Testing Device Specifications**

| Component | Specification |
|-----------|---------------|
| Device | OnePlus 11 |
| Operating System | Android 14 (OxygenOS) |
| Display | 6.7" AMOLED, 3216 x 1440 resolution |
| Processor | Qualcomm Snapdragon 8 Gen 2 |
| RAM | 16 GB |
| Storage | 256 GB |

The OnePlus 11 served as the primary testing device throughout development, providing a realistic environment for testing the application's performance, responsiveness, and user interface rendering on actual Android hardware.

### 5.2.2 Software Environment

The software environment encompasses the development tools, frameworks, programming languages, and cloud services utilized in building the GoalBuddy application.

**Table 5.3: Development Software and Tools**

| Category | Software/Tool | Version | Purpose |
|----------|---------------|---------|---------|
| **IDE** | Visual Studio Code | 1.85+ | Primary code editor with Flutter extensions |
| **Framework** | Flutter SDK | 3.29.2 | Cross-platform mobile application framework |
| **Language** | Dart | 3.7.2 | Primary programming language |
| **Version Control** | Git | 2.43+ | Source code version control |
| **Repository** | GitHub | - | Remote repository hosting |
| **AI Assistant** | Claude Code (Anthropic) | - | AI-powered coding assistance and debugging |

**Table 5.4: Backend Services and APIs**

| Service | Provider | Purpose |
|---------|----------|---------|
| Firebase Authentication | Google | User authentication and session management |
| Cloud Firestore | Google | NoSQL document database for data storage |
| Firebase Storage | Google | File storage for PDFs and media |
| Firebase Cloud Messaging (FCM) | Google | Push notification delivery |
| Firebase Cloud Functions | Google | Serverless backend functions |
| Gemini API | Google | AI-powered PDF extraction and animation generation |

**Table 5.5: Flutter Dependencies (pubspec.yaml)**

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | ^3.13.0 | Firebase initialization |
| firebase_auth | ^5.5.2 | Authentication services |
| cloud_firestore | ^5.6.6 | Firestore database operations |
| firebase_storage | ^12.4.3 | File upload/download |
| firebase_messaging | ^15.2.3 | Push notifications |
| provider | ^6.1.2 | State management |
| google_generative_ai | ^0.4.6 | Gemini AI integration |
| file_picker | ^8.0.3 | PDF file selection |
| intl | ^0.20.2 | Date/time formatting |
| flutter_local_notifications | ^18.0.1 | Local notification handling |
| shared_preferences | ^2.5.3 | Local data persistence |

### 5.2.3 System Architecture Implementation

The GoalBuddy application follows the Model-View-ViewModel (MVVM) architectural pattern, implemented using Flutter's Provider package for state management. The architecture is organized into distinct layers:

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models (User, Session, Template, etc.)
├── services/                 # Business logic and API services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── storage_service.dart
│   ├── notification_service.dart
│   ├── gemini_pdf_service.dart
│   └── gemini_animation_service.dart
├── view_models/              # State management and business logic
│   ├── auth_view_model.dart
│   ├── schedule_view_model.dart
│   ├── session_view_model.dart
│   └── template_view_model.dart
├── views/                    # UI screens organized by feature
│   ├── auth/
│   ├── dashboard/
│   ├── session/
│   ├── schedule/
│   ├── templates/
│   ├── notifications/
│   └── finance/
└── widgets/                  # Reusable UI components
    ├── drill_animation_player.dart
    ├── pdf_upload_button.dart
    └── ...
```

## 5.3 Mapping Design to Implementation

This section demonstrates how the system design documented in Chapter 4 was translated into the actual implementation, establishing clear traceability between design artifacts and code components.

### 5.3.1 Use Case to Implementation Mapping

**Table 5.6: Use Case Implementation Mapping**

| Use Case | Design Component | Implementation |
|----------|------------------|----------------|
| UC-01: User Login | AuthService, AuthViewModel | `lib/services/auth_service.dart`, `lib/view_models/auth_view_model.dart`, `lib/views/auth/login_view.dart` |
| UC-02: Create Session Template | TemplateViewModel, GeminiService | `lib/view_models/template_view_model.dart`, `lib/services/gemini_pdf_service.dart`, `lib/views/templates/create_template_view.dart` |
| UC-03: Schedule Class | ScheduleViewModel, FirestoreService | `lib/view_models/schedule_view_model.dart`, `lib/views/schedule/schedule_view.dart` |
| UC-04: Start Active Session | SessionViewModel | `lib/view_models/session_view_model.dart`, `lib/views/session/active_session_view.dart` |
| UC-05: Take Attendance | SessionViewModel | `lib/views/session/attendance_view.dart` |
| UC-06: Generate Drill Animation | GeminiAnimationService | `lib/services/gemini_animation_service.dart`, `lib/widgets/drill_animation_player.dart` |
| UC-07: View Child Progress | ParentViewModel | `lib/views/dashboard/student_parent_dashboard_view.dart` |
| UC-08: Send Notification | NotificationService | `lib/services/notification_service.dart`, `lib/views/admin/send_notification_view.dart` |

### 5.3.2 Class Diagram to Code Implementation

The UML class diagram designed in Chapter 4 was directly implemented as Dart model classes. Each entity in the class diagram corresponds to a model file in the `lib/models/` directory.

**Table 5.7: Class Diagram to Model Mapping**

| Design Class | Implementation File | Key Attributes |
|--------------|---------------------|----------------|
| User | `lib/models/user_model.dart` | uid, email, name, role, fcmToken |
| SessionTemplate | `lib/models/session_template_model.dart` | id, title, ageGroup, drills, warmUp, coolDown, pdfUrl |
| ScheduledClass | `lib/models/scheduled_class_model.dart` | id, templateId, coachId, dateTime, venue, studentIds |
| ActiveSession | `lib/models/active_session_model.dart` | id, classId, startTime, attendance, sessionNotes |
| DrillAnimationData | `lib/models/drill_animation_data.dart` | players, balls, equipment, durationMs |
| Notification | `lib/models/notification_model.dart` | id, title, body, targetRole, timestamp |

### 5.3.3 Sequence Diagram to Method Implementation

The sequence diagrams illustrating system interactions were implemented as method calls across services and view models. The following table maps key sequence diagram interactions to their code implementations:

**Table 5.8: Sequence Diagram to Method Mapping**

| Sequence Diagram | Interaction | Implementation Method |
|------------------|-------------|----------------------|
| User Authentication | LoginView → AuthViewModel | `AuthViewModel.signIn(email, password)` |
| User Authentication | AuthService → Firebase Auth | `FirebaseAuth.instance.signInWithEmailAndPassword()` |
| Schedule Class | ScheduleViewModel → Firestore | `FirestoreService.createScheduledClass()` |
| Start Session | SessionViewModel → Firestore | `FirestoreService.createActiveSession()` |
| Generate Animation | GeminiAnimationService → Gemini API | `GeminiAnimationService.generateDrillAnimation()` |
| Send Notification | NotificationService → Cloud Functions | `NotificationService.sendBroadcast()` |

### 5.3.4 Database Schema Implementation

The Entity-Relationship Diagram (ERD) designed in Chapter 4 was implemented as Firestore collections. Due to Firestore's NoSQL document-based structure, relationships are maintained through document references rather than foreign keys.

**Table 5.9: ERD to Firestore Collection Mapping**

| ERD Entity | Firestore Collection | Document Structure |
|------------|---------------------|-------------------|
| User | `users` | `{uid, email, name, role, childIds[], fcmToken}` |
| SessionTemplate | `sessionTemplates` | `{id, title, ageGroup, drills[], warmUp, coolDown, pdfUrl, animationData}` |
| ScheduledClass | `scheduledClasses` | `{id, templateId (ref), coachId (ref), dateTime, venue, studentIds[]}` |
| ActiveSession | `activeSessions` | `{id, classId (ref), startTime, endTime, attendance{}, notes[]}` |
| Notification | `notifications` | `{id, title, body, targetRole, sentBy, timestamp}` |

### 5.3.5 AI Integration Implementation

The AI-powered features represent a key innovation in the GoalBuddy system. Two distinct Gemini API integrations were implemented:

**1. PDF Lesson Plan Extraction (`lib/services/gemini_pdf_service.dart`)**

This service uses Gemini 2.0 Flash's multimodal capabilities to extract structured data from PDF lesson plans:

```dart
// Simplified implementation excerpt
Future<String?> extractLessonPlan(Uint8List pdfBytes) async {
  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: _apiKey,
  );

  final prompt = '''
  Extract the following from this PDF lesson plan:
  - Title, Age Group, Duration
  - Warm-up activities
  - Main drills with descriptions
  - Cool-down activities
  Return as JSON format.
  ''';

  final response = await model.generateContent([
    Content.multi([
      TextPart(prompt),
      DataPart('application/pdf', pdfBytes),
    ])
  ]);

  return response.text;
}
```

**2. Drill Animation Generation (`lib/services/gemini_animation_service.dart`)**

This service converts textual drill descriptions into structured animation data:

```dart
// Simplified implementation excerpt
Future<DrillAnimationData?> generateDrillAnimation(String description) async {
  final prompt = '''
  Generate animation data for this football drill: "$description"

  Return JSON with:
  - players: [{label, color, path: [{x, y, timeMs}]}]
  - balls: [{path: [{x, y, timeMs}]}]
  - equipment: [{type, position: {x, y}, color}]
  - durationMs: total animation duration
  ''';

  final response = await model.generateContent([Content.text(prompt)]);
  return DrillAnimationData.fromJson(jsonDecode(response.text));
}
```

**3. Animation Rendering (`lib/widgets/drill_animation_player.dart`)**

The generated animation data is rendered using Flutter's CustomPainter, providing a safe execution environment that only interprets data without executing any generated code:

```dart
class DrillAnimationPainter extends CustomPainter {
  final DrillAnimationData animationData;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw equipment (cones, goals)
    for (var equip in animationData.equipment) {
      _drawEquipment(canvas, size, equip);
    }

    // Draw player paths and current positions
    for (var player in animationData.players) {
      _drawPlayer(canvas, size, player, currentTimeMs);
    }

    // Draw ball trajectory
    for (var ball in animationData.balls) {
      _drawBall(canvas, size, ball, currentTimeMs);
    }
  }
}
```

## 5.4 System Testing

This section describes the testing methodologies employed to validate the functionality, usability, and reliability of the GoalBuddy application. The testing approach focused on manual testing, static code analysis, and comprehensive User Acceptance Testing (UAT).

### 5.4.1 Testing Approach Overview

**Table 5.10: Testing Methods Employed**

| Testing Type | Description | Tools Used |
|--------------|-------------|------------|
| Manual Integration Testing | End-to-end testing of features on physical device | OnePlus 11, Firebase Console |
| Static Code Analysis | Automated code quality checks | Flutter Analyzer (dart analyze) |
| User Acceptance Testing | Real user evaluation with target audience | Google Forms, SUS Questionnaire |

### 5.4.2 Manual Integration Testing

Manual integration testing was conducted throughout the development process using the OnePlus 11 Android device. Each feature was tested in realistic scenarios to ensure proper functionality and data flow between system components.

**Table 5.11: Integration Test Scenarios**

| Test Scenario | Components Tested | Expected Result | Status |
|---------------|-------------------|-----------------|--------|
| User Login Flow | Firebase Auth → Firestore → Dashboard | User authenticated and redirected to role-specific dashboard | Pass |
| Create Template with PDF | File Picker → Gemini API → Firestore | PDF extracted, data populated, template saved | Pass |
| Generate Drill Animation | Gemini API → Animation Parser → CustomPainter | Animation renders correctly from text description | Pass |
| Schedule Class | Template Selection → Date Picker → Firestore | Class created with template reference | Pass |
| Start Active Session | Class Data → Session Creation → Timer | Session started, timer functional | Pass |
| Take Attendance | Student List → Checkbox → Firestore | Attendance recorded in real-time | Pass |
| Send Push Notification | Admin Input → Cloud Function → FCM | Notification received on target devices | Pass |
| View Child Progress | Parent Login → Firestore Query → UI Display | Session history and notes displayed | Pass |

### 5.4.3 Static Code Analysis

Static code analysis was performed using Flutter's built-in analyzer (`flutter analyze`) to identify potential issues, enforce coding standards, and ensure type safety throughout the codebase.

**Analysis Results:**
- **Initial Issues Identified:** Various warnings including unused imports, deprecated APIs, and type inconsistencies
- **Resolution Approach:** AI-assisted debugging using Claude Code to identify and fix issues systematically
- **Final Status:** All critical warnings resolved; code passes analysis with no errors

**Common Issues Resolved:**
1. **Unused Imports:** Removed unnecessary import statements across view files
2. **Null Safety:** Added proper null checks for Firebase document snapshots
3. **Deprecated APIs:** Updated to current Flutter/Firebase API conventions
4. **Type Annotations:** Added explicit types where inference was ambiguous

### 5.4.4 User Acceptance Testing (UAT)

User Acceptance Testing was conducted with real stakeholders representing all three user roles (Admin, Coach, Parent) to validate that the system meets its intended requirements and provides a satisfactory user experience.

#### 5.4.4.1 UAT Methodology

The UAT was conducted using the following approach:

1. **Participant Recruitment:** Stakeholders from Little Kickers academy and parents were invited to participate
2. **Consent Collection:** All participants provided informed consent for participation and recording preferences
3. **Role-Based Testing:** Each participant tested features specific to their assigned role
4. **Task Completion:** Participants completed predefined tasks while being observed
5. **Survey Completion:** Participants filled out a Google Forms questionnaire including role-specific questions and the System Usability Scale (SUS)
6. **Interview (Selected Participants):** Semi-structured interviews were conducted with selected participants for deeper insights

#### 5.4.4.2 UAT Participants

**Table 5.12: UAT Participant Demographics**

| # | Name | Role | Tech Comfort Level | Uses Sports Apps |
|---|------|------|-------------------|------------------|
| 1 | Ahmad Tarmidzi | Coach | Very Comfortable | No |
| 2 | Muhammad Ikmal Bin Azlan | Coach | Very Comfortable | No |
| 3 | ELENA GOH LING YIN | Admin | Comfortable | No |
| 4 | ELENA GOH LING YIN | Coach | Very Comfortable | No |
| 5 | Aaron | Parent | Very Comfortable | No |
| 6 | Maisarah Mustafa | Parent | Very Comfortable | No |
| 7 | Awatif Izanie | Parent | Very Comfortable | No |
| 8 | Nasrul | Parent | Very Comfortable | No |
| 9 | Ahmad Adha | Coach | Very Comfortable | No |
| 10 | Kanason RA | Admin | Very Comfortable | No |
| 11 | Yusnita | Admin | Neutral | No |

**Total Participants:** 11 (Note: ELENA GOH tested both Admin and Coach roles)

**Participant Distribution by Role:**
- Coaches: 4 participants
- Admins: 3 participants
- Parents: 4 participants

#### 5.4.4.3 Role-Specific Feature Testing Results

**Coach Role Testing Results (4 participants)**

**Table 5.13: Coach Feature Ratings (Scale 1-5)**

| Feature | Ahmad Tarmidzi | Muhammad Ikmal | ELENA GOH | Ahmad Adha | Average |
|---------|----------------|----------------|-----------|------------|---------|
| Dashboard clearly shows schedule | 5 | 5 | 5 | 5 | 5.00 |
| Starting a session was straightforward | 5 | 5 | 5 | 5 | 5.00 |
| Timer is easy to see and control | 5 | 5 | 5 | 4 | 4.75 |
| Drill animations/visuals are helpful | 5 | 5 | 5 | 5 | 5.00 |
| Marking attendance is quick and easy | 5 | 5 | 5 | 5 | 5.00 |
| Drill library is easy to search | 5 | 5 | 5 | 4 | 4.75 |
| Could use app during real training | 5 | 4 | 5 | 5 | 4.75 |

**Admin Role Testing Results (3 participants)**

**Table 5.14: Admin Feature Ratings (Scale 1-5)**

| Feature | ELENA GOH | Kanason RA | Yusnita | Average |
|---------|-----------|------------|---------|---------|
| Creating session templates is intuitive | 4 | 4 | 4 | 4.00 |
| Scheduling classes is straightforward | 5 | 5 | 4 | 4.67 |
| Managing students/coaches is easy | 5 | 4 | 3 | 4.00 |
| Dashboard layout makes sense | 5 | 5 | 4 | 4.67 |
| Finance and analytics provide useful info | 3 | 5 | 4 | 4.00 |
| Can quickly find classes to manage | 4 | 5 | 5 | 4.67 |
| FAB/red plus button is easy to use | 5 | 5 | 3 | 4.33 |

**Parent Role Testing Results (4 participants)**

**Table 5.15: Parent Feature Ratings (Scale 1-5)**

| Feature | Aaron | Maisarah | Awatif | Nasrul | Average |
|---------|-------|----------|--------|--------|---------|
| Can easily find child's upcoming classes | 5 | 5 | 5 | 5 | 5.00 |
| Class information is clear | 5 | 5 | 5 | 5 | 5.00 |
| Progress/badges section is meaningful | 5 | 5 | 5 | 5 | 5.00 |
| Understand what skills child is developing | 5 | 5 | 5 | 5 | 5.00 |
| Schedule view is easy to navigate | 5 | 5 | 5 | 5 | 5.00 |
| Switching between tabs is intuitive | 5 | 5 | 5 | 5 | 5.00 |
| Can easily check if child attended class | 5 | 5 | 5 | 5 | 5.00 |

#### 5.4.4.4 System Usability Scale (SUS) Evaluation

The System Usability Scale (SUS) is a widely-used, standardized questionnaire for measuring perceived usability. It consists of 10 statements rated on a 5-point Likert scale (1 = Strongly Disagree, 5 = Strongly Agree). The SUS score is calculated using the following formula:

- For odd-numbered questions (positive statements): Score contribution = (Rating - 1)
- For even-numbered questions (negative statements): Score contribution = (5 - Rating)
- Final SUS Score = (Sum of all contributions) × 2.5

**Table 5.16: SUS Questions**

| # | Statement | Type |
|---|-----------|------|
| Q1 | I think that I would like to use this app frequently | Positive |
| Q2 | I found the app unnecessarily complex | Negative |
| Q3 | I thought the app was easy to use | Positive |
| Q4 | I think that I would need support of a technical person to use this app | Negative |
| Q5 | I found the various functions in this app were well integrated | Positive |
| Q6 | I thought there was too much inconsistency in this app | Negative |
| Q7 | I would imagine that most people would learn to use this app very quickly | Positive |
| Q8 | I found the app very cumbersome to use | Negative |
| Q9 | I felt very confident using the app | Positive |
| Q10 | I needed to learn a lot of things before I could get going with this app | Negative |

**Table 5.17: Individual SUS Scores**

| # | Participant | Role | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | Q8 | Q9 | Q10 | SUS Score |
|---|-------------|------|----|----|----|----|----|----|----|----|----|----|-----------|
| 1 | Ahmad Tarmidzi | Coach | 4 | 1 | 5 | 1 | 5 | 1 | 4 | 2 | 4 | 1 | **90.0** |
| 2 | Muhammad Ikmal | Coach | 4 | 2 | 5 | 1 | 5 | 2 | 4 | 1 | 5 | 1 | **90.0** |
| 3 | ELENA GOH | Admin | 5 | 3 | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 2 | **92.5** |
| 4 | ELENA GOH | Coach | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | **100.0** |
| 5 | Aaron | Parent | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | **100.0** |
| 6 | Maisarah Mustafa | Parent | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 2 | **97.5** |
| 7 | Awatif Izanie | Parent | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | **100.0** |
| 8 | Nasrul | Parent | 5 | 1 | 5 | 2 | 5 | 1 | 5 | 1 | 5 | 1 | **97.5** |
| 9 | Ahmad Adha | Coach | 4 | 1 | 4 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | **95.0** |
| 10 | Kanason RA | Admin | 4 | 1 | 5 | 1 | 5 | 2 | 5 | 1 | 4 | 2 | **90.0** |
| 11 | Yusnita | Admin | 4 | 2 | 5 | 1 | 5 | 2 | 5 | 2 | 4 | 2 | **85.0** |

**Table 5.18: SUS Score Summary by Role**

| Role | Number of Participants | Average SUS Score | Rating |
|------|------------------------|-------------------|--------|
| Coach | 4 | 93.75 | Excellent (Grade A) |
| Admin | 3 | 89.17 | Excellent (Grade A) |
| Parent | 4 | 98.75 | Best Imaginable (Grade A+) |
| **Overall** | **11** | **94.32** | **Excellent (Grade A+)** |

**SUS Score Interpretation Scale:**

| Score Range | Adjective Rating | Grade |
|-------------|------------------|-------|
| 90-100 | Best Imaginable | A+ |
| 80-89 | Excellent | A |
| 68-79 | Good | B |
| 51-67 | OK | C |
| Below 51 | Poor | F |

The overall SUS score of **94.32** indicates that the GoalBuddy application achieves **"Excellent" to "Best Imaginable"** usability, placing it in the **Grade A+** category. This score significantly exceeds the industry average SUS score of 68.

#### 5.4.4.5 UI/UX Evaluation Results

**Table 5.19: UI/UX Ratings (Scale 1-5)**

| Aspect | Average Rating | Standard Deviation |
|--------|----------------|-------------------|
| The app looks professional | 4.73 | 0.47 |
| I understand what all buttons and icons do | 4.73 | 0.47 |
| The colors and design are appropriate | 4.91 | 0.30 |
| Overall experience | 4.91 | 0.30 |

#### 5.4.4.6 Qualitative Feedback

**Table 5.20: User Comments and Suggestions**

| Participant | Role | Comment/Suggestion |
|-------------|------|-------------------|
| Ahmad Tarmidzi | Coach | "Excellent app!" |
| Muhammad Ikmal | Coach | "Already perfect :)" |
| ELENA GOH | Admin | "The Payment - To be secure to add the receipt as the proof of the payment" |
| Aaron | Parent | "I thought the introduction of the app would be very good for parents. It allows parents access to many items in the app and everything is in 1 place." |
| Maisarah Mustafa | Parent | "Can include announcement (if any)" |
| Awatif Izanie | Parent | "Clean design with a straightforward user flow." |
| Nasrul | Parent | "Function to change class/time without the need to inform admin manually." |
| Ahmad Adha | Coach | "I hope it can be implemented soon in Little Kickers" |

#### 5.4.4.7 Interview Findings

Semi-structured interviews were conducted with four selected participants representing different user roles to gather deeper qualitative insights into their experience with the GoalBuddy application. The interviews followed a semi-structured format with role-specific questions.

**Table 5.21: Interview Participants**

| Participant | Role | Experience | Date |
|-------------|------|------------|------|
| Ahmad Tarmidzi | Coach | Little Kickers Coach | 20/01/2026 |
| Muhammad Ikmal | Coach | Part-time Coach (1+ year) | 20/01/2026 |
| Aaron Craig | Parent | Parent of Sammy Craig | 20/01/2026 |
| Elena Goh | Admin/Coach | Admin (3 years), Coach (4 years) | 20/01/2026 |

---

**Interview 1: Coach Ahmad Tarmidzi**

*Role: Coach at Little Kickers*

**Q: What was the easiest part of using the app?**
> "The easiest part is the looking for the drill sessions. Very, very, very easy. Very specific place to see."

**Q: What was the hardest or most confusing part?**
> "The most confusing part is the finish flag over the top because it's a bit confusing because it's just a random flag."

**Q: What feature would you use most often?**
> "I would use the timer feature."

**Q: Would you actually use the active session timer during a real class with kids running around?**
> "Yes, I would use it because while I'm looking at the lesson plan, I can simultaneously looking at the timer so that I don't overrun the class or end the class a bit early, end the session a bit early."

**Q: Tell me about the drill animations. Were they helpful or distracting?**
> "The drill animation is actually very, very good. I'm actually amazed when I first saw the animation. It looks very, very nice and I think it helps me to imagine running the drill a bit better."

**Q: Is it the same as the PDF session plans?**
> "No, this app that I'm currently testing is way, way better."

**Q: How was the attendance marking experience?**
> "It was actually pretty good, much better than the ones I'm currently using right now."

**Q: Is there anything else you wanted to mention?**
> "I think everything has been asked, everything has been covered. I think the app is very good so kudos to Adli for creating this app. I think it's gonna help a lot of people for their training session in the future."

---

**Interview 2: Coach Muhammad Ikmal**

*Role: Part-time Coach at Little Kickers (1+ year experience)*

**Q: What was the easiest part of using the app?**
> "I find that the app shows all the necessary information that I need in the dashboard itself, so I don't need to open any specific section of the app to, for example, look at my salary or look at any of the drills. I can just see everything from my dashboard, which is quite handy, I think."

**Q: Did you get stuck at any point?**
> "I find the user interface very user-friendly so I don't think it was very difficult to navigate through the app."

**Q: What feature would you use most often?**
> "I think what's really helpful with the app is that it can track my salary. So sometimes it is easier but right now I just keep track of my salary by keying in my rate in my notes manually. So with this app which everything is automated, it's really quite helpful I think."

**Q: What's missing that you expected to see?**
> "From the app, I noticed that the amount of students is not accurate. So I hope to see some improvement on that. But overall, the concept is there."

**Q: Would you actually use the active session timer during a real class?**
> "Well, as a coach, it is my job to maintain the class sessions and to make sure that the timing is right. So sometimes I find it hard when I'm focusing on the other kids and maybe I'm not looking at my watch. Sometimes it can be very easy to go over the time limit. So with this app, and it has the ringer feature, so whenever the timer runs out, it rings me. Even when I'm distracted, it tells me straight away that I'm over the time limit. So it's quite helpful, I think."

**Q: Tell me about the drill animations. Were they helpful or distracting?**
> "When I look at the animations, I find it very, very helpful. Like for the lesson plans that we have now, it is all just static pictures. So we have no animations and very long bodies of text. For example, let's say I forget how the lesson plan goes for a specific game, it is not very time efficient for me to read back all the bodies of text. So just looking at the animation is quite enough for me to know how the game goes, how to set up the game, which helps with my time management as well."

**Q: How was the attendance marking experience compared to what you're using now?**
> "For right now, what we're using is Excel. We're using Microsoft Excel to log all the attendance for all the kids. So right now, we need to manually key in. So we need to look for the names and we need to mark it. It takes a few buttons to complete the activity. So you have to click on the button, click on the name and click present. It was all manual. So with the app, GoalBuddy, all the names of the kids are there. So it is a one button action, one tap. So I just click check, check, check, check, check. So it's very easy to use."

**Q: Is there anything else you wanted to mention?**
> "Maybe in terms of improvement, we could add something like a section where you can see all the other coaches working on what session at the time. So for right now, I can only see my own. For example, maybe I don't know which coach is absent or which coach is unable to make it for the session. So hopefully I can see that and the other coaches can put their reasoning in the app, why they are absent, why they cannot make it. So just in case, if anything happens, I can be there to replace them. Maybe you can have something like a notification system for that, so just in case if any one of the coaches are on medical leave or an emergency leave, they can straight away notify the app and it can notify all the other coaches so the coaches can quickly replace the other coaches."

**Q: On a scale of 1 to 5, how likely are you to use this app once it's fully launched?**
> "I find myself using the app in the future which helps automates a lot of procedures that we're doing right now and I think this can be very useful for other coaches, not just in Little Kickers but also in other organizations as well."

---

**Interview 3: Parent Aaron Craig**

*Role: Parent of Sammy Craig at Little Kickers Putrajaya*

**Q: What was the easiest part of using the app?**
> "Just the fact that everything's in one place and the navigation through the buttons and the different pages are easy to use."

**Q: Do you think there's a hard part? Is there a big learning curve?**
> "No, I think it was very straightforward and simple for parents to access quite quickly their child's progress, being able to pay fees and the attendance of their child on the campus."

**Q: Would you check this app regularly? What would motivate you to open it?**
> "I would use it daily, just to obviously check my child's progress and what skills they need to develop for the next coming week, but also use it monthly to pay fees."

**Q: How do you currently stay informed about your child's class and progress?**
> "Child's progress is very difficult at the moment because there's no app in place. You're just relying on the WhatsApp group that I'm in and that's usually how I pay fees. But for child's progress, I'm not quite sure at what level he's at."

**Q: What additional information about your child's training would you like to see?**
> "I think more of like a development, so skills that they need to work towards in the coming weeks or coming months and just so we can practice at home also."

**Q: The app shows class time, venue and coach. Is that enough information?**
> "Yeah, I think it's suitable for the children of this age to know just what class they need to attend and what day. I don't think it needs to be any more details or then it gets more complicated."

**Q: Is there anything else you want to mention?**
> "No, I just think after navigating through the app as a demo, I thought it was a very niche thing to include in Little Kickers, and I think it would be beneficial to parents, coaches, and admin."

---

**Interview 4: Admin/Coach Elena Goh**

*Role: Admin (3 years) and Coach (4 years) at Little Kickers*

**Q: What was the easiest part of using the app?**
> "It made me easy to find the classes and also especially for the coaches, it saved a lot of my time, which is I don't need to do manually for their payment and also the monthly hours of how many hours they have been working."

**Q: Did you get stuck at any point?**
> "When I first time use it, I don't feel any stuck or hard but mostly it's an easy way for me to use."

**Q: Would you actually use the active session timer during a real class? (Coach perspective)**
> "For me as a coach, I will use it because it much more easier and help me for the whole session."

**Q: Tell me about the drill animations. Were they helpful or distracting?**
> "Animation, they basically help me because someone like me, I think it's better for me to look at animation instead of wording."

**Q: Walk me through how you currently create session plans and schedule classes. (Admin perspective)**
> "Okay, for currently I am using manually by Google Sheet. So I will make sure all the coaches fill up. Every Monday I have to send a reminder. Every weekly I will need to ask the coaches whoever are free and this takes a lot of my time to keep chasing the coaches to keep me update about their availability. So it kind of hard for me to do manually right now. By app, I think it will be helpful for me in terms of saving my time and also I don't need to chase the coaches to update every weekly to me."

**Q: Tell me about creating the session template. Was it easy?**
> "Yeah, for me it's easy just one click of upload the PDF."

**Q: You have access to finance and analytics. What data would actually be useful to you?**
> "The first thing is about the attendance. I can check how many percent is already attended. I also can check about the student distribution, the Mega Kicker, Junior, different classes. And then about the finance, I can check every weekly. Coach personally have already earned how much every month. Won't have any mistake count about their payment income. And then for the student fees also easy for me because I can check whoever have paid and then whoever haven't paid stay pending. So just one dashboard easy for me to check."

**Q: Is there anything else you wanted to mention?**
> "I would like to mention just for the finance, maybe because we need a proof of the payment, which is we cannot just one click and then just click that payment already paid. I think maybe we can just have a feature where we can upload the receipt as a proof that they already made a payment. From the receipt we also can check which date that they already made the payment and then we can check in the bank is it accurate same date or not."

---

**Interview Analysis Summary**

The qualitative data gathered from the interviews revealed several consistent themes across all participants:

**Table 5.22: Key Interview Themes**

| Theme | Evidence | Frequency |
|-------|----------|-----------|
| **Ease of Use** | All participants found the app intuitive with minimal learning curve | 4/4 (100%) |
| **Dashboard Efficiency** | Consolidated information reduces navigation needs | 3/4 (75%) |
| **Timer Usefulness** | Coaches valued the session timer with alert feature | 3/3 coaches (100%) |
| **Animation Appreciation** | Drill animations preferred over static images/text | 3/3 coaches (100%) |
| **Attendance Improvement** | Digital attendance significantly faster than Excel | 2/3 coaches (67%) |
| **Time Savings** | App reduces manual administrative work | 3/4 (75%) |
| **Real-world Applicability** | Participants would use the app in actual operations | 4/4 (100%) |

**Key Insights by Role:**

1. **Coaches:**
   - The drill animations were unanimously praised as "very, very helpful" and "way better" than static PDF lesson plans
   - The timer feature with audio alerts addresses a real pain point of time management during sessions
   - One-tap attendance marking is a significant improvement over manual Excel tracking
   - Suggestion: Add visibility into other coaches' schedules for emergency replacements

2. **Parents:**
   - Current communication via WhatsApp groups is inadequate for tracking child progress
   - Would use the app daily for progress tracking and monthly for fee payments
   - Class information (time, venue, coach) is sufficient; more details would overcomplicate
   - Values having "everything in one place"

3. **Admins:**
   - Current Google Sheet workflow requires constant follow-up with coaches
   - App automates coach availability tracking and payment calculations
   - Finance dashboard provides at-a-glance visibility into attendance and payments
   - Suggestion: Add receipt upload feature for payment verification

---

## 5.5 Results and Discussion

This section presents a comprehensive analysis of the implementation outcomes and testing results, discussing how the GoalBuddy application addresses the identified problems and meets the project objectives.

### 5.5.1 Achievement of Project Objectives

**Table 5.23: Objective Achievement Assessment**

| Objective | Implementation | Evidence | Status |
|-----------|----------------|----------|--------|
| **O1:** Develop role-based dashboards | Three distinct dashboards (Admin, Coach, Parent) with role-specific features | UAT feature ratings averaging 4.67-5.00 across roles | ✓ Achieved |
| **O2:** Implement AI-powered template creation | Gemini integration for PDF extraction and drill animation generation | Successful extraction and animation rendering demonstrated | ✓ Achieved |
| **O3:** Create session management workflow | Active session module with timer, attendance, and notes | Coach feature ratings: 4.75-5.00 average | ✓ Achieved |
| **O4:** Enable parent progress tracking | Progress view with session history and coach feedback | Parent feature ratings: 5.00 across all features | ✓ Achieved |
| **O5:** Implement push notifications | FCM integration with Cloud Functions | Notification delivery tested and verified | ✓ Achieved |

### 5.5.2 Usability Analysis

The SUS evaluation results demonstrate exceptional usability across all user roles:

**1. Overall Usability (SUS = 94.32)**

The overall SUS score of 94.32 places the GoalBuddy application in the top percentile of usability scores. According to Bangor, Kortum, and Miller's (2009) adjective rating scale, scores above 90 correspond to "Best Imaginable" usability. This result indicates that:

- Users find the application intuitive and easy to learn
- The interface is well-integrated and consistent
- Users feel confident using the application
- Technical support is not required for basic operation

**2. Role-Based Usability Comparison**

The Parent role achieved the highest average SUS score (98.75), followed by Coach (93.75) and Admin (89.17). This distribution aligns with the complexity gradient of each role:

- **Parents** interact with the simplest feature set (view-only operations), resulting in a straightforward user experience
- **Coaches** have moderate complexity (session management, attendance), achieving excellent scores
- **Admins** have the most complex feature set (template creation, scheduling, user management), yet still achieve excellent usability

**3. Feature Satisfaction**

Role-specific feature ratings reveal high satisfaction across all functionalities:

- Coach features average: 4.89/5.00 (97.8% satisfaction)
- Admin features average: 4.33/5.00 (86.6% satisfaction)
- Parent features average: 5.00/5.00 (100% satisfaction)

### 5.5.3 AI Integration Effectiveness

The AI-powered features represent a distinguishing innovation of the GoalBuddy system:

**1. PDF Lesson Plan Extraction**

The Gemini-powered PDF extraction successfully converts coach lesson plans into structured template data, reducing manual data entry time. Key benefits observed:

- Automatic extraction of drill names, descriptions, and timing
- Support for various PDF formats and layouts
- Editable results allowing coach refinement

**2. Drill Animation Generation**

The text-to-animation feature transforms drill descriptions into visual representations:

- Natural language input enables non-technical users to create animations
- Generated animations aid visual learners in understanding drill execution
- CustomPainter implementation ensures safe, sandboxed rendering

### 5.5.4 Addressing Identified Problems

**Table 5.24: Problem Resolution Assessment**

| Problem (from Chapter 1) | Solution Implemented | User Validation |
|--------------------------|---------------------|-----------------|
| Paper-based record keeping | Digital session templates and Firestore database | Admin ratings: 4.67/5.00 for scheduling |
| Communication gaps between coaches and parents | Push notifications and parent dashboard | Parent comment: "everything is in 1 place" |
| Lack of visual training aids | AI-generated drill animations | Coach rating: 5.00/5.00 for animations |
| Inconsistent session delivery | Standardized templates with predefined drills | Coach rating: 5.00/5.00 for session starting |
| Manual attendance tracking | Digital attendance with real-time sync | Coach rating: 5.00/5.00 for attendance |

### 5.5.5 User Feedback Analysis

The qualitative feedback collected reveals several themes:

**Positive Feedback:**
- Clean, professional design (Awatif: "Clean design with a straightforward user flow")
- Comprehensive feature set (Aaron: "allows parents access to many items... everything is in 1 place")
- Ready for real-world deployment (Ahmad Adha: "I hope it can be implemented soon")

**Suggested Improvements:**
1. **Payment Receipt Integration** (ELENA GOH): Add receipt upload/verification for payment tracking
2. **Announcement Feature** (Maisarah): Dedicated announcement section for general updates
3. **Self-Service Class Changes** (Nasrul): Allow parents to reschedule without admin intervention

These suggestions provide valuable direction for future development iterations.

### 5.5.6 Limitations and Challenges

**1. Testing Scope**
- Testing was conducted on a single Android device (OnePlus 11)
- iOS testing was not performed due to hardware constraints
- Sample size of 11 participants may not represent all user demographics

**2. AI Integration Challenges**
- Gemini API responses occasionally require JSON cleanup
- Animation generation quality varies based on input description specificity
- API rate limits may affect high-volume usage scenarios

**3. Technical Constraints**
- Real-time synchronization requires stable internet connectivity
- Push notifications depend on device settings and FCM token validity
- PDF extraction accuracy depends on document formatting

## 5.6 Summary

This chapter documented the implementation of the GoalBuddy application, demonstrating the successful translation of system design into a functional mobile application. The development environment consisted of a high-performance desktop computer running Windows 11 with Flutter SDK 3.29.2, tested on a OnePlus 11 Android device.

The implementation followed the MVVM architectural pattern, with clear mapping between design artifacts (use cases, class diagrams, sequence diagrams) and code components. The AI integration utilizing Google's Gemini 2.0 Flash model was successfully implemented for both PDF extraction and drill animation generation.

Testing was conducted through manual integration testing, static code analysis using Flutter Analyzer, and comprehensive User Acceptance Testing with 11 participants across all three user roles. The System Usability Scale evaluation achieved an exceptional score of 94.32, indicating "Excellent" to "Best Imaginable" usability.

The results demonstrate that the GoalBuddy application successfully addresses the identified problems and achieves all project objectives. User feedback was overwhelmingly positive, with specific suggestions for future enhancements providing clear direction for continued development. The application is considered ready for pilot deployment at the Little Kickers football academy.
