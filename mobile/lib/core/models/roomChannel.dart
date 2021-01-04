import 'package:nagora/core/models/chat.dart';

class RoomChannel {
  RoomChannel({
    this.channel,
    this.masterUid,
    this.chat,
  });

  String channel;
  int masterUid;
  List<Chat> chat;

  factory RoomChannel.fromJson(Map<String, dynamic> json) => RoomChannel(
        channel: json["channel"] == null ? null : json["channel"],
        masterUid: json["master_uid"] == null ? null : json["master_uid"],
        chat: json["chat"] == null
            ? null
            : List<Chat>.from(json["chat"].map((x) => Chat.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "channel": channel == null ? null : channel,
        "master_uid": masterUid == null ? null : masterUid,
        "chat": chat == null ? null : chat.toString(),
      };
}
