# CHAPTER 4: SYSTEM ANALYSIS AND DESIGN

## 4.1 Introduction

This chapter presents the system analysis and design of GoalBuddy - Little Kickers Coach Companion, a comprehensive mobile application designed to streamline football coaching academy operations. The application serves as an integrated platform connecting administrators, coaches, and parents through role-based interfaces tailored to their specific needs.

GoalBuddy operates on a role-based authentication system where users are directed to their respective dashboards upon login. Administrators access a centralized management console that enables them to register coaches and students, create reusable session templates, schedule classes, and broadcast notifications to the academy community. The system automatically calculates student age groups based on their date of birth and assigns them to appropriate classes, ensuring proper skill-level grouping across four categories: Little Kicks (1.5-2.5 years), Junior Kickers (2.5-3.5 years), Mighty Kickers (3.5-5 years), and Mega Kickers (5-8 years).

Coaches interact with the application through a session-focused dashboard displaying their assigned classes as lead or assistant coach. When conducting sessions, coaches utilize the active session interface featuring a countdown timer, drill-by-drill navigation, and optional AI-generated animations demonstrating drill movements. The attendance marking system allows coaches to record student presence with a simple toggle interface, automatically updating both session records and individual student attendance histories.

Parents access a child-centric dashboard displaying their enrolled student's schedule, attendance statistics, earned badges, and payment status. The notification system keeps parents informed about scheduled classes, announcements, and reminders through push notifications delivered via Firebase Cloud Messaging.

A distinguishing feature of GoalBuddy is its integration with Google Gemini AI, enabling intelligent automation of administrative tasks. Administrators can upload PDF lesson plans which the AI extracts and structures into session templates, automatically populating drill details, instructions, and equipment requirements. Additionally, the AI generates tactical animations from drill descriptions, providing visual aids for coaches to demonstrate movements to young children.

The system architecture follows the Model-View-ViewModel (MVVM) pattern built on Flutter framework, ensuring cross-platform compatibility across Android, iOS, and web browsers. Firebase provides the backend infrastructure including authentication, real-time database synchronization through Cloud Firestore, file storage, and serverless Cloud Functions for automated notification triggers.


## 4.2 Analysis of Existing Systems

Before developing GoalBuddy, an analysis of existing coaching management solutions was conducted to identify gaps in the market.

TeamSnap offers good scheduling and team communication features but lacks a drill library and AI capabilities while being expensive for small academies. SportsEngine provides comprehensive sports management but has a complex user interface not designed for young children coaching environments. CoachNow focuses on video analysis features but offers limited attendance tracking and no dedicated parent portal. Traditional paper-based systems, while simple and requiring no technology, are error-prone, lack real-time updates, and make data analysis difficult.

The gap analysis revealed that none of the existing systems provide AI-powered lesson plan extraction from PDF documents, AI-generated drill animations for visual demonstration, age-group specific session management for toddlers and young children, integrated parent communication with progress tracking, or receipt analysis for payment verification. GoalBuddy fills these gaps by providing a comprehensive solution specifically designed for youth football academies.


## 4.3 Requirements Elicitation

The requirements are the descriptions of the system services and constraints that were gathered through stakeholder interviews with academy administrators, coaches, and parents.

### 4.3.1 Functional Requirements

Functional requirements define what the system must do. They are organized by module and user role.

**Table 4.1: Authentication Module Requirements**

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| FR-AUTH-01 | User Login | The system shall allow users to login using email and password | High |
| FR-AUTH-02 | Google Sign-In | The system shall support Google OAuth authentication | Medium |
| FR-AUTH-03 | Role-Based Access | The system shall redirect users to role-specific dashboards (Admin, Coach, Parent) | High |
| FR-AUTH-04 | Session Persistence | The system shall maintain user sessions across app restarts | High |
| FR-AUTH-05 | Logout | The system shall allow users to securely logout and clear session data | High |

**Table 4.2: Admin Module Requirements**

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| FR-ADM-01 | Register Coach | Admin shall be able to register new coaches with name, email, phone, and hourly rate | High |
| FR-ADM-02 | Register Student | Admin shall be able to register students with name, DOB, parent contact, and medical notes | High |
| FR-ADM-03 | Auto Age Group | The system shall automatically calculate and assign age groups based on date of birth | High |
| FR-ADM-04 | Create Template | Admin shall be able to create session templates with drills manually | High |
| FR-ADM-05 | PDF Autofill | The system shall extract lesson plan data from uploaded PDF using AI (Gemini) | High |
| FR-ADM-06 | AI Animation | The system shall generate drill animations using AI based on drill instructions | Medium |
| FR-ADM-07 | Schedule Class | Admin shall be able to schedule classes from templates with date, time, venue, and coaches | High |
| FR-ADM-08 | Auto-Assign Students | The system shall automatically assign students to classes based on age group | High |
| FR-ADM-09 | Send Notifications | Admin shall be able to send broadcast notifications to coaches or parents | High |
| FR-ADM-10 | View Analytics | Admin shall be able to view system analytics including attendance rates and student counts | Medium |

