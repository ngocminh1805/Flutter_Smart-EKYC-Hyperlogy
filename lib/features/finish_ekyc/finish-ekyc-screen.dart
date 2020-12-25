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
                  'Gửi yêu cầu kết nối tới tổng đài viên',
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
