# GoalBuddy - Little Kickers Coach Companion
## System Diagrams Collection

---

## Table of Contents
1. [Flowcharts](#1-flowcharts)
   - 1.1 Admin Flowchart
   - 1.2 Coach Flowchart
   - 1.3 Student/Parent Flowchart
2. [Use Case Diagram](#2-use-case-diagram)
3. [UML Class Diagram](#3-uml-class-diagram)
4. [Entity-Relationship Diagram (ERD)](#4-entity-relationship-diagram-erd)
5. [Data Flow Diagram (DFD)](#5-data-flow-diagram-dfd)
6. [Sequence Diagrams](#6-sequence-diagrams)
   - 6.1 User Authentication
   - 6.2 Schedule Class from Template
   - 6.3 Coach Starts Active Session
   - 6.4 Parent Views Child Progress
   - 6.5 AI Generate Drill Animation
   - 6.6 Send Broadcast Notification

---

## 1. Flowcharts

### 1.1 Admin Flowchart

```
                              ┌─────────────────┐
                              │      START      │
                              └────────┬────────┘
                                       │
                                       ▼
                              ┌─────────────────┐
                              │  Admin Login    │
                              └────────┬────────┘
                                       │
                                       ▼
                           ┌───────────────────────┐
                           │ Authentication Valid? │
                           └───────────┬───────────┘
                                       │
                        ┌──────────────┴──────────────┐
                        │ No                      Yes │
                        ▼                             ▼
               ┌────────────────┐           ┌─────────────────┐
               │ Show Error     │           │ Admin Dashboard │
               │ Message        │           └────────┬────────┘
               └────────┬───────┘                    │
                        │                            ▼
                        │              ┌─────────────────────────┐
                        │              │    Select Function      │
                        │              └─────────────┬───────────┘
                        │                            │
                        │     ┌──────────┬──────────┼──────────┬──────────┐
                        │     ▼          ▼          ▼          ▼          ▼
                        │ ┌───────┐ ┌─────────┐ ┌────────┐ ┌────────┐ ┌────────┐
                        │ │Manage │ │ Manage  │ │ Create │ │  View  │ │  Send  │
                        │ │Users  │ │Students │ │Template│ │Finance │ │Notif.  │
                        │ └───┬───┘ └────┬────┘ └───┬────┘ └───┬────┘ └───┬────┘
                        │     │          │          │          │          │
                        │     ▼          ▼          ▼          ▼          ▼
                        │ ┌───────┐ ┌─────────┐ ┌────────┐ ┌────────┐ ┌────────┐
                        │ │Add/   │ │Register/│ │Upload  │ │View    │ │Compose │
                        │ │Edit/  │ │Edit/    │ │PDF     │ │Payment │ │Message │
                        │ │Delete │ │Assign   │ │        │ │Records │ │        │
                        │ └───┬───┘ └────┬────┘ └───┬────┘ └───┬────┘ └───┬────┘
                        │     │          │          │          │          │
                        │     │          │          ▼          │          ▼
                        │     │          │    ┌──────────┐     │    ┌──────────┐
                        │     │          │    │Gemini AI │     │    │Select    │
                        │     │          │    │Extract   │     │    │Recipients│
                        │     │          │    └────┬─────┘     │    └────┬─────┘
                        │     │          │         │           │         │
                        │     │          │         ▼           │         ▼
                        │     │          │    ┌──────────┐     │    ┌──────────┐
                        │     │          │    │Generate  │     │    │Send via  │
                        │     │          │    │Animation │     │    │FCM       │
                        │     │          │    └────┬─────┘     │    └────┬─────┘
                        │     │          │         │           │         │
                        │     ▼          ▼         ▼           ▼         ▼
                        │ ┌─────────────────────────────────────────────────┐
                        │ │              Save to Firestore                  │
                        │ └────────────────────────┬────────────────────────┘
                        │                          │
                        │                          ▼
                        │               ┌─────────────────────┐
                        │               │  Show Success Msg   │
                        │               └──────────┬──────────┘
                        │                          │
                        └────────────┬─────────────┘
                                     │
                                     ▼
                           ┌───────────────────┐
                           │ Continue Working? │
                           └─────────┬─────────┘
                                     │
                        ┌────────────┴────────────┐
                        │ Yes                  No │
                        │                         ▼
                        │               ┌─────────────────┐
                        │               │     Logout      │
                        │               └────────┬────────┘
                        │                        │
                        │                        ▼
                        │               ┌─────────────────┐
                        └───────────────►       END       │
                                        └─────────────────┘
```

---

### 1.2 Coach Flowchart

```
                              ┌─────────────────┐
                              │      START      │
                              └────────┬────────┘
                                       │
                                       ▼
                              ┌─────────────────┐
                              │  Coach Login    │
                              └────────┬────────┘
                                       │
                                       ▼
                           ┌───────────────────────┐
                           │ Authentication Valid? │
                           └───────────┬───────────┘
                                       │
                        ┌──────────────┴──────────────┐
                        │ No                      Yes │
                        ▼                             ▼
               ┌────────────────┐           ┌─────────────────┐
               │ Show Error     │           │ Coach Dashboard │
               │ Message        │           └────────┬────────┘
               └────────┬───────┘                    │
                        │                            ▼
                        │              ┌─────────────────────────┐
                        │              │    Select Function      │
                        │              └─────────────┬───────────┘
                        │                            │
                        │          ┌─────────────────┼─────────────────┐
                        │          ▼                 ▼                 ▼
                        │    ┌───────────┐    ┌───────────┐    ┌───────────┐
                        │    │   View    │    │   Start   │    │   View    │
                        │    │ Schedule  │    │  Session  │    │ Students  │
                        │    └─────┬─────┘    └─────┬─────┘    └─────┬─────┘
                        │          │                │                │
                        │          ▼                ▼                ▼
                        │    ┌───────────┐    ┌───────────┐    ┌───────────┐
                        │    │ View      │    │  Select   │    │ View      │
                        │    │ Assigned  │    │  Class    │    │ Assigned  │
                        │    │ Classes   │    │           │    │ Students  │
                        │    └─────┬─────┘    └─────┬─────┘    └─────┬─────┘
                        │          │                │                │
                        │          │                ▼                ▼
                        │          │          ┌───────────┐    ┌───────────┐
                        │          │          │   Load    │    │   View    │
                        │          │          │  Template │    │  Profile  │
                        │          │          └─────┬─────┘    │& Progress │
                        │          │                │          └───────────┘
                        │          │                ▼
                        │          │          ┌───────────┐
                        │          │          │   View    │
                        │          │          │ Animation │
                        │          │          └─────┬─────┘
                        │          │                │
                        │          │                ▼
                        │          │          ┌───────────┐
                        │          │          │   Take    │
                        │          │          │Attendance │
                        │          │          └─────┬─────┘
                        │          │                │
                        │          │                ▼
                        │          │          ┌───────────┐
                        │          │          │  Record   │
                        │          │          │  Notes    │
                        │          │          └─────┬─────┘
                        │          │                │
                        │          │                ▼
                        │          │          ┌───────────┐
                        │          │          │   End     │
                        │          │          │  Session  │
                        │          │          └─────┬─────┘
                        │          │                │
                        │          ▼                ▼
                        │ ┌─────────────────────────────────────────────────┐
                        │ │              Save to Firestore                  │
                        │ └────────────────────────┬────────────────────────┘
                        │                          │
                        │                          ▼
                        │               ┌─────────────────────┐
                        │               │  Show Success Msg   │
                        │               └──────────┬──────────┘
                        │                          │
                        └────────────┬─────────────┘
                                     │
                                     ▼
                           ┌───────────────────┐
                           │ Continue Working? │
                           └─────────┬─────────┘
                                     │
                        ┌────────────┴────────────┐
                        │ Yes                  No │
                        │                         ▼
                        │               ┌─────────────────┐
                        │               │     Logout      │
                        │               └────────┬────────┘
                        │                        │
                        │                        ▼
                        │               ┌─────────────────┐
                        └───────────────►       END       │
                                        └─────────────────┘
```

---

### 1.3 Student/Parent Flowchart

```
                              ┌─────────────────┐
                              │      START      │
                              └────────┬────────┘
                                       │
                                       ▼
                              ┌─────────────────┐
                              │  Parent Login   │
                              └────────┬────────┘
                                       │
                                       ▼
                           ┌───────────────────────┐
                           │ Authentication Valid? │
                           └───────────┬───────────┘
                                       │
                        ┌──────────────┴──────────────┐
                        │ No                      Yes │
                        ▼                             ▼
               ┌────────────────┐           ┌─────────────────┐
               │ Show Error     │           │Parent Dashboard │
               │ Message        │           └────────┬────────┘
               └────────┬───────┘                    │
                        │                            ▼
                        │              ┌─────────────────────────┐
                        │              │    Select Function      │
                        │              └─────────────┬───────────┘
                        │                            │
                        │     ┌──────────┬───────────┼───────────┬──────────┐
                        │     ▼          ▼           ▼           ▼          ▼
                        │ ┌───────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌────────┐
                        │ │ View  │ │  View   │ │  View   │ │  View   │ │  View  │
                        │ │Child  │ │Schedule │ │Progress │ │Payments │ │Notif.  │
                        │ │Profile│ │         │ │& Notes  │ │         │ │        │
                        │ └───┬───┘ └────┬────┘ └────┬────┘ └────┬────┘ └───┬────┘
                        │     │          │           │           │          │
                        │     ▼          ▼           ▼           ▼          ▼
                        │ ┌───────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌────────┐
                        │ │Display│ │ Display │ │ Display │ │ Display │ │Display │
                        │ │Child  │ │Upcoming │ │Session  │ │Payment  │ │Message │
                        │ │Info & │ │Classes  │ │History &│ │History &│ │List    │
                        │ │Age    │ │         │ │Coach    │ │Status   │ │        │
                        │ │Group  │ │         │ │Feedback │ │         │ │        │
                        │ └───┬───┘ └────┬────┘ └────┬────┘ └────┬────┘ └───┬────┘
                        │     │          │           │           │          │
                        │     ▼          ▼           ▼           ▼          ▼
                        │ ┌─────────────────────────────────────────────────────┐
                        │ │                 Fetch from Firestore                │
                        │ └────────────────────────┬────────────────────────────┘
                        │                          │
                        │                          ▼
                        │               ┌─────────────────────┐
                        │               │   Display Data      │
                        │               └──────────┬──────────┘
                        │                          │
                        └────────────┬─────────────┘
                                     │
                                     ▼
                           ┌───────────────────┐
                           │ Continue Viewing? │
                           └─────────┬─────────┘
                                     │
                        ┌────────────┴────────────┐
                        │ Yes                  No │
                        │                         ▼
                        │               ┌─────────────────┐
                        │               │     Logout      │
                        │               └────────┬────────┘
                        │                        │
                        │                        ▼
                        │               ┌─────────────────┐
                        └───────────────►       END       │
                                        └─────────────────┘
```

---

## 2. Use Case Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        GoalBuddy System Use Cases                               │
│                                                                                 │
│  ┌─────────┐                                              ┌─────────┐          │
│  │  Admin  │                                              │  Coach  │          │
│  └────┬────┘                                              └────┬────┘          │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       ├───►│           Login/Logout                   │◄──────┤               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       ├───►│        Manage User Accounts              │       │               │
│       │    │    (Create, Edit, Delete, Assign Role)   │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       ├───►│         Register Students                │       │               │
│       │    │      (Add, Edit, Assign to Class)        │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       ├───►│       Create Session Template            │       │               │
│       │    │  (Upload PDF, AI Extract, AI Animate)    │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                        │                               │               │
│       │                        ▼                               │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       │    │          <<include>>                     │       │               │
│       │    │    Gemini AI Processing                  │       │               │
│       │    │  (PDF Extraction & Animation Gen)        │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       ├───►│        Schedule Classes                  │◄──────┤               │
│       │    │     (From Template, Assign Coach)        │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       ├───►│      Send Push Notifications             │       │               │
│       │    │   (Broadcast, Role-based, Individual)    │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       ├───►│         View Finance Records             │       │               │
│       │    │      (Payment Status, Reports)           │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       │    │          View Schedule                   │◄──────┤               │
│       │    │       (Assigned Classes)                 │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       │    │        Start Active Session              │◄──────┤               │
│       │    │   (Load Template, View Animation)        │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       │    │         Take Attendance                  │◄──────┤               │
│       │    │      (Mark Present/Absent)               │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│       │                                                        │               │
│       │    ┌──────────────────────────────────────────┐       │               │
│       │    │      Record Session Notes                │◄──────┤               │
│       │    │    (Per Student Performance)             │       │               │
│       │    └──────────────────────────────────────────┘       │               │
│                                                                                 │
│  ┌─────────────┐                                                               │
│  │Student/     │                                                               │
│  │Parent       │                                                               │
│  └──────┬──────┘                                                               │
│         │                                                                       │
│         │    ┌──────────────────────────────────────────┐                      │
│         ├───►│           Login/Logout                   │                      │
│         │    └──────────────────────────────────────────┘                      │
│         │                                                                       │
│         │    ┌──────────────────────────────────────────┐                      │
│         ├───►│        View Child Profile                │                      │
│         │    │      (Info, Age Group, Photo)            │                      │
│         │    └──────────────────────────────────────────┘                      │
│         │                                                                       │
│         │    ┌──────────────────────────────────────────┐                      │
│         ├───►│         View Schedule                    │                      │
│         │    │      (Upcoming Classes)                  │                      │
│         │    └──────────────────────────────────────────┘                      │
│         │                                                                       │
│         │    ┌──────────────────────────────────────────┐                      │
│         ├───►│       View Progress & Notes              │                      │
│         │    │    (Session History, Coach Feedback)     │                      │
│         │    └──────────────────────────────────────────┘                      │
│         │                                                                       │
│         │    ┌──────────────────────────────────────────┐                      │
│         ├───►│        View Payment Status               │                      │
│         │    │      (History, Outstanding)              │                      │
│         │    └──────────────────────────────────────────┘                      │
│         │                                                                       │
│         │    ┌──────────────────────────────────────────┐                      │
│         └───►│       Receive Notifications              │                      │
│              │     (View, Mark as Read)                 │                      │
│              └──────────────────────────────────────────┘                      │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. UML Class Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              UML Class Diagram                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────┐         ┌──────────────────────────┐
│        UserModel         │         │      StudentModel        │
├──────────────────────────┤         ├──────────────────────────┤
│ - uid: String            │         │ - id: String             │
│ - email: String          │         │ - name: String           │
│ - name: String           │         │ - dateOfBirth: DateTime  │
│ - role: String           │         │ - parentId: String       │
│ - profileImageUrl: String│         │ - profileImageUrl: String│
│ - createdAt: DateTime    │         │ - ageGroup: String       │
├──────────────────────────┤         │ - classIds: List<String> │
│ + toMap(): Map           │         ├──────────────────────────┤
│ + fromMap(): UserModel   │         │ + toMap(): Map           │
│ + calculateAgeGroup()    │◄────────│ + fromMap(): StudentModel│
└──────────────────────────┘    1:N  │ + calculateAgeGroup()    │
            │                        └──────────────────────────┘
            │                                    │
            │ 1:N                                │ N:M
            ▼                                    ▼
┌──────────────────────────┐         ┌──────────────────────────┐
│    SessionTemplate       │         │      ScheduledClass      │
├──────────────────────────┤         ├──────────────────────────┤
│ - id: String             │         │ - id: String             │
│ - title: String          │         │ - templateId: String     │
│ - ageGroup: String       │◄────────│ - coachId: String        │
│ - objectives: List<Str>  │    1:N  │ - dateTime: DateTime     │
│ - equipment: List<String>│         │ - studentIds: List<Str>  │
│ - warmUp: String         │         │ - status: String         │
│ - mainActivities: List   │         ├──────────────────────────┤
│ - coolDown: String       │         │ + toMap(): Map           │
│ - drillAnimations: List  │         │ + fromMap(): Class       │
│ - pdfUrl: String         │         └──────────────────────────┘
├──────────────────────────┤                     │
│ + toMap(): Map           │                     │ 1:1
│ + fromMap(): Template    │                     ▼
└──────────────────────────┘         ┌──────────────────────────┐
            │                        │     ActiveSession        │
            │                        ├──────────────────────────┤
            │                        │ - id: String             │
            ▼                        │ - classId: String        │
┌──────────────────────────┐         │ - coachId: String        │
│   DrillAnimationData     │         │ - startTime: DateTime    │
├──────────────────────────┤         │ - endTime: DateTime      │
│ - drillName: String      │         │ - attendance: Map        │
│ - durationMs: int        │         │ - notes: Map<String,Str> │
│ - players: List<Player>  │         ├──────────────────────────┤
│ - balls: List<Ball>      │         │ + toMap(): Map           │
│ - equipment: List<Equip> │         │ + fromMap(): Session     │
├──────────────────────────┤         └──────────────────────────┘
│ + toMap(): Map           │
│ + fromMap(): Animation   │
└──────────────────────────┘

┌──────────────────────────┐         ┌──────────────────────────┐
│    NotificationModel     │         │      PaymentModel        │
├──────────────────────────┤         ├──────────────────────────┤
│ - id: String             │         │ - id: String             │
│ - title: String          │         │ - studentId: String      │
│ - body: String           │         │ - amount: double         │
│ - type: String           │         │ - status: String         │
│ - recipientIds: List     │         │ - dueDate: DateTime      │
│ - sentAt: DateTime       │         │ - paidDate: DateTime     │
│ - readBy: List<String>   │         │ - receiptUrl: String     │
├──────────────────────────┤         ├──────────────────────────┤
│ + toMap(): Map           │         │ + toMap(): Map           │
│ + fromMap(): Notification│         │ + fromMap(): Payment     │
└──────────────────────────┘         └──────────────────────────┘

                    SERVICES LAYER
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  AuthService    │  │FirestoreService │  │ StorageService  │ │
│  ├─────────────────┤  ├─────────────────┤  ├─────────────────┤ │
│  │+signIn()        │  │+getUsers()      │  │+uploadImage()   │ │
│  │+signOut()       │  │+getStudents()   │  │+uploadPdf()     │ │
│  │+getCurrentUser()│  │+getTemplates()  │  │+getDownloadUrl()│ │
│  │+resetPassword() │  │+saveSession()   │  └─────────────────┘ │
│  └─────────────────┘  │+streamClasses() │                      │
│                       └─────────────────┘                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ GeminiPdfService│  │GeminiAnimService│  │NotificationSvc  │ │
│  ├─────────────────┤  ├─────────────────┤  ├─────────────────┤ │
│  │+extractPlan()   │  │+generateAnim()  │  │+sendToTopic()   │ │
│  │+parseResponse() │  │+parseJson()     │  │+sendToUsers()   │ │
│  └─────────────────┘  └─────────────────┘  │+subscribeUser() │ │
│                                            └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

                    VIEWMODEL LAYER
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  AuthViewModel  │  │ AdminViewModel  │  │ CoachViewModel  │ │
│  ├─────────────────┤  ├─────────────────┤  ├─────────────────┤ │
│  │- _authService   │  │- _firestoreSvc  │  │- _firestoreSvc  │ │
│  │- _currentUser   │  │- _users         │  │- _assignedClass │ │
│  │+login()         │  │- _students      │  │- _activeSession │ │
│  │+logout()        │  │+loadUsers()     │  │+loadSchedule()  │ │
│  │+checkAuth()     │  │+createUser()    │  │+startSession()  │ │
│  └─────────────────┘  │+registerStudent │  │+recordAttend()  │ │
│                       └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐                      │
│  │ ParentViewModel │  │TemplateViewModel│                      │
│  ├─────────────────┤  ├─────────────────┤                      │
│  │- _children      │  │- _geminiPdfSvc  │                      │
│  │- _schedule      │  │- _geminiAnimSvc │                      │
│  │+loadChildren()  │  │+extractFromPdf()│                      │
│  │+viewProgress()  │  │+generateAnim()  │                      │
│  │+viewPayments()  │  │+saveTemplate()  │                      │
│  └─────────────────┘  └─────────────────┘                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Entity-Relationship Diagram (ERD)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          Entity-Relationship Diagram                                │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────────┐                           ┌──────────────────┐
    │      USERS       │                           │     STUDENTS     │
    ├──────────────────┤                           ├──────────────────┤
    │ PK uid           │                           │ PK id            │
    │    email         │      1          N         │    name          │
    │    name          │◄──────────────────────────│ FK parentId      │
    │    role          │        has children       │    dateOfBirth   │
    │    profileImage  │                           │    ageGroup      │
    │    createdAt     │                           │    profileImage  │
    │    fcmToken      │                           │    createdAt     │
    └──────────────────┘                           └──────────────────┘
            │                                               │
            │ 1                                             │ N
            │ creates/manages                               │ enrolled in
            ▼ N                                             ▼ M
    ┌──────────────────┐                           ┌──────────────────┐
    │SESSION_TEMPLATES │                           │ SCHEDULED_CLASS  │
    ├──────────────────┤                           ├──────────────────┤
    │ PK id            │       1          N        │ PK id            │
    │    title         │◄──────────────────────────│ FK templateId    │
    │    ageGroup      │      used by              │ FK coachId       │
    │    objectives[]  │                           │    dateTime      │
    │    equipment[]   │                           │    location      │
    │    warmUp        │                           │    status        │
    │    mainActs[]    │                           │    studentIds[]  │
    │    coolDown      │                           └──────────────────┘
    │    drillAnims[]  │                                    │
    │    pdfUrl        │                                    │ 1
    │ FK createdBy     │                                    │ generates
    └──────────────────┘                                    ▼ 1
                                                   ┌──────────────────┐
                                                   │  ACTIVE_SESSION  │
                                                   ├──────────────────┤
                                                   │ PK id            │
                                                   │ FK classId       │
                                                   │ FK coachId       │
                                                   │    startTime     │
                                                   │    endTime       │
                                                   │    attendance{}  │
                                                   │    notes{}       │
                                                   └──────────────────┘
                                                            │
                                                            │ 1
    ┌──────────────────┐                                    │ records
    │  NOTIFICATIONS   │                                    ▼ N
    ├──────────────────┤                           ┌──────────────────┐
    │ PK id            │                           │ SESSION_RECORDS  │
    │    title         │                           ├──────────────────┤
    │    body          │                           │ PK id            │
    │    type          │                           │ FK sessionId     │
    │    recipientIds[]│                           │ FK studentId     │
    │    sentAt        │                           │    attended      │
    │    readBy[]      │                           │    notes         │
    │ FK sentBy        │                           │    performance   │
    └──────────────────┘                           └──────────────────┘

    ┌──────────────────┐                           ┌──────────────────┐
    │     PAYMENTS     │                           │ DRILL_ANIMATIONS │
    ├──────────────────┤                           ├──────────────────┤
    │ PK id            │                           │ PK id            │
    │ FK studentId     │                           │ FK templateId    │
    │    amount        │                           │    drillName     │
    │    status        │                           │    durationMs    │
    │    dueDate       │                           │    players[]     │
    │    paidDate      │                           │    balls[]       │
    │    receiptUrl    │                           │    equipment[]   │
    │    month/term    │                           │    createdAt     │
    └──────────────────┘                           └──────────────────┘

RELATIONSHIP SUMMARY:
─────────────────────
• USERS (1) ──────────► (N) STUDENTS         [Parent has children]
• USERS (1) ──────────► (N) SESSION_TEMPLATES [Admin creates templates]
• USERS (1) ──────────► (N) SCHEDULED_CLASS   [Coach assigned to classes]
• SESSION_TEMPLATES (1)► (N) SCHEDULED_CLASS  [Template used by classes]
• SESSION_TEMPLATES (1)► (N) DRILL_ANIMATIONS [Template has animations]
• SCHEDULED_CLASS (1) ─► (1) ACTIVE_SESSION   [Class has active session]
• ACTIVE_SESSION (1) ──► (N) SESSION_RECORDS  [Session has records]
• STUDENTS (N) ────────► (M) SCHEDULED_CLASS  [Students enrolled in classes]
• STUDENTS (1) ────────► (N) PAYMENTS         [Student has payments]
• USERS (1) ───────────► (N) NOTIFICATIONS    [Admin sends notifications]
```

---

## 5. Data Flow Diagram (DFD)

### Level 0 - Context Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           Level 0: Context Diagram                                  │
└─────────────────────────────────────────────────────────────────────────────────────┘

                              Login Credentials
        ┌─────────┐          ──────────────────►          ┌─────────────────┐
        │         │          User Data, Schedule          │                 │
        │  ADMIN  │◄─────────────────────────────         │                 │
        │         │                                       │                 │
        └─────────┘          Templates, Classes           │                 │
                             ──────────────────►          │                 │
                                                          │                 │
                              Login Credentials           │                 │
        ┌─────────┐          ──────────────────►          │   GOALBUDDY     │
        │         │          Schedule, Template           │     SYSTEM      │
        │  COACH  │◄─────────────────────────────         │                 │
        │         │                                       │                 │
        └─────────┘          Attendance, Notes            │                 │
                             ──────────────────►          │                 │
                                                          │                 │
                              Login Credentials           │                 │
        ┌─────────┐          ──────────────────►          │                 │
        │ PARENT/ │          Child Data, Progress         │                 │
        │ STUDENT │◄─────────────────────────────         │                 │
        │         │                                       │                 │
        └─────────┘                                       └─────────────────┘
                                                                   │
                                                                   │
                    ┌──────────────────────────────────────────────┼────────┐
                    │                                              │        │
                    ▼                                              ▼        ▼
            ┌───────────────┐                           ┌────────────┐ ┌─────────┐
            │   FIREBASE    │                           │ GEMINI AI  │ │   FCM   │
            │  (Firestore,  │                           │   API      │ │ Service │
            │   Storage,    │                           └────────────┘ └─────────┘
            │    Auth)      │
            └───────────────┘
```

### Level 1 - Main Processes

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           Level 1: Main Processes                                   │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────┐                                                              ┌─────────┐
│  ADMIN  │                                                              │  COACH  │
└────┬────┘                                                              └────┬────┘
     │                                                                        │
     │ credentials                                                credentials │
     ▼                                                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     │
│    ┌───────────────┐                                                               │
│    │               │ auth result    ┌─────────────┐                                │
│    │  1.0 USER     │◄──────────────►│  FIREBASE   │                                │
│    │AUTHENTICATION │                │    AUTH     │                                │
│    │               │                │   [D1]      │                                │
│    └───────────────┘                └─────────────┘                                │
│           │                                                                         │
│           │ user session                                                            │
│           ▼                                                                         │
│    ┌───────────────┐     user data  ┌─────────────┐                                │
│    │  2.0 USER     │◄──────────────►│  FIRESTORE  │                                │
│    │  MANAGEMENT   │                │   USERS     │                                │
│    │               │                │   [D2]      │                                │
│    └───────────────┘                └─────────────┘                                │
│           │                                                                         │
│           ▼                                                                         │
│    ┌───────────────┐    student data┌─────────────┐                                │
│    │  3.0 STUDENT  │◄──────────────►│  FIRESTORE  │                                │
│    │  MANAGEMENT   │                │  STUDENTS   │                                │
│    │               │                │   [D3]      │                                │
│    └───────────────┘                └─────────────┘                                │
│           │                                                                         │
│           │ PDF file                                                               │
│           ▼                                                                         │
│    ┌───────────────┐                ┌─────────────┐                                │
│    │  4.0 TEMPLATE │   PDF bytes    │  GEMINI AI  │                                │
│    │  CREATION     │───────────────►│   SERVICE   │                                │
│    │  (AI-POWERED) │◄───────────────│   [D4]      │                                │
│    │               │  extracted JSON│             │                                │
│    └───────────────┘                └─────────────┘                                │
│           │                                                                         │
│           │ drill description        ┌─────────────┐                               │
│           │─────────────────────────►│  GEMINI AI  │                               │
│           │◄─────────────────────────│  ANIMATION  │                               │
│           │    animation JSON        │   [D5]      │                               │
│           │                          └─────────────┘                               │
│           │                                                                         │
│           │ template + PDF           ┌─────────────┐                               │
│           ▼─────────────────────────►│  FIREBASE   │                               │
│    ┌───────────────┐                 │  STORAGE    │                               │
│    │  5.0 CLASS    │                 │   [D6]      │                               │
│    │  SCHEDULING   │                 └─────────────┘                               │
│    │               │                                                               │
│    └───────────────┘    class data   ┌─────────────┐                               │
│           │◄────────────────────────►│  FIRESTORE  │                               │
│           │                          │  CLASSES    │                               │
│           │                          │   [D7]      │                               │
│           ▼                          └─────────────┘                               │
│    ┌───────────────┐                                                               │
│    │  6.0 SESSION  │   session data  ┌─────────────┐                               │
│    │  MANAGEMENT   │◄───────────────►│  FIRESTORE  │                               │
│    │               │                 │  SESSIONS   │                               │
│    └───────────────┘                 │   [D8]      │                               │
│           │                          └─────────────┘                               │
│           │                                                                         │
│           ▼                                                                         │
│    ┌───────────────┐                 ┌─────────────┐                               │
│    │ 7.0 NOTIFI-   │   push message  │    FCM      │                               │
│    │    CATION     │────────────────►│  SERVICE    │──────────► [Mobile Devices]   │
│    │    SYSTEM     │                 │   [D9]      │                               │
│    └───────────────┘                 └─────────────┘                               │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
     │                                                                        │
     │                                                                        │
     │         ┌──────────────────────────────────────────────────┐          │
     └────────►│                    PARENT/STUDENT                 │◄─────────┘
               │  (Receives: Child data, Schedule, Progress,       │
               │   Notifications, Payment status)                  │
               └──────────────────────────────────────────────────┘
```

---

## 6. Sequence Diagrams

Sequence diagrams illustrate the dynamic behavior of the system by showing the interactions between objects over time. Each diagram captures a specific use case scenario, depicting the sequence of messages exchanged between system components to accomplish a particular task.

### 6.1 User Authentication Sequence Diagram

**Description:** This sequence diagram illustrates the authentication process when a user (Admin, Coach, or Parent) attempts to log into the GoalBuddy application. The process begins when the user enters their email and password credentials on the LoginView. The AuthViewModel receives the login request and delegates authentication to the AuthService, which communicates with Firebase Authentication to verify the credentials. Upon successful authentication, the system retrieves the user's role from Firestore to determine which dashboard to display. The AuthViewModel then notifies listeners of the state change, triggering navigation to the appropriate role-based dashboard (AdminDashboardView, CoachDashboardView, or StudentParentDashboardView).

**Actors/Objects:**
- User (Actor)
- LoginView (Boundary)
- AuthViewModel (Control)
- AuthService (Control)
- Firebase Auth (Entity)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│              Sequence Diagram: User Authentication                                  │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────┐          ┌──────────┐       ┌───────────┐      ┌──────────┐      ┌──────────┐
    │User │          │LoginView │       │AuthViewModel│    │AuthService│     │Firebase  │
    │     │          │          │       │            │      │          │      │Auth      │
    └──┬──┘          └────┬─────┘       └─────┬──────┘      └────┬─────┘      └────┬─────┘
       │                  │                   │                  │                 │
       │ Enter email/pwd  │                   │                  │                 │
       │─────────────────►│                   │                  │                 │
       │                  │                   │                  │                 │
       │                  │ login(email, pwd) │                  │                 │
       │                  │──────────────────►│                  │                 │
       │                  │                   │                  │                 │
       │                  │                   │signInWithEmail() │                 │
       │                  │                   │─────────────────►│                 │
       │                  │                   │                  │                 │
       │                  │                   │                  │signInWithEmail │
       │                  │                   │                  │AndPassword()   │
       │                  │                   │                  │───────────────►│
       │                  │                   │                  │                 │
       │                  │                   │                  │   UserCredential│
       │                  ��                   │                  │◄───────────────│
       │                  │                   │                  │                 │
       │                  │                   │   User object    │                 │
       │                  │                   │◄─────────────────│                 │
       │                  │                   │                  │                 │
       │                  │                   │ getUserRole()    │                 │
       │                  │                   │─────────────────►│                 │
       │                  │                   │                  │                 │
       │                  │                   │                  │ getDocument()   │
       │                  │                   │                  │───────────────►│
       │                  │                   │                  │   (Firestore)   │
       │                  │                   │                  │                 │
       │                  │                   │                  │   UserModel     │
       │                  │                   │◄─────────────────│◄───────────────│
       │                  │                   │                  │                 │
       │                  │ notifyListeners() │                  │                 │
       │                  │◄──────────────────│                  │                 │
       │                  │                   │                  │                 │
       │                  │ Navigate to       │                  │                 │
       │ Show Dashboard   │ RoleDashboard     │                  │                 │
       │◄─────────────────│                   │                  │                 │
       │                  │                   │                  │                 │
    ┌──┴──┐          ┌────┴─────┐       ┌─────┴──────┐      ┌────┴─────┐      ┌────┴─────┐
    │User │          │LoginView │       │AuthViewModel│    │AuthService│     │Firebase  │
    └─────┘          └──────────┘       └────────────┘      └──────────┘      └──────────┘
```

---

### 6.2 Schedule Class from Template Sequence Diagram

**Description:** This sequence diagram demonstrates the process of scheduling a new class using a pre-created session template. The Admin selects an existing template from the ScheduleView, which triggers the ScheduleViewModel to fetch available templates from Firestore. The Admin then specifies the class details including date, time, location, and assigned coach. Upon confirmation, the ScheduleViewModel creates a new ScheduledClass document in Firestore that references the selected template. This approach ensures consistency across sessions while allowing flexibility in scheduling, as the same curriculum template can be reused for multiple classes across different time slots and age groups.

**Actors/Objects:**
- Admin (Actor)
- ScheduleView (Boundary)
- ScheduleViewModel (Control)
- FirestoreService (Control)
- Firestore Database (Entity)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│              Sequence Diagram: Schedule Class from Template                         │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────┐       ┌───────────┐    ┌───────────┐    ┌───────────────┐    ┌──────────┐
    │Admin│       │ScheduleView│   │ScheduleVM │    │FirestoreService│   │Firestore │
    │     │       │           │    │           │    │               │    │          │
    └──┬──┘       └─────┬─────┘    └─────┬─────┘    └───────┬───────┘    └────┬─────┘
       │                │                │                  │                 │
       │ Select Template│                │                  │                 │
       │───────────────►│                │                  │                 │
       │                │                │                  │                 │
       │                │loadTemplates() │                  │                 │
       │                │───────────────►│                  │                 │
       │                │                │                  │                 │
       │                │                │ getTemplates()   │                 │
       │                │                │─────────────────►│                 │
       │                │                │                  │                 │
       │                │                │                  │ collection()    │
       │                │                │                  │ .get()          │
       │                │                │                  │────────────────►│
       │                │                │                  │                 │
       │                │                │                  │ List<Template>  │
       │                │                │◄─────────────────│◄────────────────│
       │                │                │                  │                 │
       │                │ Templates List │                  │                 │
       │◄───────────────│◄───────────────│                  │                 │
       │                │                │                  │                 │
       │ Select Date,   │                │                  │                 │
       │ Time, Coach    │                │                  │                 │
       │───────────────►│                │                  │                 │
       │                │                │                  │                 │
       │                │scheduleClass() │                  │                 │
       │                │───────────────►│                  │                 │
       │                │                │                  │                 │
       │                │                │ createClass()    │                 │
       │                │                │─────────────────►│                 │
       │                │                │                  │                 │
       │                │                │                  │ collection()    │
       │                │                │                  │ .add()          │
       │                │                │                  │────────────────►│
       │                │                │                  │                 │
       │                │                │                  │   classId       │
       │                │                │◄─────────────────│◄────────────────│
       │                │                │                  │                 │
       │                │  Success       │                  │                 │
       │ Show Success   │◄───────────────│                  │                 │
       │◄───────────────│                │                  │                 │
       │                │                │                  │                 │
    ┌──┴──┐       ┌─────┴─────┐    ┌─────┴─────┐    ┌───────┴───────┐    ┌────┴─────┐
    │Admin│       │ScheduleView│   │ScheduleVM │    │FirestoreService│   │Firestore │
    └─────┘       └───────────┘    └───────────┘    └───────────────┘    └──────────┘
```

---

### 6.3 Coach Starts Active Session Sequence Diagram

**Description:** This sequence diagram illustrates how a coach initiates an active training session. When the coach selects a scheduled class from their dashboard, the SessionViewModel retrieves the complete class data including the associated template and drill animations from Firestore. The coach can preview the session plan and drill animations before starting. Upon tapping "Start Session," the system creates a new ActiveSession document in Firestore with the current timestamp, class reference, coach ID, and an empty attendance map. The coach is then navigated to the ActiveSessionView where they can view drill animations, take attendance, record individual student notes, and manage the drill timer throughout the session.

**Actors/Objects:**
- Coach (Actor)
- SessionView (Boundary)
- SessionViewModel (Control)
- FirestoreService (Control)
- Firestore Database (Entity)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│              Sequence Diagram: Coach Starts Active Session                          │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────┐     ┌───────────┐   ┌──────────┐   ┌───────────────┐   ┌──────────┐
    │Coach│     │SessionView│   │SessionVM │   │FirestoreService│  │Firestore │
    │     │     │           │   │          │   │               │   │          │
    └──┬──┘     └─────┬─────┘   └────┬─────┘   └───────┬───────┘   └────┬─────┘
       │              │              │                 │                │
       │ Select Class │              │                 │                │
       │─────────────►│              │                 │                │
       │              │              │                 │                │
       │              │loadClassData │                 │                │
       │              │─────────────►│                 │                │
       │              │              │                 │                │
       │              │              │ getClass()      │                │
       │              │              │────────────────►│                │
       │              │              │                 │                │
       │              │              │                 │ doc().get()    │
       │              │              │                 │───────────────►│
       │              │              │                 │                │
       │              │              │                 │ ClassData +    │
       │              │              │                 │ Template +     │
       │              │              │                 │ Animations     │
       │              │◄─────────────│◄────────────────│◄───────────────│
       │              │              │                 │                │
       │ Display Class│              │                 │                │
       │ with Template│              │                 │                │
       │◄─────────────│              │                 │                │
       │              │              │                 │                │
       │ Tap "Start   │              │                 │                │
       │  Session"    │              │                 │                │
       │─────────────►│              │                 │                │
       │              │              │                 │                │
       │              │startSession()│                 │                │
       │              │─────────────►│                 │                │
       │              │              │                 │                │
       │              │              │createSession()  │                │
       │              │              │────────────────►│                │
       │              │              │                 │                │
       │              │              │                 │add({           │
       │              │              │                 │ classId,       │
       │              │              │                 │ coachId,       │
       │              │              │                 │ startTime,     │
       │              │              │                 │ attendance:{}  │
       │              │              │                 │})              │
       │              │              │                 │───────────────►│
       │              │              │                 │                │
       │              │              │                 │  sessionId     │
       │              │              │◄────────────────│◄───────────────│
       │              │              │                 │                │
       │              │ Navigate to  │                 │                │
       │ Show Active  │ActiveSession │                 │                │
       │ Session View │              │                 │                │
       │◄─────────────│◄─────────────│                 │                │
       │              │              │                 │                │
    ┌──┴──┐     ┌─────┴─────┐   ┌────┴─────┐   ┌───────┴───────┐   ┌────┴─────┐
    │Coach│     │SessionView│   │SessionVM │   │FirestoreService│  │Firestore │
    └─────┘     └───────────┘   └──────────┘   └───────────────┘   └──────────┘
```

---

### 6.4 Parent Views Child Progress Sequence Diagram

**Description:** This sequence diagram depicts how a parent accesses and views their child's progress within the application. When the parent opens the Progress tab, the ProgressView triggers the ParentViewModel to load the child's session history. The FirestoreService queries the sessions collection for all sessions where the child's ID appears in the studentIds array, ordered by date. For each session retrieved, the system also fetches the corresponding session notes that contain coach feedback specific to that child. The compiled data including attendance records, session details, and personalized coach notes is displayed as progress cards. Parents can tap on any session card to view detailed feedback in a modal dialog, providing transparency into their child's development and performance.

**Actors/Objects:**
- Parent (Actor)
- ProgressView (Boundary)
- ParentViewModel (Control)
- FirestoreService (Control)
- Firestore Database (Entity)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│              Sequence Diagram: Parent Views Child Progress                          │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌──────┐     ┌────────────┐   ┌──────────┐   ┌───────────────┐   ┌──────────┐
    │Parent│     │ProgressView│   │ ParentVM │   │FirestoreService│  │Firestore │
    │      │     │            │   │          │   │               │   │          │
    └──┬───┘     └──────┬─────┘   └────┬─────┘   └───────┬───────┘   └────┬─────┘
       │                │              │                 │                │
       │ Open Progress  │              │                 │                │
       │ Tab            │              │                 │                │
       │───────────────►│              │                 │                │
       │                │              │                 │                │
       │                │loadProgress()│                 │                │
       │                │─────────────►│                 │                │
       │                │              │                 │                │
       │                │              │getChildSessions │                │
       │                │              │(childId)        │                │
       │                │              │────────────────►│                │
       │                │              │                 │                │
       │                │              │                 │ collection     │
       │                │              │                 │ ('sessions')   │
       │                │              │                 │ .where(student │
       │                │              │                 │  Ids.contains) │
       │                │              │                 │ .orderBy(date) │
       │                │              │                 │───────────────►│
       │                │              │                 │                │
       │                │              │                 │List<Session>   │
       │                │              │◄────────────────│◄───────────────│
       │                │              │                 │                │
       │                │              │ For each session│                │
       │                │              │ getSessionNotes │                │
       │                │              │────────────────►│                │
       │                │              │                 │                │
       │                │              │                 │ doc().get()    │
       │                │              │                 │───────────────►│
       │                │              │                 │                │
       │                │              │                 │ notes{childId: │
       │                │              │                 │  "feedback"}   │
       │                │              │◄────────────────│◄───────────────│
       │                │              │                 │                │
       │                │ Sessions +   │                 │                │
       │                │ Notes +      │                 │                │
       │                │ Attendance   │                 │                │
       │                │◄─────────────│                 │                │
       │                │              │                 │                │
       │ Display        │              │                 │                │
       │ Progress Cards │              │                 │                │
       │◄───────────────│              │                 │                │
       │                │              │                 │                │
       │ Tap Session    │              │                 │                │
       │ for Details    │              │                 │                │
       │───────────────►│              │                 │                │
       │                │              │                 │                │
       │ Show Detail    │              │                 │                │
       │ Modal with     │              │                 │                │
       │ Coach Notes    │              │                 │                │
       │◄───────────────│              │                 │                │
       │                │              │                 │                │
    ┌──┴───┐     ┌──────┴─────┐   ┌────┴─────┐   ┌───────┴───────┐   ┌────┴─────┐
    │Parent│     │ProgressView│   │ ParentVM │   │FirestoreService│  │Firestore │
    └──────┘     └────────────┘   └──────────┘   └───────────────┘   └──────────┘
```

---

### 6.5 AI Generate Drill Animation Sequence Diagram

**Description:** This sequence diagram showcases the AI-powered drill animation generation feature, which is a key innovation of the GoalBuddy system. When an admin enters a textual description of a football drill (e.g., "Passing drill with 4 players in a square formation"), the TemplateViewModel sends this description to the GeminiAnimationService. The service constructs a specialized prompt and makes an API call to Google's Gemini 2.0 Flash model, requesting a JSON response containing player positions, movement paths, ball trajectories, and equipment placement. The Gemini API processes the natural language description and returns structured animation data. The GeminiAnimationService parses this JSON response into a DrillAnimationData object, which is then rendered as a live preview using Flutter's CustomPainter. The admin can review the animation before saving the complete template to Firestore.

**Actors/Objects:**
- Admin (Actor)
- TemplateView (Boundary)
- TemplateViewModel (Control)
- GeminiAnimationService (Control)
- Gemini API (External System)
- Firestore Database (Entity)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│              Sequence Diagram: AI Generate Drill Animation                          │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────┐    ┌────────────┐  ┌───────────┐  ┌────────────┐  ┌─────────┐  ┌─────────┐
    │Admin│    │TemplateView│  │TemplateVM │  │GeminiAnimSvc│ │GeminiAPI│  │Firestore│
    │     │    │            │  │           │  │            │  │         │  │         │
    └──┬──┘    └──────┬─────┘  └─────┬─────┘  └──────┬─────┘  └────┬────┘  └────┬────┘
       │              │              │               │              │           │
       │ Enter drill  │              │               │              │           │
       │ description  │              │               │              │           │
       │─────────────►│              │               │              │           │
       │              │              │               │              │           │
       │ Tap "Generate│              │               │              │           │
       │  Animation"  │              │               │              │           │
       │─────────────►│              │               │              │           │
       │              │              │               │              │           │
       │              │generateAnim()│               │              │           │
       │              │─────────────►│               │              │           │
       │              │              │               │              │           │
       │              │              │generateDrill  │              │           │
       │              │              │Animation()    │              │           │
       │              │              │──────────────►│              │           │
       │              │              │               │              │           │
       │              │              │               │ POST /models/│           │
       │              │              │               │ gemini-2.0-  │           │
       │              │              │               │ flash:       │           │
       │              │              │               │ generate     │           │
       │              │              │               │──────────────►           │
       │              │              │               │              │           │
       │              │              │               │ Prompt:      │           │
       │              │              │               │ "Generate    │           │
       │              │              │               │ JSON for     │           │
       │              │              │               │ drill:       │           │
       │              │              │               │ {description}│           │
       │              │              │               │ with players,│           │
       │              │              │               │ positions,   │           │
       │              │              │               │ movements"   │           │
       │              │              │               │              │           │
       │              │              │               │   JSON       │           │
       │              │              │               │   Response   │           │
       │              │              │               │◄─────────────│           │
       │              │              │               │              │           │
       │              │              │               │ Parse JSON   │           │
       │              │              │               │ to Animation │           │
       │              │              │               │ Data Model   │           │
       │              │              │               │              │           │
       │              │              │ DrillAnimation│              │           │
       │              │              │ Data object   │              │           │
       │              │              │◄──────────────│              │           │
       │              │              │               │              │           │
       │              │ Show Preview │               │              │           │
       │              │ Animation    │               │              │           │
       │◄─────────────│◄─────────────│               │              │           │
       │              │              │               │              │           │
       │ Tap "Save    │              │               │              │           │
       │  Template"   │              │               │              │           │
       │─────────────►│              │               │              │           │
       │              │              │               │              │           │
       │              │saveTemplate()│               │              │           │
       │              │─────────────►│               │              │           │
       │              │              │               │              │           │
       │              │              │ saveTemplate(template)       │           │
       │              │              │──────────────────────────────────────────►
       │              │              │               │              │           │
       │              │              │               │              │  Success  │
       │              │              │◄──────────────────────────────────────────
       │              │              │               │              │           │
       │              │   Success    │               │              │           │
       │  Success     │◄─────────────│               │              │           │
       │◄─────────────│              │               │              │           │
       │              │              │               │              │           │
    ┌──┴──┐    ┌──────┴─────┐  ┌─────┴─────┐  ┌──────┴─────┐  ┌────┴────┐  ┌────┴────┐
    │Admin│    │TemplateView│  │TemplateVM │  │GeminiAnimSvc│ │GeminiAPI│  │Firestore│
    └─────┘    └────────────┘  └───────────┘  └────────────┘  └─────────┘  └─────────┘
```

---

### 6.6 Send Broadcast Notification Sequence Diagram

**Description:** This sequence diagram illustrates the push notification workflow that enables real-time communication between administrators and app users. The admin composes a notification message through the NotificationView and selects the target recipients, which can be all users, a specific role (coaches only, parents only), or individual users. Upon sending, the NotificationViewModel delegates to the NotificationService, which first persists the notification record to Firestore for history tracking. The service then triggers a Firebase Cloud Function that handles the actual delivery. The Cloud Function retrieves the FCM (Firebase Cloud Messaging) tokens for all targeted recipients from the users collection and calls the FCM API to send a multicast push notification. Recipients receive the notification on their mobile devices in real-time, even when the app is in the background, ensuring timely communication about schedule changes, announcements, or important updates.

**Actors/Objects:**
- Admin (Actor)
- NotificationView (Boundary)
- NotificationViewModel (Control)
- NotificationService (Control)
- Cloud Functions (External System)
- FCM - Firebase Cloud Messaging (External System)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│              Sequence Diagram: Send Broadcast Notification                          │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────┐    ┌────────────┐  ┌───────────┐  ┌──────────────┐  ┌─────────┐  ┌────────┐
    │Admin│    │NotifView   │  │ NotifVM   │  │NotificationSvc│ │CloudFunc│  │  FCM   │
    │     │    │            │  │           │  │              │  │         │  │        │
    └──┬──┘    └──────┬─────┘  └─────┬─────┘  └──────┬───────┘  └────┬────┘  └───┬────┘
       │              │              │               │               │           │
       │ Compose      │              │               │               │           │
       │ Message      │              │               │               │           │
       │─────────────►│              │               │               │           │
       │              │              │               │               │           │
       │ Select       │              │               │               │           │
       │ Recipients   │              │               │               │           │
       │ (All/Role/   │              │               │               │           │
       │  Individual) │              │               │               │           │
       │─────────────►│              │               │               │           │
       │              │              │               │               │           │
       │ Tap "Send"   │              │               │               │           │
       │─────────────►│              │               │               │           │
       │              │              │               │               │           │
       │              │sendNotif()   │               │               │           │
       │              │─────────────►│               │               │           │
       │              │              │               │               │           │
       │              │              │sendBroadcast()│               │           │
       │              │              │──────────────►│               │           │
       │              │              │               │               │           │
       │              │              │               │ Save to       │           │
       │              │              │               │ Firestore     │           │
       │              │              │               │───────────────────────────►
       │              │              │               │               │  (stored) │
       │              │              │               │               │           │
       │              │              │               │ Call Cloud    │           │
       │              │              │               │ Function      │           │
       │              │              │               │──────────────►│           │
       │              │              │               │               │           │
       │              │              │               │               │ Get FCM   │
       │              │              │               │               │ tokens for│
       │              │              │               │               │ recipients│
       │              │              │               │               │           │
       │              │              │               │               │ sendMulti │
       │              │              │               │               │ cast()    │
       │              │              │               │               │──────────►│
       │              │              │               │               │           │
       │              │              │               │               │           │
       │              │              │               │               │ Deliver to│
       │              │              │               │               │ devices   │
       │              │              │               │               │   ────────┼──► [Devices]
       │              │              │               │               │           │
       │              │              │               │               │  Success  │
       │              │              │               │  Success      │◄──────────│
       │              │              │               │◄──────────────│           │
       │              │              │               │               │           │
       │              │              │   Success     │               │           │
       │              │              │◄──────────────│               │           │
       │              │              │               │               │           │
       │              │  Success     │               │               │           │
       │   Success    │◄─────────────│               │               │           │
       │◄─────────────│              │               │               │           │
       │              │              │               │               │           │
    ┌──┴──┐    ┌──────┴─────┐  ┌─────┴─────┐  ┌──────┴───────┐  ┌────┴────┐  ┌───┴────┐
    │Admin│    │NotifView   │  │ NotifVM   │  │NotificationSvc│ │CloudFunc│  │  FCM   │
    └─────┘    └────────────┘  └───────────┘  └──────────────┘  └─────────┘  └────────┘
```

---

## Diagram Placement Guide

| Diagram | Section in Chapter 4 |
|---------|----------------------|
| Use Case Diagram | 4.4 Use Case Modeling |
| Flowcharts (Admin, Coach, Parent) | 4.7.2 Dynamic Models |
| UML Class Diagram | 4.7.1 Static Models |
| Sequence Diagrams (All 6) | 4.7.2 Dynamic Models |
| ERD | 4.8 Data Modeling |
| DFD (Level 0 & Level 1) | 4.5 Data Flow Diagram |

---

*Document generated for GoalBuddy - Little Kickers Coach Companion*
*Final Year Project Thesis*
