const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");

const { initializeApp } = require("firebase-admin/app");
initializeApp();


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.helloWorld = onRequest((request, response) => {
   response.send("First Deployed Functions from Firebase");
});