**Table 4.3: Coach Module Requirements**

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| FR-COA-01 | View Sessions | Coach shall see assigned sessions (as lead or assistant) on dashboard | High |
| FR-COA-02 | Start Session | Coach shall be able to start an active session with timer and drill display | High |
| FR-COA-03 | Session Timer | The system shall display countdown timer for each drill with pause/resume | High |
| FR-COA-04 | Drill Navigation | Coach shall be able to navigate between drills (next/previous) | High |
| FR-COA-05 | Play Animation | Coach shall be able to play drill animations during active session | Medium |
| FR-COA-06 | Mark Attendance | Coach shall be able to mark students as present or absent | High |
| FR-COA-07 | View Student Profile | Coach shall be able to view student details, badges, and medical notes | Medium |
| FR-COA-08 | Add Notes | Coach shall be able to add notes to student profiles | Medium |
| FR-COA-09 | Complete Session | Coach shall be able to mark session as complete and archive it | High |
| FR-COA-10 | Browse Drills | Coach shall be able to browse drill library with filters | Low |

**Table 4.4: Parent Module Requirements**

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| FR-PAR-01 | View Dashboard | Parent shall see child's name, age group, and attendance summary | High |
| FR-PAR-02 | View Schedule | Parent shall see upcoming class schedule with date, time, and venue | High |
| FR-PAR-03 | View Attendance | Parent shall see attendance history with present/absent records | High |
| FR-PAR-04 | View Badges | Parent shall see earned badges with descriptions | Medium |
| FR-PAR-05 | View Notifications | Parent shall receive and view notifications about classes and announcements | High |
| FR-PAR-06 | Mark Read | Parent shall be able to mark notifications as read | Low |
| FR-PAR-07 | View Payments | Parent shall see payment status and due amounts | Medium |
| FR-PAR-08 | Upload Receipt | Parent shall be able to upload payment receipts | Medium |
| FR-PAR-09 | AI Receipt Analysis | The system shall extract payment details from receipt images using AI | Low |

**Table 4.5: Notification Module Requirements**

| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| FR-NOT-01 | Push Notifications | The system shall send push notifications via Firebase Cloud Messaging | High |
| FR-NOT-02 | Class Scheduled | The system shall notify coaches and parents when a new class is scheduled | High |
| FR-NOT-03 | Broadcast Messages | Admin shall be able to send broadcast messages to selected roles | Medium |
| FR-NOT-04 | Real-time Updates | Notifications shall appear in real-time without app refresh | High |
| FR-NOT-05 | Unread Count | The system shall display unread notification count as badge | Low |


### 4.3.2 Non-Functional Requirements

Non-functional requirements define the quality attributes and constraints of the system. The following table specifies these requirements using measurable metrics.

**Table 4.6: Non-Functional Requirements with Metrics**

| Property | Requirement | Measure | Target Value |
|----------|-------------|---------|--------------|
| Speed | Application responsiveness | Processed transactions/second | > 100 TPS |
| Speed | User interaction feedback | User/event response time | < 300 ms |
| Speed | Dashboard loading | Screen refresh time | < 3 seconds |
| Speed | PDF extraction processing | AI response time | < 10 seconds |
| Speed | Animation generation | AI processing time | < 8 seconds |
| Size | Application package size | Mbytes | < 50 MB (Android APK) |
| Size | Offline data cache | Mbytes | < 100 MB |
| Size | Database document limit | Number of documents | 1,000,000+ |
| Ease of Use | User onboarding | Training time | < 30 minutes |
| Ease of Use | In-app guidance | Number of help frames | Contextual tooltips on all screens |
| Ease of Use | User satisfaction | Rating score | > 4.0 / 5.0 |
| Reliability | System stability | Mean time to failure (MTTF) | > 720 hours (30 days) |
| Reliability | Service availability | Probability of unavailability | < 0.1% |
| Reliability | Data synchronization | Rate of failure occurrence | < 1% of sync operations |
| Reliability | Uptime guarantee | Availability | 99.9% |
| Robustness | Crash recovery | Time to restart after failure | < 5 seconds |
| Robustness | Error handling | Percentage of events causing failure | < 0.5% |
| Robustness | Data integrity | Probability of data corruption on failure | < 0.01% |
| Robustness | Offline capability | Graceful degradation | Full read access offline |
| Portability | Cross-platform code | Percentage of target dependent statements | < 5% platform-specific code |
| Portability | Device compatibility | Number of target systems | Android 5.0+, iOS 12+, Web browsers |
| Security | Authentication | Encryption method | Firebase Auth with TLS 1.3 |
| Security | Data transmission | Protocol | HTTPS only |
| Security | AI response safety | Output type | JSON only (no executable code) |
| Accuracy | PDF extraction | Content accuracy | > 85% |
| Accuracy | Receipt OCR | Data extraction accuracy | > 80% |


## 4.4 Requirements Specification

This section presents the use case diagrams and descriptions that specify how users interact with the system.

### 4.4.1 System Use Case Diagram

[INSERT USE CASE DIAGRAM HERE]

The Use Case Diagram illustrates all interactions between actors (Admin, Coach, Parent) and the GoalBuddy system, including external systems (Firebase, Gemini AI).

### 4.4.2 Actors Description

**Table 4.7: System Actors**

