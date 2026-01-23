# CHAPTER 1: INTRODUCTION

## 1.1 Introduction

Youth football academies play a vital role in developing children's physical abilities, social skills, and foundational sports knowledge from an early age. In Malaysia, organizations such as Little Kickers provide structured football training programs for children aged 18 months to 8 years, categorizing them into age-appropriate groups to ensure effective skill development. Managing these academies involves coordinating multiple stakeholders including administrators, coaches, and parents while handling complex operational tasks such as session scheduling, attendance tracking, and progress monitoring.

The current landscape of youth football academy management predominantly relies on manual processes and fragmented digital tools. Administrators often use spreadsheets for student registration, paper-based lesson plans for session delivery, and messaging applications for parent communication. This disjointed approach leads to inefficiencies, data inconsistencies, and communication gaps that ultimately affect the quality of training delivery and stakeholder satisfaction.

The emergence of cross-platform mobile development frameworks such as Flutter, combined with cloud-based backend services like Firebase and artificial intelligence capabilities through Google Gemini, presents an opportunity to develop an integrated solution that addresses these operational challenges. A unified mobile application can streamline administrative workflows, enhance coach productivity during sessions, and improve parent engagement through real-time access to their child's progress.

This project presents the development of GoalBuddy, a comprehensive mobile application designed as a coach companion system for Little Kickers football academy. The application integrates role-based dashboards for administrators, coaches, and parents, featuring AI-powered automation for lesson plan extraction and drill animation generation. By leveraging modern technologies, GoalBuddy aims to transform how youth football academies operate, ultimately improving the training experience for young children.


## 1.2 Problem Statement

Youth football academies face several operational challenges that hinder efficient management and quality service delivery. Through observation and stakeholder consultation at Little Kickers academy, the following three key problems have been identified:

**Problem 1: Difficulty in Understanding and Preparing Lesson Plans for Coaches**

Little Kickers headquarters provides standardized curriculum materials in PDF format to branch administrators, who then distribute these documents to coaches before training sessions. Coaches are required to study these lesson plans independently, which involves reading through lengthy text descriptions, identifying required equipment, understanding drill progressions (easier and harder variations), and noting learning objectives for each activity. This preparation process is time-consuming and cognitively demanding, particularly when coaches need to quickly reference specific drill details during active sessions with young children running around.

Furthermore, the static PDF format with text-heavy descriptions lacks visual aids to help coaches understand and demonstrate drill movements. Children aged 18 months to 8 years learn primarily through visual observation rather than verbal instructions (Bandura, 1977; Ste-Marie et al., 2012), making it difficult for coaches to effectively communicate exercise patterns when they themselves must interpret abstract written descriptions. As one coach noted during stakeholder consultation, reading through "very long bodies of text" to recall how a drill works is "not very time efficient" during live sessions.

**Problem 2: Fragmented Attendance Tracking and Limited Progress Visibility**

Student attendance is currently recorded using paper registers or basic spreadsheets that are not synchronized across stakeholders. Coaches mark attendance manually during sessions, but this data is not easily accessible to administrators for analysis or to parents for monitoring their child's participation. Calculating attendance rates, identifying patterns of absenteeism, and tracking individual student progress over time requires manual compilation of records. Parents have no real-time visibility into their child's attendance history, earned achievements, or overall progress, leading to frequent inquiries and communication overhead between the academy and families.

**Problem 3: Lack of Session Transparency and Disconnected Communication**

Communication between administrators, coaches, and parents occurs through multiple disconnected channels including phone calls, WhatsApp messages, and emails. When classes are scheduled or rescheduled, administrators must manually notify assigned coaches and parents of enrolled students through separate messages. This fragmentation results in missed notifications about schedule changes, delayed announcements, and inconsistent information delivery.

Critically, parents and students have no visibility into what activities or drills will be conducted in upcoming sessions. Unlike formal educational settings where parents can view syllabi or lesson topics in advance, youth sports academies typically provide no pre-session information about training content. This lack of transparency prevents parents from preparing their children mentally for activities, discussing upcoming drills at home to build excitement, or understanding what specific skills are being developed during each session. There is no centralized system where stakeholders can view relevant information based on their role, leading to confusion and reduced engagement.


## 1.3 Project Objectives

The following three objectives have been established to directly address each identified problem:

**Objective 1:** To develop an AI-powered session template system that transforms PDF lesson plans into structured, visual formats using Google Gemini, including automatic extraction of drill details (equipment, instructions, progressions) and generation of animated visual aids to help coaches quickly understand and demonstrate movements to young children.

*This objective addresses Problem 1 by converting text-heavy PDF documents into easily digestible session templates with AI-generated drill animations, reducing coach preparation time and providing visual references that can be quickly accessed during active sessions.*

**Objective 2:** To implement a real-time attendance tracking and progress monitoring system that synchronizes data across administrators, coaches, and parents, providing comprehensive visibility into student participation, attendance history, and badge achievements.

*This objective addresses Problem 2 by digitizing attendance records with real-time synchronization and providing parents with a dedicated dashboard to monitor their child's progress.*

**Objective 3:** To develop an integrated communication system with session plan visibility, enabling parents to view upcoming class activities and drills in advance, while automatically notifying relevant stakeholders based on their roles when classes are scheduled through push notifications.

*This objective addresses Problem 3 by implementing role-based push notifications through Firebase Cloud Messaging and providing parents access to session plans before classes, ensuring centralized information delivery and increased transparency about training content.*


## 1.4 Project Scope

The scope of this project encompasses the following boundaries:

**Inclusions:**

The application targets Little Kickers football academy operations, specifically designed for children aged 18 months to 8 years across four age groups: Little Kicks (1.5-2.5 years), Junior Kickers (2.5-3.5 years), Mighty Kickers (3.5-5 years), and Mega Kickers (5-8 years).

The system supports three user roles with dedicated interfaces: administrators who manage coaches, students, session templates, and class scheduling; coaches who conduct active sessions, navigate through drills, and mark attendance; and parents who view their child's schedule, attendance history, and earned badges.

Core functionalities include user authentication with Firebase Auth supporting email/password and Google Sign-In, session template creation with AI-powered PDF extraction using Google Gemini, AI-generated drill animations rendered through custom Canvas painters, class scheduling with automatic student assignment based on age group, active session management with countdown timers and drill navigation, real-time attendance marking synchronized to both session and student records, push notifications via Firebase Cloud Messaging triggered by Cloud Functions, and a parent dashboard displaying attendance statistics, streaks, and badge achievements.

The application is developed using Flutter framework (Dart SDK 3.9.2) for cross-platform deployment on Android, iOS, and web browsers. Firebase provides backend services including Authentication, Cloud Firestore for real-time database, Cloud Storage for file uploads, Cloud Messaging for push notifications, and Cloud Functions for serverless automation.

**Exclusions:**

Online payment gateway integration is not included; payment tracking is limited to receipt upload and AI-based data extraction for verification purposes. Live video streaming, video calling, or real-time video features are outside the scope. Multi-academy or franchise management with separate data isolation is not supported. Advanced business intelligence dashboards, predictive analytics, and machine learning-based recommendations beyond the specified AI features are excluded.


