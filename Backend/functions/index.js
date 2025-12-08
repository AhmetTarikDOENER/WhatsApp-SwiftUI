const functions = require("firebase-functions");
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { onValueCreated } = require("firebase-functions/v2/database");
const { event } = require("firebase-functions/v1/analytics");
const admin = require("firebase-admin");
const { user } = require("firebase-functions/v1/auth");
admin.initializeApp();

const channelMessagesReference = "/channel-messages/{channelId}/{messageId}"

exports.listenForNewMessages = onValueCreated(
   channelMessagesReference,
   async (event) => {
      const data = event.data.val();
      const channelId = event.params.channelId
      const message = data["text"]
      const ownerUid = data["ownerUid"]
      
      /// Get message sender name -> Read op
      const messageSenderSnapshot = await admin
         .database()
         .ref("/users/" + ownerUid)
         .once("value")

      const messageSenderDictionary = messageSenderSnapshot.val()
      const messageSenderName = messageSenderDictionary["username"]

      await getChannelMembers(channelId, message, messageSenderName)
   }
)

async function getChannelMembers(channelId, message, senderName) {
   const channelSnapshot = await admin
      .database().ref("/channels/" + channelId)
      .once("value")

   const channelDictionary = channelSnapshot.val()
   const membersUids = channelDictionary["membersUids"]

   for (const memberUid of membersUids) {
      await getUserFcmToken(message, memberUid, senderName)
   }
}

async function getUserFcmToken(message, memberUid, senderName) {
   const userSnapshot = await admin
      .database().ref("/users/" + memberUid)
      .once("value")

   const userDictionary = userSnapshot.val()
   const fcmToken = userDictionary["fcmToken"]

   await sendPushNotifications(message, senderName, fcmToken)
}

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