| Actor | Description | Primary Goals |
|-------|-------------|---------------|
| Admin | Academy administrator responsible for managing coaches, students, templates, and scheduling | Efficient academy management, standardized training |
| Coach | Lead or assistant coach responsible for conducting sessions and tracking attendance | Effective session delivery, student progress tracking |
| Parent | Parent/guardian of enrolled student who monitors child's progress | Stay informed about schedule, attendance, and progress |
| Firebase | External cloud platform providing authentication, database, storage, and messaging services | Data persistence, real-time sync, push notifications |
| Gemini AI | Google's generative AI service for document analysis and content generation | PDF extraction, animation generation, receipt analysis |

### 4.4.3 Use Case Descriptions

**Use Case 1: User Authentication**

| Element | Description |
|---------|-------------|
| Use Case ID | UC-01 |
| Use Case Name | User Authentication |
| Actors | Admin, Coach, Parent, Firebase |
| Description | User logs into the system using credentials |
| Preconditions | User has registered account, App is installed |
| Postconditions | User is authenticated and redirected to role-specific dashboard |
| Main Flow | 1. User opens app. 2. System displays login screen. 3. User enters email and password. 4. System validates credentials with Firebase Auth. 5. System retrieves user role from Firestore. 6. System redirects to appropriate dashboard. |
| Alternative Flow | 3a. User selects "Sign in with Google". 3b. System initiates Google OAuth flow. 3c. Continue from step 4. |
| Exception Flow | 4a. Invalid credentials: Display error message. 4b. Network error: Display offline message. |

**Use Case 2: Create Session Template**

| Element | Description |
|---------|-------------|
| Use Case ID | UC-02 |
| Use Case Name | Create Session Template |
| Actors | Admin, Firebase, Gemini AI |
| Description | Admin creates a reusable session template with drills |
| Preconditions | Admin is logged in |
| Postconditions | Template is saved to Firestore |
| Main Flow | 1. Admin navigates to "Create Template". 2. Admin enters title, age group, badge focus. 3. Admin adds drills manually with details. 4. Admin clicks "Save Template". 5. System saves to Firestore. |
| Alternative Flow (AI Autofill) | 2a. Admin clicks "Autofill from PDF". 2b. Admin selects PDF file. 2c. System uploads PDF to Gemini AI. 2d. Gemini extracts lesson plan structure. 2e. System auto-fills form fields. 2f. Continue from step 4. |
| Alternative Flow (AI Animation) | 3a. Admin clicks "AI Animate" on drill. 3b. System sends drill details to Gemini. 3c. Gemini generates animation JSON. 3d. System displays animation preview. |

**Use Case 3: Schedule Class**

| Element | Description |
|---------|-------------|
| Use Case ID | UC-03 |
| Use Case Name | Schedule Class from Template |
| Actors | Admin, Firebase |
| Description | Admin schedules a class using existing template |
| Preconditions | Admin is logged in, Template exists |
| Postconditions | Class is created, Students assigned, Coaches notified |
| Main Flow | 1. Admin selects template. 2. Admin sets date, time, venue. 3. Admin assigns lead coach. 4. Admin assigns assistant coach (optional). 5. System creates session in Firestore. 6. System auto-assigns students by age group. 7. Cloud Function triggers notifications. 8. Coaches and parents receive push notifications. |
| Include | Auto-assign Students, Send Notification |

**Use Case 4: Conduct Active Session**

| Element | Description |
|---------|-------------|
| Use Case ID | UC-04 |
| Use Case Name | Conduct Active Session |
| Actors | Coach, Firebase |
| Description | Coach runs a scheduled session with timer and drills |
| Preconditions | Coach is logged in, Session is assigned to coach |
| Postconditions | Session is completed, Attendance recorded |
| Main Flow | 1. Coach views assigned sessions. 2. Coach selects session to start. 3. System displays first drill with timer. 4. Coach starts timer. 5. Coach demonstrates drill (optionally plays animation). 6. Coach navigates to next drill. 7. Repeat steps 4-6 for all drills. 8. Coach marks student attendance. 9. Coach completes session. 10. System archives session. |
| Extend | Play Drill Animation, View PDF Resources |

**Use Case 5: Mark Attendance**

| Element | Description |
|---------|-------------|
| Use Case ID | UC-05 |
| Use Case Name | Mark Student Attendance |
| Actors | Coach, Firebase |
| Description | Coach marks students as present or absent |
| Preconditions | Session is active or recently completed |
| Postconditions | Attendance saved to session and student records |
| Main Flow | 1. Coach opens attendance view. 2. System displays student list for session. 3. Coach toggles present/absent for each student. 4. System updates session subcollection. 5. System updates student's attendanceHistory map. |

**Use Case 6: View Child Progress**

| Element | Description |
|---------|-------------|
| Use Case ID | UC-06 |
| Use Case Name | View Child Progress |
| Actors | Parent, Firebase |
| Description | Parent views child's attendance and achievements |
| Preconditions | Parent is logged in, Child is linked to parent account |
| Postconditions | Progress information displayed |
| Main Flow | 1. Parent opens dashboard. 2. System displays child summary (name, age group). 3. Parent selects "View Progress". 4. System retrieves attendance history. 5. System calculates attendance rate and streaks. 6. System displays earned badges. 7. Parent views detailed progress. |

**Use Case 7: Upload Payment Receipt**