## 1.5 Significance of Study

This project contributes to the field of sports management technology and provides practical benefits to multiple stakeholders:

**For Youth Football Academies:**
GoalBuddy provides a comprehensive digital solution that standardizes session delivery through structured templates, improves operational efficiency through centralized data management, and enhances stakeholder communication through automated notifications. The system bridges the gap between headquarters curriculum delivery and on-ground coaching execution.

**For Coaches:**
The application significantly reduces the cognitive burden of lesson plan preparation by transforming text-heavy PDF documents into structured, visual formats. AI-generated drill animations provide instant visual references that coaches can access during active sessions, eliminating the need to read through lengthy descriptions while children are waiting. The visual timers and one-tap attendance marking further streamline session management, allowing coaches to focus on actual coaching rather than administrative tasks.

**For Parents:**
The dedicated parent dashboard improves transparency by providing real-time access to their child's class schedule, attendance records, and badge achievements. Critically, parents can now view upcoming session plans and drill activities before classes, enabling them to prepare their children mentally, discuss upcoming activities at home, and understand what skills are being developed. Push notifications ensure parents stay informed about schedule changes and announcements automatically.

**For Academic Research:**
This project demonstrates the practical integration of generative AI (Google Gemini) into mobile applications for domain-specific tasks including document processing (PDF extraction) and content generation (drill animations). The implementation provides insights into AI-augmented user interfaces in specialized contexts like youth sports coaching, particularly for transforming static instructional content into dynamic visual aids.


## 1.6 Project Timeline

The project follows a phased development approach. The timeline is illustrated in the Gantt chart below:

**[INSERT GANTT CHART HERE]**

**Table 1.1: Project Timeline**

| Phase | Activities | Duration |
|-------|------------|----------|
| Phase 1: Planning & Analysis | Requirements gathering, stakeholder interviews, system analysis, UI/UX design | Weeks 1-2 |
| Phase 2: Design | System architecture design, database schema design, interface prototyping | Week 3 |
| Phase 3: Core Development | Firebase setup, authentication module, role-based dashboards, user management | Weeks 4-5 |
| Phase 4: AI Integration | Session templates, Gemini PDF extraction, drill animation generation | Weeks 6-7 |
| Phase 5: Session Management | Active session module, drill timer, attendance tracking, student progress | Weeks 8-9 |
| Phase 6: Communication Features | Push notifications, Cloud Functions triggers, parent dashboard | Weeks 10-11 |
| Phase 7: Testing & Refinement | Unit testing, integration testing, user acceptance testing, bug fixes | Weeks 12-13 |
| Phase 8: Documentation | Thesis writing, deployment preparation, final presentation | Weeks 14-15 |


## 1.7 Thesis Organization

This thesis consists of six chapters organized to reflect the systematic approach toward achieving the project objectives. A brief description of each chapter is provided below:

**Chapter 1: Introduction** presents the project background, problem statement, objectives, scope, significance, timeline, and thesis organization. This chapter establishes the foundation and rationale for the study.

**Chapter 2: Literature Review** provides an overview of existing research and applications related to sports management systems, mobile application development frameworks, cloud computing services, and artificial intelligence in software applications. This chapter establishes the theoretical foundation and identifies gaps addressed by this project.

**Chapter 3: Methodology** describes the development methodology adopted for this project, including the software development life cycle model, development tools and technologies, and the systematic approach to achieving each objective.

**Chapter 4: System Analysis and Design** presents the detailed system analysis including functional and non-functional requirements, use case specifications, system architecture, object-oriented design with UML diagrams, data modeling, and user interface design.

**Chapter 5: Implementation and Testing** documents the implementation process, key code components, AI integration details, and testing procedures including the results of functional testing and user acceptance testing.

**Chapter 6: Conclusion and Future Work** summarizes the project outcomes, evaluates the achievement of each objective against the identified problems, discusses limitations encountered, and proposes recommendations for future enhancements.

In summary, this chapter has introduced the GoalBuddy project, identified three key problems faced by youth football academies: (1) difficulty for coaches in understanding and preparing text-heavy lesson plans, (2) fragmented attendance tracking with limited progress visibility for parents, and (3) lack of session transparency and disconnected communication between stakeholders. Three corresponding objectives have been established to address these problems through AI-powered visual drill animations, real-time attendance synchronization with parent dashboards, and integrated notifications with pre-session visibility for parents. The next chapter presents a comprehensive review of literature related to sports management systems, mobile development technologies, and AI integration in software applications.


---


# CHAPTER 2: LITERATURE REVIEW

## 2.1 Introduction

This chapter presents a comprehensive review of literature relevant to the development of GoalBuddy, a mobile application for youth football academy management. The review examines existing research, technologies, and applications that form the theoretical and technical foundation of this project. The literature is organized into four main clusters: youth sports management systems, cross-platform mobile development frameworks, cloud computing and backend services, and artificial intelligence in software applications.

The purpose of this literature review is to establish the context of the project within existing knowledge, identify gaps in current solutions that this project addresses, and justify the selection of technologies and approaches used in the development of GoalBuddy. Sources include academic journals, conference proceedings, official documentation, and industry reports published within the past five to ten years.


## 2.2 Background

### 2.2.1 Youth Football Academy Operations

Youth football academies provide structured training programs designed to develop children's motor skills, coordination, and foundational football abilities. According to Côté and Hancock (2016), early sports participation between ages 2-6 years focuses on fundamental movement skills rather than sport-specific techniques, emphasizing play-based learning and enjoyment. This aligns with the Little Kickers curriculum which categorizes children into age-appropriate groups: Little Kicks (1.5-2.5 years), Junior Kickers (2.5-3.5 years), Mighty Kickers (3.5-5 years), and Mega Kickers (5-8 years).

Basic motor skills, also referred to as fundamental movement skills (FMS), are recognized as the foundational movements that enable children to interact with their environment (Zhang et al., 2024). These skills serve as the basic structure upon which more complex movements are built (Hurtado-Almonacid et al., 2024), and their acquisition involves continuous modification during childhood through interplay between neuromuscular maturation, growth, and new motor experiences. FMS are broadly categorized into locomotor skills (e.g., running, galloping, hopping), manipulative or object control skills (e.g., kicking, catching, throwing), and non-locomotor stability skills. The period from 0 to 6 years is deemed particularly crucial for their development, often highlighted as a "critical window of opportunity" due to higher neuronal plasticity (Moreno et al., 2021).

Research by Hurtado-Almonacid et al. (2024) reported concerning findings that many children aged 3 to 10 fall into very poor to low-average categories for locomotion, manipulation, and overall motor competence, with motor age often lagging behind chronological age. This emphasizes the urgent need for structured early intervention programs like those offered by youth football academies.

The operational aspects of youth sports academies involve multiple interconnected processes including student enrollment, session scheduling, coach assignment, attendance tracking, and parent communication (Wiersma & Sherman, 2005). These processes traditionally rely on manual methods such as paper registers, spreadsheets, and verbal communication, which create inefficiencies as academies scale their operations.

