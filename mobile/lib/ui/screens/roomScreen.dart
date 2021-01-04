import 'dart:convert';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_channel.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nagora/core/https/roomsHttp.dart';
import 'package:nagora/core/providers/userProvider.dart';
import 'package:nagora/core/resources/environment.dart';
import 'package:nagora/core/utils/socketUtils.dart';
import 'package:nagora/core/utils/utils.dart';
import 'package:nagora/ui/components/customDivider.dart';
import 'package:ndialog/ndialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoomScreen extends StatefulWidget {
  final String title;
  final String channelName;
  final bool creator;
  final bool published;

  const RoomScreen(
      {Key key, this.title, this.channelName, this.creator, this.published})
      : super(key: key);
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  RoomChannel _roomChannel;

  RtcEngine _rtc;
  RtcChannel _rtcChannel;
  WebSocketChannel _socketChannel =
      IOWebSocketChannel.connect("ws://$websocket:$websocketPort");
  bool ready = false;

  @override
  void initState() {
    initRTC();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(Icons.mic_off),
              onPressed: () {
                if (!(widget.creator ?? false)) {
                  NAlertDialog(
                    title: Text("Attention"),
                    content: Text("Only admin can mute all users"),
                    actions: [
                      FlatButton(
                        child: Text("Understand"),
                        onPressed: () {
                          closeScreen(context);
                        },
                      )
                    ],
                  ).show(context);
                }
                SocketUtils.muteAll(context,
                    room: widget.channelName, mute: false);
              })
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _socketChannel.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(
                      child: FlatButton(
                    child: Text("Refresh"),
                    onPressed: () {
                      SocketUtils.joinRoom(context, name: widget.channelName);
                    },
                  ));
                RoomChannel resp =
                    RoomChannel.fromJson(jsonDecode(snapshot.data));
                if (resp.name == widget.channelName) _roomChannel = resp;

                print(resp);

                return ListView(
                  children: _roomChannel.users
                      .map((e) => ListTile(
                            title: Text("#${e.id}"),
                            leading: Icon((e?.muted ?? false)
                                ? Icons.mic
                                : Icons.mic_off),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<UserProvider>(
        builder: (context, provider, child) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => _enableSpeaker(provider),
              child:
                  Icon(provider.speaker ? Icons.speaker_group : Icons.speaker),
              heroTag: "speaker",
            ),
            RowDivider(),
            FloatingActionButton(
              onPressed: () => _enableMicrophone(provider),
              child: Icon(provider.microphone ? Icons.mic : Icons.mic_off),
              heroTag: "microphone",
            ),
          ],
        ),
      ),
    );
  }

  void _enableMicrophone(UserProvider provider) {
    _rtc.enableLocalAudio(!provider.speaker).then((value) {
      provider.microphone = !provider.microphone;
      print(provider.microphone);
      SocketUtils.muteMe(context,
          room: widget.channelName, mute: provider.microphone);
    });
  }

  void _enableSpeaker(UserProvider provider) {
    _rtc
        .setEnableSpeakerphone(!provider.speaker)
        .then((value) => provider.speaker = !provider.speaker);
  }

  void initRTC() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone].request();
    }
    _rtc = await RtcEngine.create(agoraID);
    await _rtc.enableAudio();
    await _rtc.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _rtc.setClientRole(
        widget.creator ? ClientRole.Broadcaster : ClientRole.Audience);
    _rtc
      ..setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          log('joinChannelSuccess $channel $uid $elapsed');
        },
        leaveChannel: (stats) {
          log('leaveChannel ${stats.toJson()}');
        },
      ));

    if ((widget.creator ?? false) && !(widget.published ?? false)) {
      _rtcChannel = await RtcChannel.create(widget.channelName);
      _rtcChannel.setEventHandler(RtcChannelEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          log("Berhasil gabung channel");
        },
        userJoined: (uid, elapsed) {
          log("$uid bergabung di channel");
        },
      ));

      await _rtcChannel.setClientRole(ClientRole.Broadcaster);
      await _rtcChannel.joinChannel(
          null,
          null,
          UserProvider.instance(context).userInfo.uid,
          ChannelMediaOptions(true, false));
    } else {
      await _rtc.joinChannel(null, widget.channelName, null,
          UserProvider.instance(context).userInfo.uid);
      await _rtc
          .enableLocalAudio(true)
          .then((value) => UserProvider.instance(context).speaker = true);
    }

    Future.delayed(Duration.zero).then((value) {
      SocketUtils.joinRoom(context, name: widget.channelName);
    });
  }

  @override
  void dispose() {
    _rtcChannel?.leaveChannel();
    _rtc?.leaveChannel();
    _socketChannel.sink.close();
    super.dispose();
  }
}

class UserJoined {
  bool isMuted;
  int uid;

  UserJoined({this.isMuted, this.uid});
}