| Element | Description |
|---------|-------------|
| Use Case ID | UC-07 |
| Use Case Name | Upload Payment Receipt |
| Actors | Parent, Firebase, Gemini AI |
| Description | Parent uploads receipt for payment verification |
| Preconditions | Parent is logged in |
| Postconditions | Receipt stored, Payment details extracted |
| Main Flow | 1. Parent opens finance view. 2. Parent selects "Upload Receipt". 3. Parent captures/selects receipt image. 4. System uploads to Firebase Storage. 5. System sends image to Gemini AI. 6. Gemini extracts: amount, date, reference, method. 7. System displays extracted information. 8. System updates payment status. |
| Extend | AI Receipt Analysis |


## 4.5 System Design

### 4.5.1 Design Approach

The GoalBuddy system is designed using the following principles and methodologies:

The Model-View-ViewModel (MVVM) Architecture separates business logic from UI for maintainability and testability. The Provider Pattern enables reactive state management using ChangeNotifier. Service-Oriented Architecture provides modular services for Firebase, AI, and storage operations. Cross-Platform Development using Flutter allows a single codebase for Android, iOS, and Web. Serverless Backend through Firebase services eliminates server management overhead. AI-Augmented Features via Google Gemini integration enable intelligent automation.

### 4.5.2 Design Justification

**Table 4.8: Design Decisions and Justifications**

| Design Decision | Justification |
|-----------------|---------------|
| Flutter Framework | Single codebase for multiple platforms, hot reload for rapid development, rich widget library for Material 3 design |
| Firebase Backend | Real-time synchronization, built-in authentication, scalable NoSQL database, integrated push notifications |
| MVVM Pattern | Clear separation of concerns, easier unit testing, reactive UI updates |
| Provider State Management | Lightweight, recommended by Flutter team, sufficient for app complexity |
| Gemini AI Integration | State-of-the-art multimodal AI, supports PDF analysis and text generation, cost-effective API |
| NoSQL Database (Firestore) | Flexible schema for evolving requirements, optimized for mobile apps, offline support |


## 4.6 Architectural Design

### 4.6.1 System Architecture Overview

[INSERT SYSTEM ARCHITECTURE DIAGRAM HERE]

The GoalBuddy system follows a three-tier architecture consisting of the Presentation Layer, Business Logic Layer, and Data Layer.

The Presentation Layer includes the Flutter applications for Android, iOS, and Web platforms, all running on the Flutter Engine with Dart Runtime. The Business Logic Layer contains ViewModels (AuthVM, DashboardVM, AdminVM, AttendanceVM, etc.), Services (AuthService, FirestoreService, StorageService, NotificationService, GeminiService), and Models (User, Student, Coach, Session, Drill, Notification). The Data Layer encompasses Firebase services (Auth, Firestore, Storage, FCM), Cloud Functions running on Node.js, and Google Gemini AI for PDF extraction, animation generation, and receipt OCR.

### 4.6.2 Component Description

**Table 4.9: System Components**

| Component | Technology | Responsibility |
|-----------|------------|----------------|
| Flutter App | Dart/Flutter | Cross-platform UI rendering, user interaction |
| ViewModels | Dart (ChangeNotifier) | State management, business logic orchestration |
| Services | Dart | Data access, external API communication |
| Models | Dart (Classes) | Data structures, serialization/deserialization |
| Firebase Auth | Firebase | User authentication, session management |
| Cloud Firestore | Firebase | Real-time NoSQL database |
| Firebase Storage | Firebase | File storage (PDFs, images, receipts) |
| Firebase Cloud Messaging | Firebase | Push notification delivery |
| Cloud Functions | Node.js | Server-side triggers and automation |
| Gemini AI | Google AI | PDF analysis, animation generation, OCR |

### 4.6.3 Communication Patterns

**Table 4.10: Communication Patterns**

| Pattern | Usage | Example |
|---------|-------|---------|
| Request-Response | Service calls to Firebase | FirestoreService.getCoachSessions() |
| Streams | Real-time data updates | Stream<List<Session>> for dashboard |
| Pub-Sub | Push notifications | FCM topic subscriptions |
| Event-Driven | Cloud Function triggers | onSessionCreated document trigger |


## 4.7 Object-Oriented Design

### 4.7.1 Structural Static Models

#### 4.7.1.1 UML Class Diagram

[INSERT UML CLASS DIAGRAM HERE]

The class diagram shows the main model classes and their relationships.

**Table 4.11: Class Descriptions**

