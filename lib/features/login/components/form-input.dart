import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_ekyc/api/base.dart';
import 'package:smart_ekyc/features/upload-images/upload-identity-card-screen.dart';
import 'package:http/http.dart' as http;

class FormInput extends StatefulWidget {
  @override
  _FormInput createState() => _FormInput();
}

class _FormInput extends State<FormInput> {
  final userNameContoller = TextEditingController();
  final passWordController = TextEditingController();
  bool isUserNameValidate = false;
  bool isPassWordValidate = false;
  var base = Base();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "NHẬP THÔNG TIN",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          //---------------- input user name ----------------
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  hintText: 'nhập tên đăng nhập',
                  labelText: "Tên đăng nhập",
                  errorText: isUserNameValidate
                      ? 'Vui lòng nhập tên đăng nhập'
                      : null),
              controller: userNameContoller,
            ),
          ),
          // ------------------ input password ----------------------
          Padding(
            padding: EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 40),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  hintText: 'nhập mật khẩu',
                  labelText: "Mật khẩu",
                  errorText:
                      isPassWordValidate ? 'Vui lòng nhập mật khẩu' : null),
              controller: passWordController,
              obscureText: true,
            ),
          ),

          // ------------------- submit button ----------------------------------------
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(right: 20, left: 20),
            child: FlatButton(
              onPressed: () => onSubmit(),
              child: Text(
                "Đăng nhập",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.blueGrey,
              padding: EdgeInsets.only(bottom: 5, top: 5, left: 30, right: 30),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30)),
            ),
          )
        ],
      ),
    );
  }

  // --------------- on submit press ----------------------------------
  void onSubmit() {
    var userName = userNameContoller.text;
    var passWord = passWordController.text;
    log("User Info :" + userName + " - " + passWord);
    validatePassword(passWord);
    validateUserName(userName);
    if (userName.isNotEmpty && passWord.isNotEmpty) {
      getToken(userName, passWord);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadIdentityCardScreen()),
      );
    }
  }

  // ---------------- validate user name ----------------------------------
  void validateUserName(String userInput) {
    if (userInput.isEmpty) {
      setState(() {
        isUserNameValidate = true;
      });
    } else {
      setState(() {
        isUserNameValidate = false;
      });
    }
  }

  // ----------------- validate password -----------------------------------
  void validatePassword(String password) {
    if (password.isEmpty) {
      setState(() {
        isPassWordValidate = true;
      });
    } else {
      setState(() {
        isPassWordValidate = false;
      });
    }
  }

  // ----------------------- get token -------------------------------------

  Future getToken(String userName, String passWord) async {
    // ignore: non_constant_identifier_names
    var URL = base.URL_GET_TOKEN;
    String publicKey = base.publicKey;
    final response = await http.get('${URL}?publicKey=${publicKey}');

    log('RESPONSE : ' + response.body);
    var parsed = json.decode(response.body);
    String token = parsed['Token'].toString();
    log('TOKEN : ' + token);

    // save to local storage
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Token', token);
    prefs.setString('userName', userName);
    prefs.setString('passWord', passWord);
  }
}
