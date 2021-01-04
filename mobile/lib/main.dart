import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:nagora/core/providers/agoraProvider.dart';
import 'package:nagora/core/providers/userProvider.dart';
import 'package:nagora/core/utils/preferences.dart';
import 'package:nagora/ui/screens/loginChannelScreen.dart';
import 'core/resources/myColors.dart';
import 'ui/screens/mainScreen.dart';
import 'package:provider/provider.dart';

main() {
  return runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AgoraProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryColor,
          accentColor: accentColor,
        ),
        home: Root(),
      ),
    ),
  );
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  bool ready = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      await Future.wait([
        AgoraProvider.initEngine(context),
        Preferences.instance().then((value) {
          if (value.userAccount != null && value.uid != null) {
            UserProvider.instance(context).userInfo = UserInfo.fromJson({
              "uid": value.uid,
              "userAccount": value.userAccount,
            });
          }
        }),
      ]);
      setState(() {
        ready = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ready
        ? Consumer<UserProvider>(
            builder: (context, provider, child) {
              if (provider.userInfo != null)
                return MainScreen();
              else
                return LoginChannelScreen();
            },
          )
        : SplashScreen();
  }
}

///Splash screen to show on root!
///Use this if you got something to do and make some delay or loading when app is open
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Splash"),
      ),
    );
  }
}