| Class | Attributes | Methods | Description |
|-------|------------|---------|-------------|
| User | id, name, email, phone, role, ratePerHour, fcmToken, linkedStudentId | fromMap(), toMap() | Represents all system users (Admin, Coach, Parent) |
| Student | id, name, dateOfBirth, ageGroup, parentEmail, parentPhone, medicalNotes, earnedBadges, attendanceHistory, notes | fromMap(), toMap(), calculateAgeGroup() | Represents enrolled students |
| Coach | id, name, email, phone, ratePerHour, role, assignedClasses | fromMap(), toMap() | Coach profile with assignments |
| Session | id, className, ageGroup, startTime, durationMinutes, venue, status, leadCoachId, assistantCoachId, drills | fromMap(), toMap(), isOvertime | Scheduled or completed class session |
| SessionTemplate | id, title, ageGroup, badgeFocus, drills, pdfUrl, createdBy | fromFirestore(), toFirestore(), blank() | Reusable session blueprint |
| Drill | title, category, instructions, durationSeconds, equipment, ageGroup, animationUrl, animationJson, visualType | fromMap(), sortOrder | Individual drill activity |
| DrillData | title, duration, instructions, equipment, progressionEasier, progressionHarder, learningGoals, animationJson | blank() | Drill data embedded in templates |
| DrillAnimationData | players, balls, equipment, durationMs, description | fromJson(), toJson() | AI-generated animation structure |
| Badge | id, title, ageGroup, iconAsset, colorHex, description | fromMap(), toMap() | Achievement badge |
| Note | id, text, timestamp | fromMap(), toMap() | Coach note on student |
| NotificationModel | id, title, body, type, targetUserId, targetRole, read, createdAt | fromFirestore(), toMap(), timeAgo | Push notification record |
| StudentAttendance | id, name, isPresent, isNew, parentContact, medicalNotes | fromMap(), toMap() | Session attendance record |

#### 4.7.1.2 Class Relationships

**Table 4.12: Class Relationships**

| Relationship | Type | Description |
|--------------|------|-------------|
| User → Student | 1:0..1 | Parent user links to one student |
| User → Session | 1:* | Coach assigned to many sessions |
| Student → Note | 1:* | Student has many coach notes |
| Student → Badge | *:* | Student earns many badges |
| Session → SessionTemplate | *:1 | Sessions created from templates |
| Session → Drill | 1:* | Session contains multiple drills |
| SessionTemplate → DrillData | 1:* | Template contains embedded drills |
| DrillData → DrillAnimationData | 1:0..1 | Drill may have AI animation |
| User → NotificationModel | 1:* | User receives many notifications |


#### 4.7.1.3 Data Flow Diagram (DFD)

[INSERT DFD LEVEL 0 - CONTEXT DIAGRAM HERE]

[INSERT DFD LEVEL 1 - MAIN PROCESSES HERE]

**Table 4.13: DFD Process Descriptions**

| Process ID | Process Name | Input | Output | Description |
|------------|--------------|-------|--------|-------------|
| 1.0 | Authenticate User | Login credentials | User role, session token | Validates user and returns role for routing |
| 2.0 | Manage Templates | Template data, PDF file | Stored template | Creates/updates session templates with drills |
| 3.0 | Schedule Class | Template ID, date/time, coach IDs | Session document | Creates scheduled class from template |
| 4.0 | Send Notification | Message, target role | Push notification | Sends FCM notifications to users |
| 5.0 | View Sessions | Coach ID | Session list | Retrieves assigned sessions for coach |
| 6.0 | Mark Attendance | Session ID, attendance data | Updated records | Records student attendance |
| 7.0 | View Progress | Student ID | Progress data | Retrieves child's attendance and badges |
| 8.0 | Manage Payments | Receipt image | Payment status | Processes and verifies payments |

**Table 4.14: DFD Data Stores**

| Store ID | Store Name | Contents |
|----------|------------|----------|
| D1 | Users | User profiles with roles and FCM tokens |
| D2 | Session Templates | Reusable session blueprints with drills |
| D3 | Sessions | Scheduled and completed class sessions |
| D4 | Students | Student records with attendance history |
| D5 | Notifications | Push notification records |
| D6 | Drills | Drill library with animations |
| D7 | Badges | Achievement badge definitions |


#### 4.7.1.4 Entity Relationship Diagram (ERD)

[INSERT ERD DIAGRAM HERE]

**Table 4.15: Entity Descriptions**

| Entity | Primary Key | Foreign Keys | Description |
|--------|-------------|--------------|-------------|
| users | id (UID) | linkedStudentId → students.id | System users with role-based access |
| students | id | assignedClassId → sessions.id | Enrolled students with attendance |
| sessions | id | leadCoachId → users.id, assistantCoachId → users.id, templateId → session_templates.id | Class sessions |
| session_templates | id | createdBy → users.id | Reusable templates |
| drills | id | - | Drill library |
| badges | id | - | Achievement badges |
| notifications | id | targetUserId → users.id, relatedSessionId → sessions.id | Notification records |
| notes (subcollection) | id | studentId → students.id | Coach notes |
| session_students (subcollection) | id | sessionId → sessions.id | Attendance records |

**Table 4.16: ERD Cardinality Summary**

| Relationship | Cardinality | Description |
|--------------|-------------|-------------|
| users ↔ students | 1:0..1 | One parent links to one child |
| users ↔ sessions (lead) | 1:* | One coach leads many sessions |
| users ↔ sessions (assistant) | 1:* | One coach assists many sessions |
| sessions ↔ session_templates | *:1 | Many sessions from one template |
| students ↔ badges | *:* | Many students earn many badges |
| students ↔ notes | 1:* | One student has many notes |
| sessions ↔ session_students | 1:* | One session has many attendance records |
| users ↔ notifications | 1:* | One user has many notifications |


### 4.7.2 Dynamic Models

#### 4.7.2.1 Sequence Diagram: Create Session Template with AI

[INSERT SEQUENCE DIAGRAM HERE]

