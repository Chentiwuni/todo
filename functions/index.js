const admin = require("firebase-admin");
admin.initializeApp();

const { onSchedule } = require("firebase-functions/v2/scheduler");

exports.notifyDueTasks = onSchedule("every 5 minutes", async () => {
  const now = admin.firestore.Timestamp.now();
  const in15Min = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 15 * 60 * 1000)
  );

  const users = await admin.firestore().collection("users").get();

  for (const userDoc of users.docs) {
    const uid = userDoc.id;
    const fcmToken = userDoc.data().fcmToken;

    if (!fcmToken) continue;

    const tasksSnap = await admin
      .firestore()
      .collection("users")
      .doc(uid)
      .collection("tasks")
      .where("dueDate", ">=", now)
      .where("dueDate", "<=", in15Min)
      .where("isCompleted", "==", false)
      .where("reminderSent", "==", false)
      .get();

    if (!tasksSnap.empty) {
      const titles = tasksSnap.docs.map((doc) => doc.data().title).join(", ");
      const message = {
        token: fcmToken,
        notification: {
          title: "Upcoming Tasks",
          body: `You have: "${titles}" task due soon.`,
        },
      };

      try {
        await admin.messaging().send(message);

        const batch = admin.firestore().batch();
        tasksSnap.docs.forEach((doc) => {
          batch.update(doc.ref, { reminderSent: true });
        });
        await batch.commit();
      } catch (_) {
        // Optionally log errors to monitoring if needed
      }
    }
  }

  return null;
});
