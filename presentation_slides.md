# GoalBuddy Presentation Slides
## Copy each slide section into PowerPoint

---

# SLIDE 1: Title

**GoalBuddy - Little Kickers Coach Companion**

An AI-Powered Mobile Application for Youth Football Academy Management

---

**Student Name:** [Your Name]
**Supervisor:** [Supervisor Name]
**Date:** [Presentation Date]

---

# SLIDE 2: Problem Statement

**Current Challenges at Youth Football Academies:**

- **Manual Record Keeping** - Paper-based attendance, Excel spreadsheets for scheduling
- **Communication Gaps** - Parents rely on WhatsApp groups, unclear child progress
- **No Visual Training Aids** - Static PDF lesson plans with long text descriptions
- **Time Management Issues** - Coaches lose track of drill timing during sessions
- **Fragmented Tools** - Google Sheets, WhatsApp, Excel used separately

---

# SLIDE 3: Project Objectives

| # | Objective |
|---|-----------|
| O1 | Develop role-based dashboards for Admin, Coach, and Parent |
| O2 | Implement AI-powered session template creation using Gemini |
| O3 | Create session management workflow with timer and attendance |
| O4 | Enable parents to track child's progress and session history |
| O5 | Implement push notification system for real-time communication |

---

# SLIDE 4: Literature Review - Key Findings

**Existing Solutions Analysis:**

| App | Limitation |
|-----|------------|
| TeamSnap | No AI features, expensive subscription |
| SportsEngine | Complex interface, no drill visualization |
| CoachNow | Video-focused, no session management |

**Gap Identified:** No unified platform with AI-powered drill animations for youth sports

---

# SLIDE 5: Methodology

**Development Approach:** Iterative Model (15 weeks)

| Phase | Duration | Focus |
|-------|----------|-------|
| Planning & Design | Weeks 1-3 | Requirements, Architecture |
| Core Development | Weeks 4-5 | Auth, Dashboards |
| AI Integration | Weeks 6-7 | Gemini PDF & Animation |
| Session Management | Weeks 8-9 | Timer, Attendance |
| Communication | Weeks 10-11 | Notifications |
| Testing & Docs | Weeks 12-15 | UAT, Thesis |

---

# SLIDE 6: Technology Stack

**Frontend:**
- Flutter SDK 3.29.2
- Dart 3.7.2
- Provider (State Management)

**Backend:**
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Cloud Functions

**AI:**
- Google Gemini 2.0 Flash API

---

# SLIDE 7: System Architecture

**[INSERT ARCHITECTURE DIAGRAM HERE]**

MVVM Pattern with Provider State Management

- **Models** - Data structures (User, Session, Template)
- **Views** - UI screens per role
- **ViewModels** - Business logic & state
- **Services** - Firebase & Gemini API integration

---

# SLIDE 8: Key Features Overview

| Role | Key Features |
|------|--------------|
| **Admin** | Create templates, Schedule classes, Manage users, Finance dashboard |
| **Coach** | View schedule, Start sessions, Drill timer, Take attendance, View animations |
| **Parent** | View child's schedule, Track progress, See coach notes, Pay fees |

---

# SLIDE 9: Live Demo - Coach Flow

**[DEMO ON PHONE]**

1. Login as Coach
2. View Dashboard with today's classes
3. Tap "Start Session"
4. Show drill animation playing
5. Demonstrate timer controls
6. Mark attendance (one-tap)

---

# SLIDE 10: Live Demo - AI Features

**[DEMO ON PHONE]**

1. Admin creates new template
2. Upload PDF lesson plan
3. Gemini extracts drill data automatically
4. Generate drill animation from text
5. Preview animation before saving

---

# SLIDE 11: Live Demo - Parent View

**[DEMO ON PHONE]**

1. Login as Parent
2. View child's upcoming classes
3. Check progress tab
4. See attendance history
5. Read coach notes

---

# SLIDE 12: AI Integration - How It Works

**PDF Extraction:**
```
PDF Upload → Gemini 2.0 Flash → JSON Data → Form Autofill
```

**Animation Generation:**
```
Text Description → Gemini API → JSON Animation Data → CustomPainter Rendering
```

**Safe Implementation:** AI generates data only, never executable code

---

# SLIDE 13: Testing Methodology

**Testing Approach:**

| Type | Method |
|------|--------|
| Manual Testing | OnePlus 11 device throughout development |
| Static Analysis | Flutter Analyzer (dart analyze) |
| UAT | 11 participants across 3 roles |
| Interviews | 4 semi-structured interviews |

**Evaluation Tool:** System Usability Scale (SUS) - 10 questions

---

# SLIDE 14: Results - SUS Scores

**Overall SUS Score: 94.32 (Grade A+)**

| Role | Participants | SUS Score | Rating |
|------|--------------|-----------|--------|
| Parent | 4 | 98.75 | Best Imaginable |
| Coach | 4 | 93.75 | Excellent |
| Admin | 3 | 89.17 | Excellent |

**Interpretation:** Score > 90 = "Best Imaginable" usability

---

# SLIDE 15: User Feedback Highlights

**Coach Ahmad Tarmidzi:**
> "The drill animation is actually very, very good. I'm actually amazed when I first saw the animation."

**Parent Aaron Craig:**
> "Everything's in one place... I would use it daily."

**Admin Elena Goh:**
> "It saved a lot of my time, which is I don't need to do manually for their payment."

---

# SLIDE 16: Objectives Achievement

| Objective | Status | Evidence |
|-----------|--------|----------|
| O1: Role-based dashboards | ✓ Achieved | 3 dashboards, ratings 4.67-5.00 |
| O2: AI template creation | ✓ Achieved | PDF extraction & animation working |
| O3: Session management | ✓ Achieved | Timer & attendance rated 5.00 |
| O4: Parent progress tracking | ✓ Achieved | All parent features rated 5.00 |
| O5: Push notifications | ✓ Achieved | FCM delivery verified |

**All 5 objectives successfully achieved**

---

# SLIDE 17: Limitations

**Technical:**
- Android only (iOS not tested)
- Requires internet connection
- AI response occasionally needs cleanup

**Evaluation:**
- Sample size: 11 participants
- Controlled environment testing only
- No long-term usage data

---

# SLIDE 18: Future Work

**Based on User Feedback:**

| Enhancement | Suggested By |
|-------------|--------------|
| Payment receipt upload | Elena Goh (Admin) |
| Coach schedule visibility | Muhammad Ikmal (Coach) |
| Self-service class rescheduling | Nasrul (Parent) |

**Technical Enhancements:**
- iOS deployment
- Offline mode
- Advanced analytics

---

# SLIDE 19: Conclusion

**Key Achievements:**
- All 5 objectives achieved
- SUS Score: 94.32 (Excellent/Best Imaginable)
- Positive feedback from all user roles
- Ready for pilot deployment

**Contribution:**
- Demonstrates AI integration in sports coaching apps
- Provides reference implementation for Flutter + Firebase + Gemini

---

# SLIDE 20: Q&A

**Thank You**

**Questions?**

---

**Contact:** [Your Email]
**GitHub:** [Repository Link if applicable]

---

# END OF SLIDES

## Notes for PowerPoint Creation:

1. **Font:** Use clean sans-serif (Calibri, Arial, or Segoe UI)
2. **Colors:** Use GoalBuddy colors - Green (#2D5016), White, Red accent
3. **Diagrams:** Insert from thesis_diagrams.md where indicated
4. **Screenshots:** Take from your OnePlus 11 during demo prep
5. **Keep text minimal** - You'll explain verbally
6. **Practice timing:** ~45 seconds per slide = 15 minutes total