The sequence diagram illustrates the interaction flow when an admin creates a session template using AI-powered PDF extraction. The admin initiates the process by clicking "Autofill from PDF" and selecting a PDF file. The CreateTemplateView sends the PDF bytes to GeminiService which processes the document through the Gemini AI API. Upon receiving the extracted JSON data, the view simultaneously uploads the PDF to StorageService for Firebase Storage and receives the download URL. The form is then auto-filled with the extracted data. When the admin clicks "Save", the template is stored in Firestore via FirestoreService, and a success confirmation is displayed.

#### 4.7.2.2 Sequence Diagram: Mark Attendance

[INSERT SEQUENCE DIAGRAM HERE]

The attendance marking sequence begins when the coach opens the AttendanceView. The view requests student data from AttendanceViewModel, which queries Firestore for the session's student list. Upon receiving the data, the ViewModel notifies listeners and the UI displays the student list. When the coach toggles a student's attendance status, the ViewModel updates both the session document's student subcollection and the student's individual attendanceHistory map in Firestore. The UI reflects the changes immediately through state management.

#### 4.7.2.3 Activity Diagram: Session Lifecycle

[INSERT ACTIVITY DIAGRAM HERE]

The session lifecycle begins when an admin creates a session template. The admin then schedules a class using the template, specifying date, time, venue, and assigned coaches. The system automatically assigns students to the class based on their age group matching the session's target age group. Notifications are sent to the assigned coaches and parents of enrolled students. The session status is set to "UPCOMING".

When the scheduled time arrives, the coach starts the active session. The system displays the first drill with a countdown timer. The coach runs through each drill, optionally playing animations and demonstrating movements. After completing all drills, the coach navigates to the attendance view and marks each student as present or absent. Upon completing attendance, the coach finishes the session, changing its status to "COMPLETED". Finally, the system archives the session to the pastSessions collection for historical records.


## 4.8 Data Modeling

### 4.8.1 Database Design

GoalBuddy uses Firebase Cloud Firestore, a NoSQL document database. The database is organized into collections containing documents with fields. This section details the schema for each collection.

### 4.8.2 Collection Schemas

**Table 4.17: Users Collection Schema**

| Field | Data Type | Constraints | Description |
|-------|-----------|-------------|-------------|
| id | String | PK, Required | Firebase Auth UID |
| name | String | Required, Max 100 chars | Full name |
| email | String | Required, Email format | Email address |
| phone | String | Optional, Max 20 chars | Phone number |
| role | String | Required, Enum: 'admin', 'coach', 'student_parent' | User role |
| ratePerHour | Double | Optional, Min 0 | Coach hourly rate (MYR) |
| fcmToken | String | Optional | Firebase Cloud Messaging token |
| fcmTokenUpdatedAt | Timestamp | Optional | Token last updated |
| linkedStudentId | String | Optional, FK → students | Linked child (for parents) |
| linkedStudentName | String | Optional | Linked child name |
| createdAt | Timestamp | Required | Account creation date |
| lastUpdated | Timestamp | Required | Last modification date |

**Table 4.18: Students Collection Schema**

| Field | Data Type | Constraints | Description |
|-------|-----------|-------------|-------------|
| id | String | PK, Required | Auto-generated document ID |
| name | String | Required, Max 100 chars | Student full name |
| dateOfBirth | Timestamp | Required | Date of birth |
| ageGroup | String | Required, Enum | Calculated age group |
| parentEmail | String | Required, Email format | Parent email |
| parentPhone | String | Required, Max 20 chars | Parent phone |
| medicalNotes | String | Optional, Max 500 chars | Medical information |
| assignedClassId | String | Optional, FK → sessions | Current class |
| earnedBadges | Array of String | Optional | List of badge IDs |
| attendanceHistory | Map of String to String | Optional | Date → 'Present'/'Absent' |
| createdAt | Timestamp | Required | Registration date |
| lastUpdated | Timestamp | Required | Last modification |

**Students Subcollection: notes**

| Field | Data Type | Constraints | Description |
|-------|-----------|-------------|-------------|
| id | String | PK | Note ID |
| text | String | Required, Max 500 chars | Note content |
| timestamp | Timestamp | Required | Note creation time |

**Table 4.19: Sessions Collection Schema**

| Field | Data Type | Constraints | Description |
|-------|-----------|-------------|-------------|
| id | String | PK, Required | Auto-generated document ID |
| className | String | Required, Max 100 chars | Class name |
| ageGroup | String | Required, Enum | Target age group |
| startTime | Timestamp | Required | Session start time |
| durationMinutes | Integer | Required, 30-90 | Session duration |
| venue | String | Required, Max 200 chars | Location |
| status | String | Required, Enum: 'Upcoming', 'Scheduled', 'Completed' | Session status |
| leadCoachId | String | Required, FK → users | Lead coach UID |
| assistantCoachId | String | Optional, FK → users | Assistant coach UID |
| templateId | String | Optional, FK → session_templates | Source template |
| badgeFocus | String | Optional | Badge being taught |
| drills | Array of Map | Required | Embedded drill data |
| pdfUrl | String | Optional, URL | PDF resource link |
| pdfFileName | String | Optional | PDF file name |
| createdAt | Timestamp | Required | Creation date |
| completedAt | Timestamp | Optional | Completion date |

**Sessions Subcollection: students (attendance)**

