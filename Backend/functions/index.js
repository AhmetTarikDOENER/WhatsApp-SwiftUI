const functions = require("firebase-functions");
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { onValueCreated } = require("firebase-functions/v2/database");
const admin = require("firebase-admin");

admin.initializeApp();

const channelMessagesReference = "/channel-messages/{channelId}/{messageId}"

exports.sendPushNotificationsForMessages = onValueCreated(
   channelMessagesReference,
   async (event) => {
      const data = event.data.val();
      const textMessage = data.text
      const senderName = data.channelNameAtSend
      const chatPartnerFcmTokens = data.chatPartnerFcmTokens
      const messageType = data.type

      let notificationMessage = textMessage;

      if (messageType === "photo") {
         notificationMessage = "Sent a Photo Message"
      } else if (messageType === "video") {
         notificationMessage = "Sent a Video Message"
      } else if (messageType === "audio") {
         notificationMessage = "Sent an Audio Message"
      }

      for (const fcmToken of chatPartnerFcmTokens) {
            await sendPushNotifications(notificationMessage, senderName, fcmToken)
      }
   }
)

async function sendPushNotifications(message, senderName, fcmToken) {
   const payload = {
      notification: {
         title: senderName,
         body: message
      },

      apns: {
         payload: {
            aps: {
               sound: "default",
               badge: 10,
            }
         }
      },

      token: fcmToken,
   };

   try {
      await admin.messaging().send(payload);
      console.info("Successfully sent message: ", message)
   } catch (err) {
      console.error("Error sending pnm: ", err)
   }
}
