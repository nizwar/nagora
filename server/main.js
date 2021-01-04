const express = require('express');
const WebSocket = require('ws'); 

const app = express();
const server = require('http').createServer(app);
const wss = new WebSocket.Server({ server });

const rooms = [];


wss.on('connection', ws => {
    ws.on('message', (data) => {
        console.log(data);
        msg = JSON.parse(data);
        const room = rooms.find(item => item.name == msg.data.room);
        switch (msg.action) {
            case "create_room":
                const roomItem = {
                    "name": msg.data.room,
                    "id_master": msg.data.id_master,
                    "users": [
                        {
                            "id": msg.data.id_master,
                            "muted": false,
                        }
                    ],
                };
                rooms.push(roomItem);
                wss.clients.forEach(client => {
                    client.send(JSON.stringify(roomItem)); 
                })
                break;

            case "join_room": 
                if (checkUserExists(room.users, msg.data.id_user))
                    console.log("User already exists")
                else
                    room.users.push({
                        "id": msg.data.id_user,
                        "muted": false,
                    })

                wss.clients.forEach(client => {
                    client.send(JSON.stringify(room));
                    console.log(room);
                })
                break;

            case "mute_id":
                room.users.find(item => item.id == msg.data.id_user).muted = msg.data.mute;
                wss.clients.forEach(client => {
                    client.send(JSON.stringify(room));
                    console.log(room);
                })
                break;

            case "mute_all":
                if(msg.data.id_user != room.id_master) return;
                room.users.forEach(user=>{
                    if(user.id != msg.data.id_user)
                    user.muted = msg.data.mute;
                })

                wss.clients.forEach(client => {
                    client.send(JSON.stringify(room));
                    console.log(room);
                })
                break;

        }
    });
});

app.get("/rooms", (req, res) => {
    res.send(rooms);
});

server.listen(6969, function () {
    console.log('server listening');
});


function checkUserExists(users, id) {
    for (var i = 0; i < users.length; i++) {
        console.log(users[i]);
        if (users[i].id == id) return true;
    }

    return false;
}