import 'package:nagora/core/models/model.dart';

class Chat extends Model {
  Chat({
    this.sentBy,
    this.message,
    this.sentOn,
  });

  SentBy sentBy;
  String message;
  int sentOn;

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        sentBy:
            json["sent_by"] == null ? null : SentBy.fromJson(json["sent_by"]),
        message: json["message"] == null ? null : json["message"],
        sentOn: json["sent_on"] == null ? null : json["sent_on"],
      );

  Map<String, dynamic> toJson() => {
        "sent_by": sentBy == null ? null : sentBy.toJson(),
        "message": message == null ? null : message,
        "sent_on": sentOn == null ? null : sentOn,
      };
}

class SentBy extends Model {
  SentBy({
    this.id,
    this.username,
    this.room,
  });

  int id;
  String username;
  String room;

  factory SentBy.fromJson(Map<String, dynamic> json) => SentBy(
        id: json["id"] == null ? null : json["id"],
        username: json["username"] == null ? null : json["username"],
        room: json["room"] == null ? null : json["room"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "username": username == null ? null : username,
        "room": room == null ? null : room,
      };
}
