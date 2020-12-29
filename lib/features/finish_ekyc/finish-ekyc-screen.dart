import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jitsi_meet/feature_flag/feature_flag_enum.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_ekyc/api/base.dart';
import 'package:smart_ekyc/features/finish_ekyc/jitsi-examples-screen.dart';
import 'package:http/http.dart' as http;

class FinishEkycScreen extends StatefulWidget {
  @override
  _FinishEkycSceen createState() => _FinishEkycSceen();
}

class _FinishEkycSceen extends State<FinishEkycScreen> {
  var base = Base();
  String userName;
  String passWord;
  String guid;
  bool isConnect = false;

  @override
  void initState() {
    // TODO: implement initState
    getInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Text(
                        'Chúc mừng quý khách đã đăng ký tài khoản thành công!!!',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Tài khoản của quý khách giới hạn giao dịch định mức 5,000,000 VNĐ và không được rút tiền mặt. Vui lòng kết nối Video call với tổng đài viên để được nâng cấp hạn mức giao dịch',
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: FlatButton(
                child: Text(
                  isConnect
                      ? 'Đang kết nối với tổng đài viên ...'
                      : 'Gửi yêu cầu kết nối tới tổng đài viên',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                padding:
                    EdgeInsets.only(bottom: 5, top: 5, left: 30, right: 30),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30)),
                color: Colors.blueGrey,
                onPressed: () => onPressButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------lấy thông tin user ----------------------------------
  void getInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
      passWord = prefs.getString('passWord');
      guid = prefs.getString('guid');
    });

    log('FINISH USER INFO :' + userName + ' - ' + passWord + ' - ' + guid);
  }
  // ---------- on press button ---------------------------

  void onPressButton() {
    setState(() {
      isConnect = true;
    });
    makeCall();
  }

  // ------------ gửi yêu cầu kết nối với tổng đài viên ---------------------
  Future<void> makeCall() async {
    log('Make Call');
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => JitsiScreen()),
    // );

    var URL = base.JITSI_MAKE_CALL + '?username=${userName}' + '&guid=${guid}';
    Map<String, String> headers = {'Content-Type': 'multipart/form-data'};
    var response = await http.post(URL, headers: headers);
    var parsed = json.decode(response.body);

    log('test_Client gọi api để yêu cầu một cuộc gọi tới tổng đài');
    var tempId = parsed['Id'];
    log('Id: ' + tempId.toString());
    var tempStatus = parsed['Status'];
    log('Status: ' + tempStatus.toString());
    //REQUESTING = 1 (đã gọi, chưa tạo phòng)
    //CONNECTED = 2 (giao dịch viên đã tiếp nhận cuộc gọi, sẵn sàng join phòng)
    //COMPLETED = 3 (đã kết thúc, rời khỏi phòng)
    if (tempStatus == 1) {
      this.taskCall(tempId, 0);
    }
  }

  //--------------------------------

  taskCall(String id, int delay) async {
    Future.delayed(Duration(milliseconds: delay), () async {
      var parsed;
      log('Client kiểm tra trạng thái! - id :' + id);
      var URL = base.JITSI_INFO_CALL + '?id=' + id;
      log('URL_check: ' + URL);
      Map<String, String> headers = {'Content-Type': 'multipart/form-data'};
      await http
          .post(URL, headers: headers)
          .then((response) => {
                parsed = json.decode(response.body),
                log('TaskCall Status: ' + parsed['Status'].toString()),
                if (parsed['Status'] == 2)
                  {
                    log('Kết nối OK!'),
                    _joinMeeting(id),
                    taskCheck(id, 5000),
                    setState(() {
                      isConnect = false;
                    })
                  }
                else
                  {this.taskCall(id, 1500)}
                // log('Đang đợi kết nối')
              })
          .catchError((error) => {log('InfoCall Error: ' + error.message)});
    });
  }

  // -------------------------

  taskCheck(String id, int delay) {
    Future.delayed(Duration(milliseconds: delay), () async {
      var parsed;
      log('Kiểm tra trạng thái tắt');
      var URL = base.JITSI_INFO_CALL + '?id=' + id;
      log('URL_check: ' + URL);
      Map<String, String> headers = {'Content-Type': 'multipart/form-data'};
      await http
          .post(URL, headers: headers)
          .then((response) => {
                parsed = json.decode(response.body),
                log('TaskCall Status: ' + parsed['Status'].toString()),
                if (parsed['Status'] == 4)
                  {log('Ngắt kết nối!!'), _leaveMeeting()}
                else
                  {this.taskCheck(id, 2500)}
              })
          .catchError((error) => {log('InfoCall Error: ' + error.message)});
    });
  }

  // ------------------------ open Jitsi screen ----------------------------

  _joinMeeting(String roomId) async {
    // String serverUrl =
    //     serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      };

      // // Here is an example, disabling features for each platform
      // if (Platform.isAndroid) {
      //   // Disable ConnectionService usage on Android to avoid issues (see README)
      //   featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      // } else if (Platform.isIOS) {
      //   // Disable PIP on iOS as it looks weird
      //   featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      // }

      // Define meetings options here
      var options = JitsiMeetingOptions()
        ..room = roomId
        ..serverURL = 'https://meet.hyperlogy.com/'
        ..subject = 'Test Jitsi'
        ..userDisplayName = 'Minh Be Ti'
        // ..userEmail = emailText.text
        // ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
        // ..audioOnly = isAudioOnly
        // ..audioMuted = isAudioMuted
        // ..videoMuted = isVideoMuted
        ..featureFlags.addAll(featureFlags);

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
          debugPrint("${options.room} will join with message: $message");
        }, onConferenceJoined: ({message}) {
          debugPrint("${options.room} joined with message: $message");
        }, onConferenceTerminated: ({message}) {
          debugPrint("${options.room} terminated with message: $message");
        }),
        // by default, plugin default constraints are used
        //roomNameConstraints: new Map(), // to disable all constraints
        //roomNameConstraints: customContraints, // to use your own constraint(s)
      );
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  // close meet
  _leaveMeeting() {
    JitsiMeet.closeMeeting();
  }
}