### 2.2.2 Football as a Vehicle for Motor Development

Football, being one of the most popular sports globally, offers an accessible and engaging platform for children to fulfill their physical activity needs (Grygus et al., 2024). Its dynamic nature inherently involves a variety of basic motion activities, making it an effective medium to promote the development of fundamental movements in children. For children aged 6 to 10 years, FIFA's grassroots development program designates this period as the "Fun Phase," where the primary goal is to foster joy and love for the sport through play-based approaches rather than complex tactics (Conra et al., 2021).

Research by Conra et al. (2021) demonstrated that game-based soccer training models for children aged 6-8 years significantly improved both locomotor and manipulative motion skills. Their study developed 33 game-based training models that proved effective in enhancing fundamental movement skills while maintaining engagement through play. This approach ensures that children improve their basic movements through soccer training adapted to their age characteristics without realizing they are practicing.

Grygus et al. (2024) further emphasized that age-specific training approaches are essential, with game-based exercises in football training for younger age groups (4-10 years) leading to better engagement and more effective motor skill development compared to traditional drill-based approaches. Football club activities help compensate for insufficient physical activity and promote health in young people when delivered through developmentally appropriate methods.

### 2.2.3 Digital Transformation in Sports Management

The sports industry has increasingly adopted digital technologies to improve operational efficiency and stakeholder engagement. Ratten (2020) identifies mobile applications, cloud computing, and data analytics as key enablers of digital transformation in sports organizations. For youth sports specifically, digital tools have been shown to improve parent engagement, streamline administrative tasks, and enhance the quality of coaching delivery (Dorsch et al., 2021).

Mobile applications are increasingly utilized in children's learning and physical activity contexts. According to Semartiana et al. (2022), mobile apps are commonly used for gamification in children's learning processes, with children generally preferring interactive applications because they offer innovative experiences that increase motivation. This trend has driven the development of new approaches that combine elements of engagement with educational and developmental content.

The COVID-19 pandemic accelerated digital adoption in youth sports, with organizations implementing online registration, digital communication platforms, and virtual training resources (Shepherd et al., 2021). This shift highlighted both the potential and the gaps in existing digital solutions for youth sports management.

### 2.2.4 Visual Learning in Early Childhood Sports Education

Children aged 2-8 years are predominantly visual learners who acquire motor skills through observation and imitation (Bandura, 1977). Research by Williams and Hodges (2005) demonstrates that visual demonstrations significantly improve skill acquisition in young athletes compared to verbal instructions alone. This is particularly relevant for toddler-age programs where language comprehension is still developing.

Animation and video-based instruction have been shown to be effective tools for teaching movement patterns to young children (Ste-Marie et al., 2012). Moreno et al. (2021) demonstrated that mobile applications can effectively assess and enhance motor skills in children through interactive exercises, capturing objective, quantifiable data on movement precision and coordination abilities. Their research highlighted the potential of mobile apps to serve as both diagnostic tools and training aids for motor development.

Furthermore, Diekhoff and Greve (2023) explored the use of digital technology in game-based football physical education, finding that video tools and digital feedback mechanisms can enhance reflection and understanding of tactical situations. While their study focused on older students, the principles of visual feedback and digital demonstration apply across age groups, supporting the integration of animated visual aids in coaching applications.

However, creating custom animations for specific drills requires specialized skills and resources that most youth sports academies lack, presenting an opportunity for AI-assisted content generation.

### 2.2.5 The Role of Parental Involvement

Parents are pivotal influencers and "gatekeepers" of children's physical development. Research consistently indicates that with appropriate support, parents can significantly improve their children's fundamental motor skills (Zhang et al., 2024). Mobile applications that provide developmentally appropriate activities and instructional content empower parents to facilitate physical development at home.

Zhang et al. (2024) studied the MiniMovers application, which provides motor skill activities for young children with parental involvement. Their findings revealed that when parents engage consistently with such apps, children demonstrate significant improvements in motor skills like running, jumping, kicking, and throwing. Qualitative findings showed high levels of enjoyment from both parents and children, increased parent knowledge about motor competence importance, and enhanced social interaction during physical activities.

These findings underscore the potential of mobile applications to bridge the gap between motor development theory and parental practice, fostering a supportive home environment for physical development. For youth sports academies, providing parents with visibility into their child's progress and training activities through a dedicated dashboard can extend the benefits of structured coaching beyond the academy sessions.


## 2.3 Related Work

### 2.3.1 Review of Existing Sports Management Applications

Several commercial applications currently address sports team and academy management. This section reviews the most relevant solutions and analyzes their strengths and limitations.

#### 2.3.1.1 TeamSnap

TeamSnap is a widely-used team management platform that provides scheduling, availability tracking, and team communication features (TeamSnap, 2023). The application supports multiple sports and offers both free and premium tiers.

**Strengths:** TeamSnap excels in schedule management with calendar integration, availability polling, and automated reminders. The platform supports team-wide messaging and file sharing, facilitating communication between coaches and parents.

**Limitations:** TeamSnap is designed for recreational team sports rather than structured academy programs. It lacks curriculum or lesson plan management features, does not support age-group based automatic student assignment, and provides no AI-powered automation capabilities. The application does not offer visual training aids or drill animation features.

#### 2.3.1.2 SportsEngine

SportsEngine provides comprehensive sports organization management including registration, scheduling, website building, and communication tools (SportsEngine, 2023). The platform is used by large sports organizations and leagues.

**Strengths:** SportsEngine offers robust registration and payment processing, league management with standings and statistics, and customizable organization websites. The platform scales well for large multi-team organizations.

**Limitations:** The complexity of SportsEngine makes it less suitable for small academies focused on young children. The user interface is designed for traditional sports leagues rather than developmental programs. There is no support for session template management, drill libraries, or AI-assisted features.

#### 2.3.1.3 CoachNow

CoachNow focuses on athlete development through video analysis and coaching feedback (CoachNow, 2023). The application allows coaches to share video annotations and training content with athletes.

**Strengths:** CoachNow provides excellent video markup and analysis tools, enabling coaches to provide visual feedback on technique. The platform supports asynchronous communication between coaches and athletes.

**Limitations:** CoachNow is designed for individual athlete coaching rather than group class management. It lacks attendance tracking, class scheduling, and parent portal features essential for youth academy operations. The video-centric approach is less suitable for toddler programs where real-time demonstration is more appropriate than video review.

#### 2.3.1.4 Comparison Summary

**Table 2.1: Comparison of Existing Sports Management Applications**

| Feature | TeamSnap | SportsEngine | CoachNow | GoalBuddy |
|---------|----------|--------------|----------|-----------|
| Class Scheduling | Yes | Yes | No | Yes |
| Attendance Tracking | Basic | Yes | No | Yes (Real-time) |
| Parent Portal | Yes | Yes | Limited | Yes |
| Session Templates | No | No | No | Yes |
| AI PDF Extraction | No | No | No | Yes |
| Drill Animations | No | No | No | Yes (AI-generated) |
| Age Group Management | No | Limited | No | Yes (Automatic) |
| Push Notifications | Yes | Yes | Yes | Yes (Role-based) |
| Young Children Focus | No | No | No | Yes |

