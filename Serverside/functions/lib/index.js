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
exports.newMessage = functions.database
    .ref("conversations/{conversationid}/messages/{messageid}")
    .onCreate((snapshot, context) => {
    //let sender_id = snapshot.val().sender
    //let receiver_id = snapshot.val().receiver
    //let receiver_token = admin.database().ref(`/users/${receiver_id}`).snapshot.val().token
    //let sender_firstname = admin.database().ref(`/users/${sender_id}`).snapshot.val().firstname
    //let sender_lastname = admin.database().ref(`/users/${sender_id}`).snapshot.val().lastname
    const payload = {
        notification: {
            title: 'Text'
        }
    };
    return admin.messaging().sendToDevice("ewcV4pGfHLE:APA91bEttGMZu-iCqiB8PPFsOzLbK5oUl9YRLrWititRiwRNpgL7gOxeOdtJ4WXcyrtLElWN4aYzFVeb2CS5iYcULtQRkzE_GMQ5RE38NZ_KW1ZXCTo6gEMATX2ABg3QXketPEdQMQRz", payload);
});
//# sourceMappingURL=index.js.map