| Field | Data Type | Constraints | Description |
|-------|-----------|-------------|-------------|
| id | String | PK | Student ID |
| name | String | Required | Student name |
| isPresent | Boolean | Required | Attendance status |
| isNew | Boolean | Optional | First-time student flag |
| parentContact | String | Optional | Parent phone |
| medicalNotes | String | Optional | Medical notes |
| ageGroup | String | Required | Student age group |
| lastUpdated | Timestamp | Required | Last update time |

**Table 4.20: Session Templates Collection Schema**

| Field | Data Type | Constraints | Description |
|-------|-----------|-------------|-------------|
| id | String | PK, Required | Auto-generated document ID |
| title | String | Required, Max 100 chars | Template name |
| ageGroup | String | Required, Enum | Target age group |
| badgeFocus | String | Optional, Max 50 chars | Badge focus |
| drills | Array of Map | Required | Embedded DrillData objects |
| pdfUrl | String | Optional, URL | Source PDF link |
| pdfFileName | String | Optional | PDF file name |
| createdAt | Timestamp | Required | Creation date |
| createdBy | String | Required, FK → users | Creator UID |

**Embedded DrillData Structure**

| Field | Data Type | Constraints | Description |
|-------|-----------|-------------|-------------|
| title | String | Required | Drill name |
| duration | String | Required | Duration (e.g., "5 min") |
| instructions | String | Required | Step-by-step instructions |
| equipment | String | Optional | Required equipment |
| progression_easier | String | Optional | Easier variation |
| progression_harder | String | Optional | Harder variation |
| learning_goals | String | Optional | Learning objectives |
| animationUrl | String | Optional, URL | Animation file URL |
| animationJson | String | Optional, JSON | AI-generated animation |
| visualType | String | Optional, Enum: 'animation', 'video', 'image', 'gif' | Visual type |

**Table 4.21: Notifications Collection Schema**

| Field | Data Type | Constraints | Description |
|-------|-----------|-------------|-------------|
| id | String | PK, Required | Auto-generated document ID |
| title | String | Required, Max 100 chars | Notification title |
| body | String | Required, Max 500 chars | Message body |
| type | String | Required, Enum: 'class_scheduled', 'broadcast', 'reminder', 'attendance' | Notification type |
| targetUserId | String | Required, FK → users | Target user |
| targetRole | String | Optional | Target role filter |
| relatedSessionId | String | Optional, FK → sessions | Related session |
| createdAt | Timestamp | Required | Creation time |
| read | Boolean | Required, Default false | Read status |
| readAt | Timestamp | Optional | Read timestamp |

### 4.8.3 Age Group Calculation Algorithm

The system automatically calculates a student's age group based on their date of birth using the following algorithm:

1. Calculate the student's age in years from their date of birth to the current date.
2. If age is greater than or equal to 1.5 years and less than 2.5 years, assign "Little Kicks".
3. If age is greater than or equal to 2.5 years and less than 3.5 years, assign "Junior Kickers".
4. If age is greater than or equal to 3.5 years and less than 5.0 years, assign "Mighty Kickers".
5. If age is greater than or equal to 5.0 years and less than or equal to 8.0 years, assign "Mega Kickers".
6. Otherwise, assign "Unknown".

### 4.8.4 Drill Category Sort Order

**Table 4.22: Drill Category Sort Order**

| Category | Sort Order | Typical Duration |
|----------|------------|------------------|
| Intro / Muster | 0 | 5 minutes |
| Warm Up | 1 | 5-10 minutes |
| Technical / Skill / Ball Mastery | 2 | 15-20 minutes |
| Match / Game / Fun Game | 3 | 10-15 minutes |


## 4.9 User Interface Design

### 4.9.1 Design Principles

The GoalBuddy user interface follows these design principles: Material Design 3 using Google's latest design system with dynamic color theming; Child-Friendly Aesthetics with bright colors, rounded corners, and playful typography; Role-Based Navigation providing different dashboards for Admin, Coach, and Parent; Progressive Disclosure showing only relevant information at each step; and Accessibility ensuring large touch targets, readable fonts, and proper color contrast.

### 4.9.2 Color Scheme and Typography

**Table 4.23: Color Palette**

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Primary (Little Kickers Red) | #E31C23 | Headers, buttons, branding |
| Secondary (Pitch Green) | #4CAF50 | Success states, attendance present |
| Background | #F5F7FA | Screen backgrounds |
| Surface | #FFFFFF | Cards, dialogs |
| Text Primary | #2D2D2D | Main text content |
| Text Secondary | #757575 | Subtle text, labels |
| Error | #F44336 | Error states, absent marking |
| Warning | #FFC107 | Warning states |

**Table 4.24: Typography**

| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| Headline Large | Fredoka | 32sp | Bold | Screen titles |
| Headline Medium | Fredoka | 28sp | Semi-Bold | Section headers |
| Title Large | Fredoka | 22sp | Medium | Card titles |
| Body Large | Fredoka | 16sp | Regular | Main content |
| Body Medium | Fredoka | 14sp | Regular | Secondary content |
| Label | Fredoka | 12sp | Medium | Buttons, chips |

### 4.9.3 Screen Layouts

#### 4.9.3.1 Login Screen

[INSERT LOGIN SCREEN MOCKUP]