The comparison reveals that existing solutions do not adequately address the specific needs of youth football academies serving toddlers and young children. None of the reviewed applications provide AI-powered lesson plan extraction, drill animation generation, or age-group specific management features that GoalBuddy aims to deliver.


### 2.3.2 Cross-Platform Mobile Development Frameworks

The selection of an appropriate mobile development framework is critical for project success. This section reviews the leading cross-platform frameworks considered for GoalBuddy development.

#### 2.3.2.1 Flutter

Flutter is an open-source UI toolkit developed by Google for building natively compiled applications for mobile, web, and desktop from a single codebase (Google, 2023). Flutter uses the Dart programming language and employs a widget-based architecture where the entire UI is composed of nested widgets.

**Technical Characteristics:**
Flutter compiles to native ARM code, providing near-native performance. The framework uses its own rendering engine (Skia) rather than platform UI components, ensuring consistent appearance across platforms. Hot reload functionality enables rapid development iteration without losing application state.

**Advantages for This Project:**
Flutter's widget-based architecture aligns well with the component-driven UI design required for GoalBuddy's multiple dashboards. The CustomPainter API enables creation of custom animations for drill visualization without external dependencies. Strong integration with Firebase services through official FlutterFire plugins simplifies backend implementation.

**Industry Adoption:**
According to the Stack Overflow Developer Survey 2023, Flutter is the most popular cross-platform framework with 14.4% of developers using it. Major applications built with Flutter include Google Pay, BMW, and Alibaba (Flutter, 2023).

#### 2.3.2.2 React Native

React Native, developed by Meta (Facebook), enables mobile application development using JavaScript and React (Meta, 2023). The framework renders native platform components rather than web views.

**Technical Characteristics:**
React Native uses a bridge architecture to communicate between JavaScript and native modules. Components are mapped to native UI elements, providing platform-authentic appearance. The framework leverages the extensive npm ecosystem for third-party packages.

**Comparison with Flutter:**
While React Native benefits from JavaScript's widespread developer familiarity, Flutter offers better performance for animation-heavy applications due to its direct compilation approach (Wu, 2018). For GoalBuddy's requirement of smooth drill animations, Flutter's Skia-based rendering provides advantages over React Native's bridge-dependent architecture.

#### 2.3.2.3 Framework Selection Justification

**Table 2.2: Framework Comparison for GoalBuddy Requirements**

| Criteria | Flutter | React Native | Requirement Fit |
|----------|---------|--------------|-----------------|
| Animation Performance | Excellent (Skia) | Good (Native Bridge) | Critical for drill animations |
| Firebase Integration | Official Plugins | Community Plugins | Important for backend |
| Custom Graphics | CustomPainter API | Requires Native Modules | Required for animation rendering |
| Single Codebase | Yes (Mobile, Web, Desktop) | Yes (Mobile, Web) | Important for maintenance |
| Hot Reload | Yes | Yes | Important for development |
| Learning Curve | Moderate (Dart) | Lower (JavaScript) | Manageable |

Based on this analysis, Flutter was selected for GoalBuddy development due to its superior animation capabilities through CustomPainter, official Firebase integration through FlutterFire, and ability to target web browsers in addition to mobile platforms from a single codebase.


### 2.3.3 Cloud Computing and Backend-as-a-Service

Modern mobile applications increasingly rely on cloud-based backend services to handle authentication, data storage, and server-side logic. This section reviews relevant cloud platforms and services.

#### 2.3.3.1 Firebase Platform

Firebase is Google's mobile and web application development platform providing a comprehensive suite of backend services (Firebase, 2023). The platform follows a Backend-as-a-Service (BaaS) model, eliminating the need for server infrastructure management.

**Core Services Relevant to GoalBuddy:**

**Firebase Authentication** provides secure user authentication supporting multiple sign-in methods including email/password, Google Sign-In, and social providers. The service handles session management, token refresh, and security automatically.

**Cloud Firestore** is a NoSQL document database offering real-time data synchronization across clients. Data is organized in collections and documents with support for complex queries, atomic transactions, and offline persistence. According to Firebase documentation, Firestore can handle millions of concurrent connections with automatic scaling (Firebase, 2023).

**Cloud Storage** provides secure file upload and download capabilities with integration to Firebase Authentication for access control. The service supports large file uploads with automatic retry and resume functionality.

**Firebase Cloud Messaging (FCM)** enables push notification delivery to Android, iOS, and web clients. FCM supports topic-based messaging for broadcasting to user groups and individual device targeting.

**Cloud Functions** provides serverless compute capability triggered by database events, HTTP requests, or scheduled intervals. Functions execute in a managed Node.js environment with automatic scaling.

#### 2.3.3.2 Alternative Backend Solutions

**AWS Amplify** offers similar BaaS capabilities built on Amazon Web Services infrastructure. While powerful, Amplify's complexity and pricing model are less suited for smaller-scale applications compared to Firebase's generous free tier (Serverless Stack, 2022).

**Supabase** provides an open-source Firebase alternative built on PostgreSQL. While offering relational database advantages, Supabase's real-time capabilities and mobile SDK maturity lag behind Firebase for Flutter development (Supabase, 2023).

#### 2.3.3.3 Selection Justification

Firebase was selected for GoalBuddy based on: excellent Flutter integration through official FlutterFire plugins, real-time synchronization capabilities essential for attendance tracking, comprehensive free tier supporting development and initial deployment, and integrated services reducing architectural complexity.


### 2.3.4 Artificial Intelligence in Mobile Applications

The integration of AI capabilities into mobile applications has expanded significantly with the availability of cloud-based AI services and on-device machine learning frameworks.

#### 2.3.4.1 Google Gemini

Google Gemini is a family of multimodal AI models capable of processing text, images, audio, and video inputs (Google AI, 2024). The Gemini API provides access to these capabilities through REST endpoints and client libraries.

**Multimodal Capabilities:**
Gemini models can analyze PDF documents, extracting structured information from both text and visual elements. This capability is particularly relevant for processing lesson plan PDFs that contain formatted text, tables, and diagrams. According to Google's technical documentation, Gemini achieves state-of-the-art performance on document understanding benchmarks (Google AI, 2024).

**Text Generation:**
Gemini models generate coherent, contextually appropriate text responses. For GoalBuddy, this capability enables generation of structured JSON data describing drill animations based on textual drill descriptions.

**Integration Approach:**
The google_generative_ai Dart package provides native Flutter integration with Gemini API. Requests can include multiple content types (text and binary data) enabling multimodal inputs like PDF files combined with extraction prompts.

#### 2.3.4.2 AI-Powered Document Processing

Automated document processing using AI has applications across industries including healthcare, legal, and education (Cui et al., 2021). Key techniques include:

**Optical Character Recognition (OCR):** Extracting text from images and scanned documents. While traditional OCR extracts raw text, modern AI approaches understand document structure and semantics.

