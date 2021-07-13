import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Meeting());
  }
}

class Meeting extends StatefulWidget {
  @override
  _MeetingState createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "testroom");
  final subjectText = TextEditingController(text: "Test Meeting");
  final nameText = TextEditingController(text: "Username");
  final emailText = TextEditingController(text: "123@email.com");
  
  final iosAppBarRGBAColor =
      TextEditingController(text: "#0080FF80"); //transparent blue
  bool? isAudioOnly = false;
  bool? isAudioMuted = false;
  bool? isVideoMuted = false;

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: const Text('SocialHub'),
          backgroundColor: Colors.brown[900],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: kIsWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.30,
                      child: meetConfig(),
                    ),
                    Container(
                        width: width * 0.60,
                        color: Colors.brown[800],

                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                              color: Colors.white54,
                              child: SizedBox(
                                width: width * 0.60 * 0.70,
                                height: width * 0.60 * 0.70,
                                child: JitsiMeetConferencing(
                                  extraJS: [
                                    // extraJs setup example
                                    '<script>function echo(){console.log("echo!!!")};</script>',
                                    '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                  ],
                                ),
                              )),
                        ))
                  ],
                )
              : meetConfig(),
        ),
      ),
    );
  }

  Widget meetConfig() {
    return SingleChildScrollView(
      
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          SizedBox(
            height: 64.0,
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () {
                _joinFromUrl();
              },
              child: Text(
                "Join From Link",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateColor.resolveWith((states) => Colors.brown)),
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: roomText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Room",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: subjectText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Subject",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: nameText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Display Name",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: emailText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Email",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          
          SizedBox(
            height: 14.0,
          ),
         
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Audio Muted"),
            value: isAudioMuted,
            onChanged: _onAudioMutedChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Video Muted"),
            value: isVideoMuted,
            onChanged: _onVideoMutedChanged,
          ),
          Divider(
            height: 48.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 64.0,
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () {
                _joinMeeting();
              },
              child: Text(
                "Create Meeting",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateColor.resolveWith((states) => Colors.brown)),
            ),
          ),
          SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool? value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool? value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool? value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinFromUrl() async {
    String? serverid = await showDialog(
      context: context,
      builder: (context) => URLdialog(),
    );
    if (serverid == null) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: Text("Enter Valid URL"),
              ));
    } else {
      if (serverid.startsWith("https://meet.jit.si/")) {
        serverid = serverid.replaceAll("https://meet.jit.si/", "");
        roomText.text = serverid;
        _joinMeeting();
      } else {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  content: Text("Enter Valid URL"),
                ));
      }
    }
  }

  _joinMeeting() async {
    //JitsiMeet.r
    
    JitsiMeet.closeMeeting();
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;
    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      FeatureFlagEnum.ADD_PEOPLE_ENABLED: false,
      FeatureFlagEnum.INVITE_ENABLED: false,
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(room: roomText.text)
      ..serverURL = serverUrl //"http://localhost.50181/"
      ..subject = subjectText.text
      ..userDisplayName = nameText.text
      ..userEmail = emailText.text
      ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      ..audioOnly = isAudioOnly
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomText.text,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": true,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": nameText.text},
        "enableAddPeople": false,
        "enableInvite": false,
        "disableInviteFunctions": false,
        "invite.enabled": false
      };

    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}

class URLdialog extends StatefulWidget {
  const URLdialog({
    Key? key,
  }) : super(key: key);

  @override
  _URLdialogState createState() => _URLdialogState();
}

class _URLdialogState extends State<URLdialog> {
  TextEditingController st = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        SizedBox(
          
          height: 64.0,
          width: double.maxFinite,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(st.text);
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateColor.resolveWith((states) => Colors.brown)),
          ),
        )
      ],
      content: TextField(
        controller: st,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Enter Joining Link",
        ),
      ),
    );
  }
}

