"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
exports.startedNewConversation = functions.database
    .ref('/conversations/{conversationid}/')
    .onCreate((snapshot, context) => {
    let senderid = null;
    let receiverid = null;
    const conversationsid = snapshot.key;
    const messages = snapshot.child("/messages");
    messages.forEach((value) => {
        senderid = value.val().sender;
        receiverid = value.val().receiver;
        return true;
    });
    // Add conversationid to the receiver's conversations and vice versa
    admin.database().ref(`/users/${senderid}/conversations/${receiverid}`).set(conversationsid);
    return admin.database().ref(`/users/${receiverid}/conversations/${senderid}`).set(conversationsid);
});
// MARK: Have a counter for every user on the platform
// Increase when user is added
// Decrease when user is deleted
exports.userCountUp = functions.database
    .ref("/users/{userid}")
    .onCreate(async (snapshot, context) => {
    const countRef = snapshot.ref.parent.child("user_count");
    return countRef.transaction(count => {
        return count + 1;
    });
});
exports.userCountDown = functions.database
    .ref("/users/{userid}")
    .onDelete(async (snapshot, context) => {
    const countRef = snapshot.ref.parent.child("user_count");
    return countRef.transaction(count => {
        return count - 1;
    });
});
// Have a function which only increases the counter of the users
// Add what number the user is
exports.userCountAlltimeUp = functions.database
    .ref("/users/{userid}")
    .onCreate((snapshot, context) => {
    // Increase counter
    const all_time_count_ref = admin.database().ref("users").child("all_time_user_count");
    all_time_count_ref.once("value").then((snapshot_count) => {
        let counter = snapshot_count.val();
        counter++;
        all_time_count_ref.set(counter);
        // Set the counter to the user
        return snapshot.ref.child("all_time_user_count").set("" + counter);
    });
});
exports.newMessage = functions.database
    .ref("conversations/{conversationid}/messages/{messageid}")
    .onCreate((snapshot, context) => {
    const sender_id = snapshot.val().sender;
    const receiver_id = snapshot.val().receiver;
    let sender_firstname = null;
    let sender_lastname = null;
    let receiver_token = null;
    // Get token of receiver
    const ref_receiver_id = admin.database().ref("users").child(receiver_id);
    ref_receiver_id.once("value").then((snapshot_token) => {
        receiver_token = snapshot_token.val().device_token;
        // Get first and lastname
        const ref_sender_id = admin.database().ref("users").child(sender_id);
        ref_sender_id.once("value").then((snapshot_name) => {
            sender_firstname = snapshot_name.val().firstname;
            sender_lastname = snapshot_name.val().lastname;
            const payload = {
                notification: {
                    title: sender_firstname + " " + sender_lastname
                }
            };
            return admin.messaging().sendToDevice(receiver_token, payload);
        });
    });
});
//# sourceMappingURL=index.js.map