**Named Entity Recognition (NER):** Identifying and classifying entities within text such as names, dates, and domain-specific terms. For lesson plans, relevant entities include drill names, duration, equipment, and instructions.

**Information Extraction:** Converting unstructured document content into structured data formats. Gemini's ability to output JSON-formatted responses enables direct extraction of drill information into application data structures.

#### 2.3.4.3 AI-Generated Visual Content

Generative AI models can create visual content including images, animations, and diagrams based on textual descriptions. While image generation models like DALL-E and Stable Diffusion create raster graphics, procedural content generation approaches produce structured data that applications render programmatically.

For GoalBuddy's drill animations, a procedural approach is more appropriate than image generation:

**Procedural Animation Data:** AI generates JSON describing player positions, movement paths, and timing. The application renders this data using custom drawing code, ensuring consistent visual style and enabling interactive playback controls.

**Advantages:** This approach provides smaller data size compared to video or GIF animations, consistent rendering across devices, ability to modify animations programmatically, and integration with application theming.

#### 2.3.4.4 AI Integration in GoalBuddy

GoalBuddy integrates Gemini AI for two primary functions:

**PDF Lesson Plan Extraction:** Administrators upload PDF curriculum documents. The application sends PDF bytes to Gemini with a structured prompt requesting extraction of session title, age group, badge focus, and drill details (title, duration, instructions, equipment, progressions, learning goals). Gemini returns JSON-formatted data that populates the session template form.

**Drill Animation Generation:** For each drill, administrators can request AI-generated animation. The application sends drill details (title, instructions, equipment) to Gemini with a prompt describing the required animation JSON schema. Gemini generates animation data including player paths, ball movements, and equipment positions that the DrillAnimationPlayer widget renders using Flutter's CustomPainter.


### 2.3.5 State Management in Flutter Applications

Effective state management is essential for maintaining consistent UI behavior and data flow in Flutter applications. Several approaches exist with varying complexity and use cases.

#### 2.3.5.1 Provider Pattern

Provider is the recommended state management approach for Flutter applications according to official documentation (Flutter, 2023). The pattern uses InheritedWidget to propagate state down the widget tree with ChangeNotifier enabling reactive updates.

**Architecture with Provider:**
The MVVM (Model-View-ViewModel) architecture pairs naturally with Provider. ViewModels extend ChangeNotifier and expose state properties and methods. Views use Consumer or context.watch to rebuild when state changes. This separation enables unit testing of business logic independent of UI.

**Advantages:** Provider is lightweight with minimal boilerplate, officially supported by the Flutter team, sufficient for medium-complexity applications, and easy to understand for developers new to Flutter.

#### 2.3.5.2 Alternative Approaches

**BLoC (Business Logic Component)** uses streams for state management, providing strong separation between UI and logic. While powerful, BLoC introduces significant boilerplate code that may be excessive for GoalBuddy's requirements (Soares, 2019).

**Riverpod** is an evolution of Provider offering compile-time safety and improved testability. However, its relatively recent introduction means fewer community resources compared to Provider (Riverpod, 2023).

#### 2.3.5.3 Selection for GoalBuddy

Provider with MVVM architecture was selected for GoalBuddy based on: alignment with Flutter team recommendations, appropriate complexity level for the application scope, extensive documentation and community support, and natural fit with Firebase's stream-based data delivery.


## 2.4 Summary

This chapter reviewed literature across four key areas relevant to GoalBuddy development. The review of existing sports management applications revealed that current solutions do not adequately address the specific needs of youth football academies serving young children, particularly lacking AI-powered automation and visual training aids. The analysis of cross-platform frameworks justified the selection of Flutter for its superior animation capabilities and Firebase integration. The examination of cloud services confirmed Firebase as the appropriate backend platform providing real-time synchronization, authentication, and serverless functions. Finally, the review of AI technologies established Google Gemini as a capable solution for PDF document extraction and procedural content generation.

**Table 2.3: Literature Review Summary**

| Area | Key Findings | Application to GoalBuddy |
|------|--------------|--------------------------|
| Sports Management Apps | Existing solutions lack AI features, drill animations, and young children focus | Opportunity to address unmet needs |
| Mobile Frameworks | Flutter offers superior animation and Firebase integration | Selected for development |
| Cloud Services | Firebase provides comprehensive BaaS with real-time sync | Selected for backend |
| AI Technologies | Gemini enables multimodal document processing and content generation | Integrated for PDF extraction and animation |
| State Management | Provider with MVVM balances simplicity and structure | Adopted for architecture |

The literature review confirms a gap in existing solutions for youth football academy management, particularly for programs serving toddlers and young children. GoalBuddy addresses this gap by combining proven technologies (Flutter, Firebase) with innovative AI integration (Gemini) to deliver features not available in current market offerings.

The next chapter presents the methodology adopted for GoalBuddy development, detailing the software development life cycle model, tools and technologies, and systematic approach to achieving each project objective.


## References for Chapter 2

- Bandura, A. (1977). Social Learning Theory. Prentice Hall.
- CoachNow. (2023). CoachNow Platform Overview. Retrieved from https://coachnow.io
- Conra, M. A., Marlina Siregar, N., & Setiakarnawijaya, Y. (2021). Game-based soccer training models for children aged 6-8 years. Gladi: Jurnal Ilmu Keolahragaan, 12(04), 281–290. https://doi.org/10.21009/gjik.124.07
- Côté, J., & Hancock, D. J. (2016). Evidence-based policies for youth sport programs. International Journal of Sport Policy and Politics, 8(1), 51-65.
- Cui, L., et al. (2021). Document AI: Benchmarks, Models and Applications. arXiv preprint.
- Diekhoff, H., & Greve, S. (2023). Digital technology in game-based approaches: Video tagging in football in PE. Physical Education and Sport Pedagogy, 1–13. https://doi.org/10.1080/17408989.2023.2256758
- Dorsch, T. E., et al. (2021). Parent involvement in youth sport: A systematic review. Sport, Exercise, and Performance Psychology, 10(3), 345-363.
- Firebase. (2023). Firebase Documentation. Retrieved from https://firebase.google.com/docs
- Flutter. (2023). Flutter Documentation. Retrieved from https://flutter.dev/docs
- Google AI. (2024). Gemini API Documentation. Retrieved from https://ai.google.dev/docs
- Meta. (2023). React Native Documentation. Retrieved from https://reactnative.dev
- Ratten, V. (2020). Sport technology: A commentary. Journal of High Technology Management Research, 31(1), 100383.
- Shepherd, H. A., et al. (2021). The impact of COVID-19 on youth sport. Frontiers in Sports and Active Living, 3, 630075.
- SportsEngine. (2023). SportsEngine Platform. Retrieved from https://sportsengine.com
- Ste-Marie, D. M., et al. (2012). Observation interventions for motor skill learning and performance. Psychonomic Bulletin & Review, 19(2), 193-220.
- TeamSnap. (2023). TeamSnap Features. Retrieved from https://teamsnap.com
- Grygus, I., Gamma, T., Godlevskyi, P., Zhuk, M., & Zukow, W. (2024). Methodological aspects of developing motor skills in children of different ages during football club activities. Journal of Education Health and Sport, 64, 55525. https://doi.org/10.12775/jehs.2024.64.55525
- Hurtado-Almonacid, J., Reyes-Amigo, T., Yáñez-Sepúlveda, R., Cortés-Roco, G., Oñate-Navarrete, C., Olivares-Arancibia, J., & Páez-Herrera, J. (2024). Development of Basic Motor Skills from 3 to 10 Years of Age: Comparison by Sex and Age Range in Chilean Children. Children, 11(6), 715. https://doi.org/10.3390/children11060715
- Moreno, D. M. N., Vázquez-Araújo, F. J., Castro, P. M., Costa, J. V., Dapena, A., & Doniz, L. G. (2021). Utilization of a Mobile Application for Motor Skill Assessment in Children. Applied Sciences, 11(2), 663. https://doi.org/10.3390/app11020663
- Semartiana, N., Putri, A., & Rosmansyah, Y. (2022). A systematic literature review of gamification for children: Game elements, purposes, and technologies. International Conference on Information Science and Technology Innovation (ICoSTEC), 1(1), 72–76. https://doi.org/10.35842/icostec.v1i1.12
- Wiersma, L. D., & Sherman, C. P. (2005). Volunteer youth sport coaches' perspectives of coaching education. Sport, Education and Society, 10(2), 191-213.
- Williams, A. M., & Hodges, N. J. (2005). Practice, instruction and skill acquisition in soccer. Journal of Sports Sciences, 23(6), 637-650.
- Wu, W. (2018). React Native vs Flutter: A comparison. Medium Engineering Blog.
- Zhang, Y., Wainwright, N., Goodway, J. D., John, A., Stevenson, A., Thomas, K., Jenkins, S., Layas, F., & Piper, K. (2024). MiniMovers: An initial pilot and feasibility study to investigate the impact of a mobile application on children's motor skills and parent support for physical development. Children, 11(1), 99. https://doi.org/10.3390/children11010099


