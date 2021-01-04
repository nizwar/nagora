import 'package:agora_rtc_engine/rtc_channel.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:nagora/core/resources/environment.dart';
import 'package:provider/provider.dart';

class AgoraProvider {
  RtcEngine rtcEngine;
  RtcChannel rtcChannel;

  static Future initEngine(BuildContext context) async {
    var provider = instance(context);
    provider.rtcEngine = await RtcEngine.create(agoraID);
    await provider.rtcEngine.enableAudio();
    await provider.rtcEngine.setClientRole(ClientRole.Broadcaster);
    await provider.rtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
  }

  Future createChannel(String channelName) async {
    if (rtcChannel != null) rtcChannel.destroy();
    rtcChannel.setEventHandler(RtcChannelEventHandler());
  }

  static AgoraProvider instance(BuildContext context) =>
      Provider.of(context, listen: false);
}
