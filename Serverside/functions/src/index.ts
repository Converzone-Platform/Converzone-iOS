import * as functions from 'firebase-functions';

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

export const startedNewConversation = functions.database
    .ref('/conversations/{conversationid}/')
    .onCreate((snapshot, context) => {

        let senderid = null
        let receiverid = null

        const conversationsid = snapshot.key

        const messages = snapshot.child("/messages")

        messages.forEach((value) => {

            senderid = value.val().sender
            receiverid = value.val().receiver

            return true

        });

        // Add conversationid to the receiver's conversations and vice versa
               admin.database().ref(`/users/${senderid}/conversations/${receiverid}`).set(conversationsid)
        return admin.database().ref(`/users/${receiverid}/conversations/${senderid}`).set(conversationsid)
        
    })

export const newMessage = functions.database
    .ref("conversations/{conversationid}/messages/{messageid}")
    .onCreate((snapshot, context) => {

        //let sender_id = snapshot.val().sender
        const receiver_id = snapshot.val().receiver

        let receiver_token = null

        //let sender_firstname = admin.database().ref(`/users/${sender_id}`).snapshot.val().firstname
        //let sender_lastname = admin.database().ref(`/users/${sender_id}`).snapshot.val().lastname

        admin.database().ref(`/users/${receiver_id}/token`).once('value').then((snap) => {
            receiver_token = snap.val()
            console.log('snapshot: ' + snap.val())

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

        //console.log('sender_id: ' + sender_id)
        //console.log('receiver_id: ' + receiver_id)
        //console.log('receiver_token: ' + receiver_token)
        //console.log('sender_firstname: ' + sender_firstname)
        //console.log('sender_lastname: ' + sender_lastname)
        //console.log(sender_firstname + ' ' + sender_lastname)

       return admin.messaging().sendToDevice(receiver_token, payload);
})