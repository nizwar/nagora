import 'package:agora_rtc_engine/rtc_channel.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:nagora/core/providers/agoraProvider.dart';
import 'package:nagora/core/providers/userProvider.dart';

class AgoraUtils {
  static Future<RtcChannel> createChannel(BuildContext context,
      {String uid}) async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    if (uid == null) uid = "nagora_" + time.substring(time.length - 8);
    RtcChannel rtcChannel = await RtcChannel.create(uid);

    await Future.wait([
      rtcChannel.setClientRole(ClientRole.Broadcaster),
      rtcChannel.joinChannelWithUserAccount(
          null,
          UserProvider.instance(context).userInfo.userAccount,
          ChannelMediaOptions(true, false)),
    ]);

    rtcChannel.publish();

    return rtcChannel;
  }

  static Future<RtcEngine> joinChannel(BuildContext context,
      {@required String uid}) async {
    return AgoraProvider.instance(context).rtcEngine
      ..joinChannelWithUserAccount(
          null, uid, UserProvider.instance(context).userInfo.userAccount);
  }
}
