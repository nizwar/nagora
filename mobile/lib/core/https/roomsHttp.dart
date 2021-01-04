import 'package:flutter/material.dart';
import 'package:nagora/core/https/httpConnection.dart';
import 'package:nagora/core/models/model.dart';
import 'package:nagora/core/resources/environment.dart';

class RoomsHttp extends HttpConnection {
  RoomsHttp(BuildContext context) : super(context);

  Future<List<RoomChannel>> getRooms() async {
    var resp = await get("http://$websocket:$websocketPort/rooms", pure: true);
    return resp.map<RoomChannel>((item) => RoomChannel.fromJson(item)).toList();
  }
}

class RoomChannel extends Model {
  RoomChannel({
    this.name,
    this.idMaster,
    this.users,
  });

  String name;
  String idMaster;
  List<User> users;

  factory RoomChannel.fromJson(Map<String, dynamic> json) => RoomChannel(
        name: json["name"] == null ? null : json["name"],
        idMaster: json["id_master"] == null ? null : json["id_master"],
        users: json["users"] == null
            ? null
            : List<User>.from(json["users"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "id_master": idMaster == null ? null : idMaster,
        "users": users == null
            ? null
            : List<dynamic>.from(users.map((x) => x.toJson())),
      };
}

class User extends Model {
  User({
    this.id,
    this.muted,
  });

  String id;
  bool muted;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] == null ? null : json["id"],
        muted: json["muted"] == null ? null : json["muted"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "muted": muted == null ? null : muted,
      };
}
