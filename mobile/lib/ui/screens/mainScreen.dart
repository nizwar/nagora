import 'package:flutter/material.dart';
import 'package:nagora/core/https/roomsHttp.dart';
import 'package:nagora/core/providers/userProvider.dart';
import 'package:nagora/core/utils/socketUtils.dart';
import 'package:nagora/core/utils/utils.dart';
import 'package:nagora/ui/screens/roomScreen.dart';
import 'package:ndialog/ndialog.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to NAGORA"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: createRoom,
          )
        ],
      ),
      body: FutureBuilder<List<RoomChannel>>(
        future: RoomsHttp(context).getRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          if (!snapshot.hasData)
            return Center(
              child: Text("There is no room"),
            );
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              children: snapshot.data
                  .map((e) => ListTile(
                        title: Text((e?.name ?? "Not available").toUpperCase()),
                        subtitle: Text("Master : #${e?.idMaster}"),
                        onTap: () async {
                          await startScreen(
                              context,
                              RoomScreen(
                                channelName: e?.name,
                                title: "Room #${e?.name}",
                                creator: e?.idMaster ==
                                        UserProvider.instance(context)
                                            .userInfo
                                            .userAccount
                                    ? true
                                    : false,
                              ));
                          if (mounted) setState(() {});
                        },
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  void createRoom() async {
    TextEditingController name = TextEditingController();
    var resp = await NAlertDialog(
      title: Text("New Room"),
      content: TextField(
        controller: name,
        decoration: InputDecoration(hintText: "Type your channel name"),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            closeScreen(context, name.text);
          },
          child: Text("Apply"),
        ),
        FlatButton(
          onPressed: () {
            closeScreen(context);
          },
          child: Text("Cancel"),
        ),
      ],
    ).show(context);
    if (resp == null) return;
    SocketUtils.createRoom(context, name: resp);
    await startScreen(
        context,
        RoomScreen(
          channelName: resp,
          creator: true,
          title: "Room #$resp",
        ));
    if (mounted) setState(() {});
  }
}