The login screen displays the GoalBuddy logo centered at the top, followed by a welcome message. Below are the email and password input fields with appropriate validation. The primary login button uses the Little Kickers Red color. A Google Sign-In button provides OAuth authentication as an alternative. A "Forgot Password" link is available for password recovery.

Data Elements: Email (Required, valid email format, max 254 characters), Password (Required, min 6 characters).

#### 4.9.3.2 Admin Dashboard

[INSERT ADMIN DASHBOARD MOCKUP]

The admin dashboard features a header with the title and notification bell icon. A row of statistics cards displays the count of coaches, students, and today's sessions. Quick action buttons are arranged in a grid for Register Coach, Register Student, Create Template, and Schedule Class. A list of recent and upcoming sessions is displayed below. Bottom navigation provides access to Dashboard, Analytics, Notifications, and Profile.

#### 4.9.3.3 Coach Dashboard

[INSERT COACH DASHBOARD MOCKUP]

The coach dashboard header displays "My Sessions" with a date picker. Today's sessions are listed in cards showing the class name, time, venue, age group chip, and status indicator. Each card has a green "Start Session" button. Quick links provide access to Past Sessions, Drill Library, and Resources.

#### 4.9.3.4 Active Session Screen

[INSERT ACTIVE SESSION MOCKUP]

The active session screen displays the class name in the header with a close button. A large countdown timer shows the remaining time in MM:SS format. A progress bar indicates the current position within the session drills. The current drill card displays the drill title, expandable instructions, and an animation preview area. Navigation buttons (Previous, Pause/Play, Next) allow drill control. A floating action button provides access to "Mark Attendance".

#### 4.9.3.5 Attendance Screen

[INSERT ATTENDANCE SCREEN MOCKUP]

The attendance screen header shows "Attendance" with session information. A summary card displays total students, present count, and absent count. The scrollable student list shows each student with their name, age group chip, and a toggle switch for marking attendance. The "Save & Continue" button commits the attendance records.

#### 4.9.3.6 Parent Dashboard

[INSERT PARENT DASHBOARD MOCKUP]

The parent dashboard displays the child's name and avatar in the header. A child information card shows the photo, name, and age group. A statistics row presents attendance percentage, classes attended, and current streak. The upcoming class card shows details of the next scheduled session. A horizontal scrolling section displays earned badges. Quick action buttons provide access to Schedule, Progress, and Payments views.

#### 4.9.3.7 Create Session Template Screen

[INSERT CREATE TEMPLATE MOCKUP]

The create template screen features an AI Autofill button prominently at the top. The general information card contains fields for title, age group dropdown, and badge focus. The drills section uses an expansion panel list where each drill can be expanded to show title, duration, instructions, equipment, progressions, and learning goals. Each drill card includes an "AI Animate" button that generates and displays an animation preview. An "Add Drill" button allows adding more drills. The "Save Template" button commits the template to the database.

### 4.9.4 Navigation Flow Diagram

[INSERT NAVIGATION FLOW DIAGRAM]

The application navigation begins at the Splash Screen which checks for existing authentication. Users without active sessions are directed to the Login Screen, while authenticated users proceed directly to their role-specific dashboard.

From the Admin Dashboard, navigation paths lead to Coaches List, Students List, Template Creation, Class Scheduling, Analytics, and Notifications. From the Coach Dashboard, coaches can navigate to Active Session, Attendance, Student List, Drill Library, and Past Sessions. From the Parent Dashboard, parents can access Schedule View, Progress View, Badges, and Finance sections. All dashboards provide access to the Notifications view and user Profile.


## 4.10 Summary

This chapter presented a comprehensive system analysis and design for the GoalBuddy - Little Kickers Coach Companion mobile application.

The Requirements Analysis identified over 35 functional requirements organized across Authentication, Admin, Coach, Parent, and Notification modules, along with 18 non-functional requirements with measurable metrics covering speed, size, ease of use, reliability, robustness, portability, security, and accuracy.

The System Modeling produced a Use Case Diagram identifying three primary actors (Admin, Coach, Parent) and two external systems (Firebase, Gemini AI) with fifteen use cases, supported by seven detailed use case descriptions with main flows, alternative flows, and exception handling.

The Architectural Design established a three-tier architecture encompassing Presentation, Business Logic, and Data layers, implementing the MVVM pattern with Provider state management and a service-oriented approach with dedicated services for authentication, database operations, storage, notifications, and AI processing.

The Object-Oriented Design delivered a UML Class Diagram with twelve model classes and their relationships, Data Flow Diagrams at Level 0 and Level 1 showing eight main processes and seven data stores, an Entity Relationship Diagram with complete cardinality mapping, Sequence Diagrams for key workflows including template creation and attendance marking, and an Activity Diagram depicting the complete session lifecycle.

The Data Modeling section detailed seven Firestore collections with comprehensive field-level specifications including data types, constraints, and validation rules, along with algorithms for age group calculation and drill sorting.

The User Interface Design section specified Material Design 3 implementation with a custom color scheme, typography guidelines, eight key screen layouts with detailed component specifications, and a navigation flow diagram showing user journeys throughout the application.

The design ensures that GoalBuddy meets all identified requirements while providing a scalable, maintainable, and user-friendly solution for youth football coaching academies.
