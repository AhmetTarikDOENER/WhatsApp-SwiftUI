const functions = require("firebase-functions");
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { onValueCreated } = require("firebase-functions/v2/database");
const { event } = require("firebase-functions/v1/analytics");
const admin = require("firebase-admin");
admin.initializeApp();

const channelMessagesReference = "/channel-messages/{channelId}/{messageId}"

exports.listenForNewMessages = onValueCreated(
   channelMessagesReference,
   async (event) => {
      const data = event.data.val();
      const channelId = event.params.channelId
      const message = data["text"]
      const senderUid = data["ownerUid"]
      const messageSender = await initializeApp.
   }
)