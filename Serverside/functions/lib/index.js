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
// export const userCountAlltimeUp = functions.database
//     .ref("/users/{userid}")
//     .onCreate(async (snapshot, context) => {
//     const countRef = snapshot.ref.parent!.child("user_count_alltime")
//     countRef.transaction(count => {
//         snapshot.ref.parent!.child("user_count_alltime").on('value', function (snapshot2){
//             const count = snapshot2!.val().user_count_alltime
//             snapshot.ref.child("user_count").set(count);
//         })
//         return count + 1
//     })
// })
exports.newMessage = functions.database
    .ref("conversations/{conversationid}/messages/{messageid}")
    .onCreate((snapshot, context) => {
    //let sender_id = snapshot.val().sender
    const receiver_id = snapshot.val().receiver;
    const receiver_token = null;
    //let sender_firstname = admin.database().ref(`/users/${sender_id}`).snapshot.val().firstname
    //let sender_lastname = admin.database().ref(`/users/${sender_id}`).snapshot.val().lastname
    // admin.database().ref(`/users/${receiver_id}/token`).once('value').then((snap) => {
    //     receiver_token = snap.val()
    //     console.log('snapshot: ' + snap.val())
    // }); 
    snapshot.ref.parent.parent.parent.child(`/users/${receiver_id}`).on('value', function (snapshot2) {
        console.log(snapshot2.val().device_token);
    });
    //const payload = {
    //      notification: {
    //          title: sender_firstname + ' ' + sender_lastname
    //      }
    //};
    const payload = {
        notification: {
            title: "Name"
        }
    };
    return admin.messaging().sendToDevice(receiver_token, payload);
});
//# sourceMappingURL=index.js.map