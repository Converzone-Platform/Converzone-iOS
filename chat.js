
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
var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
console.log("Listening on 5134" + " ( " + date + " )");

io.sockets.on('connection', newConnection);

function newConnection(socket){
    
    console.log(socket.id + " connected.");
    
    socket.on('add-user', function(user){
              
      console.log(connections);
      
      connections[user.id] = {
      "socket": socket.id
      };
      });
    
    socket.on('chat-message', function(message){
              
              console.log(message);
              
              if (connections[message.receiver]){
              console.log("Send to: " + connections[message.receiver].socket);
              io.sockets.connected[connections[message.receiver].socket].emit("chat-message", message);
              }else{
              console.log("Send push notification")
              }
              });
    
    //Removing the socket on disconnect
    socket.on('disconnect', function() {
              for(var id in connections) {
              if(connections[id].socket === socket.id) {
              delete connections[id];
              break;
              }
              }
              })
}
