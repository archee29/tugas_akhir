const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendScheduledNotification = functions.pubsub.schedule('every day 07:00').onRun(async (context) => {
  const payload = {
    notification: {
      title: "Reminder",
      body: "It's time for the morning schedule!",
    },
  };

  // Fetch user tokens from Firebase Realtime Database
  const tokensSnapshot = await admin.database().ref('UsersData/{user_id}/tokens').once('value');
  const tokens = tokensSnapshot.val();

  if (tokens) {
    // Send notification to all user tokens
    await admin.messaging().sendToDevice(tokens, payload);
    console.log('Notification sent');
  } else {
    console.log('No tokens found');
  }

  return null;
});
