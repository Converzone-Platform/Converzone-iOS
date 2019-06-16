"use strict";

const apn = require('apn');

var express = require('express');

var app = express();
var server = app.listen(5134);

app.use(express.static('public'));
var socket = require('socket.io');
var io = socket(server);

// Here is an array of all connections to the server
var connections = {};

// Show that the websocket is running
var today = new Date();
var date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();

console.log("Listening on 5134" + " ( " + date + " )");

io.sockets.on('connection', newConnection);

function newConnection(socket) {
    
    console.log(socket.id + " connected.");
    
    socket.on('add-user', function(user) {
              
              connections[user.id] = {
              "socket": socket.id
              };
              
              });
    
    socket.on('chat-message', function(message) {
              
              console.log(message);
              
              if (connections[message.receiver]) {
              
              console.log("Send to: " + connections[message.receiver].socket);
              //io.sockets.connected[connections[message.receiver].socket].emit("chat-message", message);
              
              io.to(connections[message.receiver].socket).emit('chat-message', message);
              
              } else {
              console.log("Send push notification")
              sendPushNotificationToIOS(message.senderName, message, message.deviceToken, message.sound)
              }
              });
    
    //Removing the socket on disconnect
    socket.on('disconnect', function() {
              console.log("The client disconnected");
              console.log("The new list of clients is: " + connections)
              for (var id in connections) {
              if (connections[id].socket === socket.id) {
              delete connections[id];
              break;
              }
              }
              })
}
function sendPushNotificationToIOS(alert, data, token, sound) {
    let options = {
    token: {
    key: "key.p8",
    keyId: "F659H42J2K",
    teamId: "M3493F96B3"
    },
    sandbox: true
    };
    
    let apnProvider = new apn.Provider(options);
    //E3B7DC9D945E34353E2F385FCDC3767337B57F1D2F20EBAFAE333531E8DA7477
    
    // Replace deviceToken with your particular token:
    let deviceToken = token;
    
    // Prepare the notifications
    let notification = new apn.Notification();
    notification.expiry = Math.floor(Date.now() / 1000) + 24 * 3600 * 30; // will expire in 24 * 30 hours from now
    notification.badge = 1;
    notification.sound = sound;
    notification.alert = alert;
    notification.payload = data;
    
    notification.topic = "com.hashtag.oct.converzone";
    
    apnProvider.send(notification, deviceToken).then(result => {
                                                     // Show the result of the send operation:
                                                     console.log(result);
                                                     });
    
    // Close the server
    apnProvider.shutdown();
}
