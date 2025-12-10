require('dotenv').config();

// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onValueCreated} = require("firebase-functions/v2/database");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();

const { StreamChat } = require('stream-chat');

const functions = require('firebase-functions/v1')
const logger = require("firebase-functions/logger");
const { event } = require("firebase-functions/v1/analytics");
const { https } = require("firebase-functions");

const channelMessageReference = "channel-messages/{channelId}/{messageId}";

exports.listenSendNotificationsForMessages = onValueCreated(
    channelMessageReference,
    async (event) => {
        const data = event.data.val();
        const textMessage = data["text"];
        const senderName = data.channelNameAtSend
        const chatPartnerFCMTokens = data.chatPartnerFCMTokens
        const messageType = data.type
        
        let notificationMessage = textMessage;

        if (messageType === "photo") {
            notificationMessage = "Sent a photo message"
        } else if (messageType === "video") {
            notificationMessage = "Sent a video message"
        } else if (messageType === "audio") {
            notificationMessage = "Sent a audio message"
        }

        for (const fcmToken of chatPartnerFCMTokens) {
            await sendPushNotifications(notificationMessage, senderName, fcmToken)
        }
    }
)

exports.sendMessageReactionNotification = https.onCall (
    async(request, response) => {
        const data = request.data
        const fcmToken = data.fcmToken
        const channelNameAtSend = data.channelNameAtSend
        const notificationMessage = data.notificationMessage

        await sendPushNotifications(notificationMessage, channelNameAtSend, fcmToken);
    }
)

async function sendPushNotifications(message, senderName, fcmToken) {
    const payload = {
        notification: {
            title: senderName,
            body: message,
        },

        apns: {
            payload: {
                aps: {
                    sound: "default",
                    badge: 5,
                }
            }
        },

        token: fcmToken,
    };

    try {
        await admin.messaging().send(payload);
        console.info("Successfully sent message: ", message);
    } catch (error) {
        console.error("Error sending message: ", error);
    }
}


// MARK: - Stream Client
const apiKey = process.env.API_KEY
const apiSecret = process.env.API_SECRETS

const streamClient = StreamChat.getInstance(apiKey, apiSecret)

// Create a stream user when creating a firebase user.
exports.createStreamUser = functions.auth.user()
.onCreate(async (user) => {
    logger.log("Firebase user was created", user)

    const response = await streamClient.upsertUser({
        id: user.uid,
        name: user.displayName,
        email: user.email,
        image: user.photoURL
    })

    logger.log("Stream user was created", response)

    return response
})

exports.deleteStreamUser = functions.auth.user()
.onDelete(async (user) => {
    logger.log("Firebase user was deleted", user)
    
    const response = await streamClient.deleteUser(user.uid)

    logger.log("Stream user was deleted", response)

    return response
})

// Get stream user token logged in with email and password
exports.getStreamUserToken = functions.https.onCall((data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "failed-precondition",
            "The function must be called while authenticated"
        )
    } else {
        try {
            return streamClient.createToken(context.auth.uid, undefined, Math.floor(new Date().getTime() / 1000))
        } catch (error) {
            console.error(`Unable to get user token with ID ${context.auth.uid} on Stream. Error ${error}`)
            throw new functions.https.HttpsError(
                "failed-precondition",
                "Could not get stream user"
            )   
        }
    }
})

exports.revokeStreamUserToken = functions.https.onCall((data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "failed-precondition",
            "The function must be called while authenticated"
        )
    } else {
        try {
            return streamClient.revokeUserToken(context.auth.uid)
        } catch (error) {
            console.error(`Unable to get revoke user token with ID ${context.auth.uid} on Stream. Error ${error}`)
            throw new functions.https.HttpsError(
                "failed-precondition",
                "Could not get stream user"
            )   
        }
    }
})