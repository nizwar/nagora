import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nagora/core/providers/userProvider.dart';
import 'package:nagora/core/resources/environment.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketUtils {
  static WebSocketChannel channel =
      IOWebSocketChannel.connect("ws://$websocket:$websocketPort");

  static void createRoom(BuildContext context, {String name}) {
    var provider = UserProvider.instance(context);
    channel.sink.add(jsonEncode({
      "action": "create_room",
      "data": {
        "room": name,
        "id_master": provider.userInfo.userAccount,
      },
    }));
  }

  static void joinRoom(BuildContext context, {String name}) {
    var provider = UserProvider.instance(context);
    channel.sink.add(jsonEncode({
      "action": "join_room",
      "data": {
        "room": name,
        "id_user": provider.userInfo.userAccount,
      },
    }));
  }

  static void muteMe(BuildContext context, {String room, bool mute}) {
    var provider = UserProvider.instance(context);
    channel.sink.add(jsonEncode({
      "action": "mute_id",
      "data": {
        "room": room,
        "id_user": provider.userInfo.userAccount,
        "mute": mute,
      },
    }));
  }

  static void muteAll(BuildContext context, {String room, bool mute}) {
    //Only admin

    var provider = UserProvider.instance(context);
    channel.sink.add(jsonEncode({
      "action": "mute_all",
      "data": {
        "room": room,
        "id_user": provider.userInfo.userAccount,
        "mute": mute,
      },
    }));
  }
}
