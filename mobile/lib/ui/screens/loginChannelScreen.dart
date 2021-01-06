import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:nagora/core/providers/agoraProvider.dart';
import 'package:nagora/core/providers/userProvider.dart';
import 'package:nagora/core/resources/environment.dart';
import 'package:nagora/core/resources/myColors.dart';
import 'package:nagora/ui/components/customDivider.dart';

class LoginChannelScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(20),
            shrinkWrap: true,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: "username"),
              ),
              ColumnDivider(),
              FlatButton(
                child: Text(
                  "Continue",
                  style: TextStyle(color: Colors.white),
                ),
                color: primaryColor,
                shape: StadiumBorder(),
                onPressed: () async {
                  UserProvider.instance(context).userInfo = UserInfo.fromJson({
                    "uid": int.parse(DateTime.now()
                        .millisecondsSinceEpoch
                        .floor()
                        .toString()
                        .substring(0, 8)),
                    "userAccount": _nameController.text,
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