---


# CHAPTER 3: METHODOLOGY

## 3.1 Introduction

This chapter describes the methodology adopted for the development of GoalBuddy, a mobile application for youth football academy management. The methodology encompasses the software development life cycle model, development tools and technologies, system architecture, and the systematic approach to achieving each project objective. A well-defined methodology serves as a roadmap that guides the development process, ensures systematic progress, and enables effective management of project constraints including time, resources, and technical complexity.

The development of GoalBuddy requires careful consideration of multiple factors: the need for cross-platform deployment, real-time data synchronization, AI service integration, and the delivery of a user-friendly interface for three distinct user roles. The selected methodology must accommodate iterative refinement based on testing feedback while maintaining structured progress toward project milestones.

This chapter is organized as follows: Section 3.2 presents the software development life cycle model adopted for this project. Section 3.3 details the development environment, tools, and technologies. Section 3.4 describes the system architecture and design approach. Section 3.5 explains the methodology for achieving each project objective. Section 3.6 discusses project constraints and risk management. Section 3.7 provides the chapter summary.


## 3.2 Software Development Life Cycle Model

### 3.2.1 Selection of Development Model

After evaluating several software development models including Waterfall, V-Model, Spiral, and Agile methodologies, the Agile development methodology with iterative incremental approach was selected for GoalBuddy development. This selection is justified by the following project characteristics:

**Evolving Requirements:** While the core requirements are defined, details of AI integration and user interface design benefit from iterative refinement based on testing and feedback.

**Multiple Integrated Components:** The application integrates multiple services (Firebase, Gemini AI) that require incremental integration and testing rather than big-bang deployment.

**Risk Management:** AI-powered features (PDF extraction, animation generation) involve technical uncertainty that is better managed through early prototyping and iterative improvement.

**Stakeholder Feedback:** Regular demonstrations to stakeholders (supervisor, potential users) enable course correction and validation of development direction.

### 3.2.2 Agile Iterative Incremental Model

The Agile iterative incremental model combines the flexibility of Agile practices with structured iteration cycles. Each iteration (sprint) produces a working increment of the software that can be demonstrated and evaluated.

**Figure 3.1: Agile Iterative Incremental Development Model**

[INSERT DIAGRAM SHOWING ITERATIVE CYCLES]

**Key Practices Adopted:**

**Sprint-Based Development:** Development is organized into 2-3 week sprints, each with defined deliverables. Sprint planning identifies tasks, and sprint review evaluates completed work.

**Incremental Delivery:** Each sprint produces functional software that can be demonstrated. Early sprints deliver core functionality; later sprints add advanced features.

**Continuous Integration:** Code changes are integrated frequently with automated building to detect integration issues early.

**Iterative Refinement:** Feedback from each sprint informs subsequent development. UI designs, AI prompts, and feature implementations are refined based on testing results.

### 3.2.3 Development Phases

The project is organized into the following phases aligned with the iterative model:

**Table 3.1: Development Phases and Activities**

| Phase | Duration | Activities | Deliverables |
|-------|----------|------------|--------------|
| Phase 1: Planning & Analysis | Weeks 1-2 | Requirements gathering, stakeholder analysis, technology evaluation, project planning | Requirements document, technology stack selection, project plan |
| Phase 2: Design | Week 3 | System architecture design, database schema, UI/UX wireframes, API design | Architecture diagram, database schema, UI mockups |
| Phase 3: Sprint 1 - Core | Weeks 4-5 | Firebase setup, authentication, role-based routing, admin dashboard, coach/student registration | Working authentication, basic dashboards, user management |
| Phase 4: Sprint 2 - AI Integration | Weeks 6-7 | Gemini integration, PDF extraction service, session template creation, animation generation | AI-powered template creation, drill animations |
| Phase 5: Sprint 3 - Sessions | Weeks 8-9 | Class scheduling, active session module, drill timer, attendance tracking, student progress | Complete session management workflow |
| Phase 6: Sprint 4 - Communication | Weeks 10-11 | Push notifications, Cloud Functions, parent dashboard, finance module | Notification system, parent features |
| Phase 7: Testing | Weeks 12-13 | Unit testing, integration testing, UAT, bug fixes, performance optimization | Test reports, refined application |
| Phase 8: Deployment | Weeks 14-15 | Documentation, deployment preparation, final presentation | Thesis document, deployed application |


## 3.3 Development Environment and Tools

### 3.3.1 Hardware Requirements

**Table 3.2: Development Hardware Specifications**

| Component | Specification | Purpose |
|-----------|---------------|---------|
| Development Machine | Intel Core i5/AMD Ryzen 5 or higher, 16GB RAM, 256GB SSD | Primary development environment |
| Android Device | Android 8.0+ with 4GB RAM | Physical device testing |
| iOS Device (Optional) | iPhone with iOS 12+ | iOS testing (via macOS) |
| Internet Connection | Stable broadband connection | Cloud services access, API calls |

### 3.3.2 Software Development Tools

**Table 3.3: Development Software and Tools**

