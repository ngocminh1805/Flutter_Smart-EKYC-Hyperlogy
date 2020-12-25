import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinishEkycScreen extends StatefulWidget {
  @override
  _FinishEkycSceen createState() => _FinishEkycSceen();
}

class _FinishEkycSceen extends State<FinishEkycScreen> {
  String userName;
  String passWord;
  String guid;

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
            Expanded(),
            Container(
              child: FlatButton(
                child: Text('Gửi yêu cầu kết nối tới tổng đài viên'),
                color: Colors.blueGrey,
                onPressed: () => makeCall(),
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

  // ------------ gửi yêu cầu kết nối với tổng đài viên ---------------------
  void makeCall() {}
}
