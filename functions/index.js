const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Triggered when a new session is created in Firestore.
 * Sends notifications to the assigned coaches and parents of students in that age group.
 */
exports.onSessionCreated = functions
  .region("asia-southeast1")
  .firestore.document("sessions/{sessionId}")
  .onCreate(async (snap, context) => {
    const sessionData = snap.data();
    const sessionId = context.params.sessionId;

    console.log(`New session created: ${sessionId}`);
    console.log("Session data:", JSON.stringify(sessionData));

    const { className, ageGroup, venue, startTime, leadCoachId, assistantCoachId } = sessionData;

    // Format the date for the notification
    let dateString = "TBD";
    if (startTime) {
      const date = startTime.toDate();
      dateString = date.toLocaleDateString("en-US", {
        weekday: "short",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      });
    }

    const notificationTitle = "New Class Scheduled!";
    const notificationBody = `${className || "A new class"} on ${dateString} at ${venue || "TBD"}`;

    // Collect all user IDs to notify
    const usersToNotify = [];

    // 1. Notify Lead Coach
    if (leadCoachId) {
      usersToNotify.push({ userId: leadCoachId, role: "coach" });
      console.log(`Will notify lead coach: ${leadCoachId}`);
    }

    // 2. Notify Assistant Coach (if assigned)
    if (assistantCoachId) {
      usersToNotify.push({ userId: assistantCoachId, role: "coach" });
      console.log(`Will notify assistant coach: ${assistantCoachId}`);
    }

    // 3. Notify Parents of students in this age group
    if (ageGroup) {
      try {
        // Get all students with this age group
        const studentsSnapshot = await db
          .collection("students")
          .where("ageGroup", "==", ageGroup)
          .get();

        const parentEmails = new Set();
        studentsSnapshot.forEach((doc) => {
          const studentData = doc.data();
          if (studentData.parentEmail) {
            parentEmails.add(studentData.parentEmail);
          }
        });

        console.log(`Found ${parentEmails.size} parent emails for age group ${ageGroup}`);

        // Find user IDs for these parent emails
        for (const email of parentEmails) {
          const userSnapshot = await db
            .collection("users")
            .where("email", "==", email)
            .where("role", "==", "student_parent")
            .limit(1)
            .get();

          if (!userSnapshot.empty) {
            usersToNotify.push({
              userId: userSnapshot.docs[0].id,
              role: "parent",
            });
          }
        }
      } catch (error) {
        console.error("Error fetching parents:", error);
      }
    }

    // Send notifications and save to Firestore
    const notifications = [];
    const fcmMessages = [];

    for (const user of usersToNotify) {
      try {
        // Get user's FCM token
        const userDoc = await db.collection("users").doc(user.userId).get();
        const userData = userDoc.data();

        if (userData && userData.fcmToken) {
          // Prepare FCM message
          fcmMessages.push({
            token: userData.fcmToken,
            notification: {
              title: notificationTitle,
              body: notificationBody,
            },
            data: {
              type: "class_scheduled",
              sessionId: sessionId,
              click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
            android: {
              priority: "high",
              notification: {
                channelId: "high_importance_channel",
                sound: "default",
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: "default",
                  badge: 1,
                },
              },
            },
          });
        }

        // Save notification to Firestore for history
        notifications.push({
          title: notificationTitle,
          body: notificationBody,
          type: "class_scheduled",
          targetUserId: user.userId,
          targetRole: user.role,
          relatedSessionId: sessionId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });
      } catch (error) {
        console.error(`Error processing user ${user.userId}:`, error);
      }
    }

    // Batch save notifications to Firestore
    if (notifications.length > 0) {
      const batch = db.batch();
      notifications.forEach((notification) => {
        const docRef = db.collection("notifications").doc();
        batch.set(docRef, notification);
      });
      await batch.commit();
      console.log(`Saved ${notifications.length} notifications to Firestore`);
    }

    // Send FCM messages
    if (fcmMessages.length > 0) {
      try {
        const response = await messaging.sendEach(fcmMessages);
        console.log(`Sent ${response.successCount} FCM messages, ${response.failureCount} failed`);
      } catch (error) {
        console.error("Error sending FCM messages:", error);
      }
    }

    return null;
  });

/**
 * Callable function for admin to send broadcast notifications.
 * Can target all coaches, all parents, or everyone.
 */
exports.sendBroadcastNotification = functions
  .region("asia-southeast1")
  .https.onCall(async (data, context) => {
    // Verify the caller is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated to send notifications"
      );
    }

    // Verify the caller is an admin
    const callerDoc = await db.collection("users").doc(context.auth.uid).get();
    const callerData = callerDoc.data();

    if (!callerData || callerData.role !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can send broadcast notifications"
      );
    }

    const { title, body, targetAudience } = data;

    if (!title || !body || !targetAudience) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields: title, body, targetAudience"
      );
    }

    console.log(`Admin ${context.auth.uid} sending broadcast to ${targetAudience}`);

    // Build query based on target audience
    let usersQuery;
    if (targetAudience === "all_coaches") {
      usersQuery = db.collection("users").where("role", "==", "coach");
    } else if (targetAudience === "all_parents") {
      usersQuery = db.collection("users").where("role", "==", "student_parent");
    } else if (targetAudience === "everyone") {
      usersQuery = db.collection("users").where("role", "in", ["coach", "student_parent"]);
    } else {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid targetAudience. Must be: all_coaches, all_parents, or everyone"
      );
    }

    const usersSnapshot = await usersQuery.get();
    console.log(`Found ${usersSnapshot.size} users to notify`);

    const fcmMessages = [];
    const notifications = [];

    usersSnapshot.forEach((doc) => {
      const userData = doc.data();

      // Prepare FCM message if user has token
      if (userData.fcmToken) {
        fcmMessages.push({
          token: userData.fcmToken,
          notification: {
            title: title,
            body: body,
          },
          data: {
            type: "broadcast",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: "high",
            notification: {
              channelId: "high_importance_channel",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        });
      }

      // Save notification to Firestore
      notifications.push({
        title: title,
        body: body,
        type: "broadcast",
        targetUserId: doc.id,
        targetRole: userData.role,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
    });

    // Batch save notifications
    if (notifications.length > 0) {
      const batch = db.batch();
      notifications.forEach((notification) => {
        const docRef = db.collection("notifications").doc();
        batch.set(docRef, notification);
      });
      await batch.commit();
      console.log(`Saved ${notifications.length} notifications to Firestore`);
    }

    // Send FCM messages
    let successCount = 0;
    let failureCount = 0;

    if (fcmMessages.length > 0) {
      try {
        const response = await messaging.sendEach(fcmMessages);
        successCount = response.successCount;
        failureCount = response.failureCount;
        console.log(`Sent ${successCount} FCM messages, ${failureCount} failed`);
      } catch (error) {
        console.error("Error sending FCM messages:", error);
        throw new functions.https.HttpsError("internal", "Error sending notifications");
      }
    }

    return {
      success: true,
      totalUsers: usersSnapshot.size,
      notificationsSaved: notifications.length,
      fcmSent: successCount,
      fcmFailed: failureCount,
    };
  });