| Category | Tool/Technology | Version | Purpose |
|----------|-----------------|---------|---------|
| IDE | Visual Studio Code | Latest | Primary code editor |
| IDE | Android Studio | Latest | Android SDK management, emulator |
| Framework | Flutter | 3.9.2+ | Cross-platform UI development |
| Language | Dart | 3.9.2+ | Programming language |
| Version Control | Git | Latest | Source code management |
| Version Control | GitHub | - | Remote repository hosting |
| Backend | Firebase | Latest | Backend-as-a-Service |
| AI Service | Google Gemini API | gemini-2.0-flash | AI processing |
| Design | Figma | Latest | UI/UX design and prototyping |
| Documentation | Microsoft Word | Latest | Thesis writing |
| Diagramming | Draw.io / Lucidchart | Latest | System diagrams |

### 3.3.3 Technology Stack

The technology stack for GoalBuddy is organized into frontend, backend, and external services layers.

**Figure 3.2: Technology Stack Architecture**

[INSERT TECHNOLOGY STACK DIAGRAM]

### 3.3.4 Flutter Packages and Dependencies

**Table 3.4: Key Flutter Packages**

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | any | Firebase initialization |
| firebase_auth | any | User authentication |
| cloud_firestore | any | Real-time database |
| firebase_storage | any | File storage |
| firebase_messaging | ^15.0.0 | Push notifications |
| cloud_functions | ^5.0.0 | Cloud Functions integration |
| provider | ^6.1.2 | State management |
| google_generative_ai | ^0.4.7 | Gemini AI integration |
| google_sign_in | ^6.1.0 | Google OAuth |
| google_fonts | ^6.1.0 | Typography (Fredoka) |
| file_picker | ^10.3.8 | File selection |
| syncfusion_flutter_pdfviewer | ^28.1.33 | PDF viewing |
| lottie | ^3.1.2 | Lottie animations |
| intl | ^0.19.0 | Date/time formatting |
| percent_indicator | ^4.2.2 | Progress indicators |


## 3.4 System Architecture and Design Approach

### 3.4.1 Architectural Pattern: MVVM

GoalBuddy adopts the Model-View-ViewModel (MVVM) architectural pattern, which provides clear separation of concerns between data, business logic, and user interface.

**Figure 3.3: MVVM Architecture in GoalBuddy**

[INSERT MVVM ARCHITECTURE DIAGRAM]

**Component Responsibilities:**

**Model:** Data classes representing domain objects (User, Student, Session, Drill, etc.). Models include factory constructors for JSON/Firestore parsing and toMap() methods for serialization.

**View:** Flutter widgets that render the user interface. Views observe ViewModels using Provider's Consumer or context.watch and rebuild when state changes. Views do not contain business logic.

**ViewModel:** Classes extending ChangeNotifier that manage UI state and orchestrate business logic. ViewModels call Services for data operations and notify Views of state changes via notifyListeners().

**Services:** Classes responsible for data access and external communication. Services interact with Firebase (Auth, Firestore, Storage, FCM) and external APIs (Gemini). Services are stateless and reusable across ViewModels.

### 3.4.2 Project Structure

The Flutter project follows a feature-organized directory structure:

```
lib/
├── config/
│   ├── theme.dart              # Material 3 theming
│   └── routes.dart             # Navigation routes
├── models/
│   ├── student_model.dart      # Student data class
│   ├── coach_model.dart        # Coach data class
│   ├── session.dart            # Session data class
│   ├── drill_model.dart        # Drill data class
│   ├── session_template.dart   # Template data class
│   ├── notification_model.dart # Notification data class
│   ├── drill_animation_data.dart # Animation structure
│   └── ...
├── services/
│   ├── auth_service.dart       # Firebase Auth operations
│   ├── firestore_service.dart  # Firestore CRUD operations
│   ├── storage_service.dart    # File upload/download
│   ├── notification_service.dart # FCM handling
│   ├── gemini_pdf_service.dart # PDF extraction
│   ├── gemini_animation_service.dart # Animation generation
│   └── ...
├── view_models/
│   ├── auth_view_model.dart    # Authentication state
│   ├── admin_view_model.dart   # Admin operations
│   ├── dashboard_view_model.dart # Coach dashboard
│   ├── attendance_view_model.dart # Attendance management
│   └── ...
├── views/
│   ├── auth/
│   │   └── login_view.dart
│   ├── dashboard/
│   │   ├── admin_dashboard_view.dart
│   │   ├── coach_dashboard_view.dart
│   │   └── student_parent_dashboard_view.dart
│   ├── admin/
│   │   ├── create_session_template_view.dart
│   │   ├── schedule_class_view.dart
│   │   └── ...
│   ├── session/
│   │   ├── active_session_view.dart
│   │   ├── attendance_view.dart
│   │   └── ...
│   └── ...
├── widgets/
│   ├── drill_animation_player.dart # Custom animation widget
│   ├── pdf_upload_button.dart  # PDF autofill component
│   └── ...
├── utils/
│   ├── age_calculator.dart     # Age group calculation
│   └── ...
└── main.dart                   # App entry point
```


## 3.5 Methodology for Achieving Objectives

This section describes the systematic approach to achieving each project objective defined in Chapter 1.

### 3.5.1 Objective 1: AI-Powered Session Template Management

**Objective Statement:** To develop an AI-powered session template management system that automates lesson plan extraction from PDF documents using Google Gemini and generates visual drill animations to assist coaches in demonstrating movements to young children.

**Methodology:**

**Step 1: PDF Upload and Processing Pipeline**

The system provides a user interface for administrators to upload PDF lesson plan documents. The implementation follows these steps:

1. Administrator accesses the "Create Session Template" screen
2. Administrator clicks "Autofill from PDF" button
3. File picker dialog allows selection of PDF file
4. PDF file is read as byte array (Uint8List)
5. PDF bytes are sent to Gemini PDF Service

**Step 2: Gemini AI Integration for PDF Extraction**

The GeminiPdfService class integrates with Google Gemini API for document processing. The service constructs a multimodal request containing:
- Text prompt specifying extraction requirements and JSON schema
- PDF file as binary data part

Gemini processes the document and returns structured JSON containing:
- Session title
- Age group
- Badge focus
- Array of drills with title, duration, instructions, equipment, progressions, and learning goals

**Step 3: Form Auto-Population**

The extracted JSON data is parsed and used to populate the template creation form:
- Title field receives session title
- Age group dropdown is set to extracted value
- Badge focus field is populated
- Drill cards are dynamically created for each extracted drill

**Step 4: AI Animation Generation**

For each drill, administrators can generate visual animations:

1. Administrator clicks "AI Animate" button on drill card
2. Drill details (title, instructions, equipment) are sent to GeminiAnimationService
3. Service constructs prompt requesting animation JSON with specified schema
4. Gemini generates animation data including:
   - Player positions and movement paths (normalized 0.0-1.0 coordinates)
   - Ball positions and trajectories
   - Equipment positions (cones, goals)
   - Timing information (milliseconds)
5. Response is parsed into DrillAnimationData model
6. DrillAnimationPlayer widget renders animation using CustomPainter

**Step 5: Template Storage**

Completed templates are saved to Firebase:
- Template metadata stored in Firestore session_templates collection
- Original PDF uploaded to Cloud Storage
- PDF URL referenced in template document

**Verification Method:**
- Test PDF extraction with 10+ sample lesson plans
- Measure extraction accuracy (target >85%)
- Validate animation generation for various drill types
- User acceptance testing with academy administrators


### 3.5.2 Objective 2: Real-Time Attendance and Progress Monitoring

**Objective Statement:** To implement a real-time attendance tracking and progress monitoring system that synchronizes data across administrators, coaches, and parents, providing comprehensive visibility into student participation, attendance history, and badge achievements.

**Methodology:**

**Step 1: Database Schema Design for Attendance**

Attendance data is stored in two locations for different access patterns:

1. **Session-level attendance** (sessions/{sessionId}/students subcollection):
   - Stores attendance for each session
   - Enables session-specific queries
   - Contains: studentId, name, isPresent, timestamp

2. **Student-level history** (students/{studentId}.attendanceHistory):
   - Map field with date keys (YYYY-MM-DD format)
   - Values: "Present" or "Absent"
   - Enables individual progress tracking

**Step 2: Coach Attendance Interface**

The attendance marking workflow:

1. AttendanceViewModel loads students assigned to session
2. UI displays student list with toggle switches
3. Toggle action calls updateStudentAttendance() method
4. Method performs batch write to both session and student documents
5. Real-time listeners update UI across all connected clients

**Step 3: Progress Calculation**

Student progress metrics are calculated from attendance data:

- **Attendance Rate:** (Present days / Total days) × 100%
- **Current Streak:** Consecutive present days from most recent
- **Longest Streak:** Maximum consecutive present days historically

**Step 4: Parent Dashboard Integration**

Parents access their child's data through StudentParentViewModel:

1. On login, system identifies linked student via linkedStudentId
2. ViewModel loads student document including attendanceHistory
3. Dashboard displays:
   - Attendance rate as percentage
   - Present/absent day counts
   - Current and longest streaks
   - Upcoming class schedule
   - Earned badges with visuals

**Step 5: Badge Achievement System**

Badges are awarded based on participation and skill development:
- Badge definitions stored in badges collection
- Student's earned badges stored as array of badge IDs
- Parent dashboard displays earned badges with icons and descriptions

**Verification Method:**
- Test attendance marking with multiple concurrent users
- Verify real-time synchronization across devices
- Validate progress calculations with test data
- User acceptance testing with parents viewing dashboard


### 3.5.3 Objective 3: Integrated Notification System

**Objective Statement:** To develop an integrated notification and communication system that automatically alerts relevant stakeholders based on their roles when classes are scheduled, ensuring centralized and timely information delivery through push notifications.

**Methodology:**

**Step 1: FCM Token Management**

Each user's device token is managed for push notification delivery:

1. NotificationService initializes on app startup
2. Requests notification permission from user
3. Retrieves FCM device token
4. Stores token in user's Firestore document (fcmToken field)
5. Listens for token refresh and updates accordingly

**Step 2: Cloud Functions for Automatic Triggers**

Firebase Cloud Functions automate notification delivery when sessions are created. The function:

1. Extracts session data from the created document
2. Queries coaches by leadCoachId and assistantCoachId
3. Queries parents by student age group matching session age group
4. Sends FCM notifications to all relevant users
5. Saves notification records to Firestore for in-app viewing

**Step 3: Notification Types**

The system supports multiple notification types:

**Table 3.5: Notification Types**

| Type | Trigger | Recipients | Content |
|------|---------|------------|---------|
| class_scheduled | New session created | Assigned coaches, parents of age group | Class details, date, time, venue |
| broadcast | Admin sends announcement | Selected role (coaches/parents/all) | Custom message |
| reminder | Scheduled time before class | Enrolled students' parents | Upcoming class reminder |
| attendance | Attendance marked | Individual parent | Child's attendance status |

**Step 4: Notification Storage and Display**

Notifications are persisted for in-app viewing:

1. Cloud Function saves notification to notifications collection
2. Document includes: title, body, type, targetUserId, createdAt, read status
3. NotificationsView queries user's notifications via stream
4. Real-time updates show new notifications immediately
5. User can mark as read, which updates readAt timestamp

**Step 5: Role-Based Targeting**

Notifications are targeted based on user roles and relationships:

- **Coaches:** Receive notifications for sessions where they are lead or assistant
- **Parents:** Receive notifications for classes matching their child's age group
- **All Users:** Receive broadcast announcements from administrators

**Verification Method:**
- Test notification delivery across Android, iOS, and web
- Verify Cloud Function triggers correctly on document creation
- Measure notification delivery latency
- User acceptance testing for notification relevance


## 3.6 Project Constraints and Risk Management

### 3.6.1 Project Constraints

**Table 3.6: Project Constraints**

| Constraint Type | Description | Mitigation |
|-----------------|-------------|------------|
| Time | Project must be completed within two semesters (24 weeks) | Agile sprints with prioritized backlog; MVP approach |
| Resources | Single developer; limited budget for cloud services | Firebase free tier; efficient resource utilization |
| Technical | AI API rate limits and costs | Caching responses; optimizing prompt efficiency |
| Platform | iOS testing requires macOS environment | Focus on Android and web; iOS testing via cloud services |
| Data | No access to real academy data during development | Synthetic test data; demo accounts |

### 3.6.2 Risk Assessment and Mitigation

**Table 3.7: Risk Assessment Matrix**

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| Gemini API changes or deprecation | Low | High | Abstract AI service behind interface; monitor Google announcements |
| Firebase service outage | Low | High | Implement offline persistence; graceful degradation |
| PDF extraction accuracy below target | Medium | Medium | Iterative prompt engineering; fallback to manual entry |
| Animation generation produces unusable results | Medium | Medium | Validation logic; manual override option |
| Scope creep from additional feature requests | High | Medium | Strict scope definition; change control process |
| Performance issues with large data sets | Medium | Medium | Pagination; efficient queries; performance testing |


## 3.7 Summary

This chapter presented the methodology adopted for developing GoalBuddy, a mobile application for youth football academy management. The Agile iterative incremental development model was selected to accommodate evolving requirements and enable continuous feedback integration. The development environment utilizes Flutter framework with Dart language, Firebase backend services, and Google Gemini AI integration.

The system architecture follows the MVVM pattern with Provider state management, ensuring clear separation between UI, business logic, and data access layers. The project structure organizes code by feature with dedicated directories for models, services, view models, views, and widgets.

Detailed methodologies were presented for achieving each project objective:
- **Objective 1** employs Gemini AI for PDF extraction and animation generation through structured prompt engineering and multimodal API calls
- **Objective 2** implements dual-location attendance storage with real-time synchronization and calculated progress metrics
- **Objective 3** utilizes Firebase Cloud Messaging with Cloud Functions for automatic, role-based notification delivery

Project constraints and risks were identified with corresponding mitigation strategies to ensure successful project completion within the defined timeline and resources.

The next chapter presents the detailed system analysis and design, including functional and non-functional requirements, use case specifications, data modeling, and user interface design.
