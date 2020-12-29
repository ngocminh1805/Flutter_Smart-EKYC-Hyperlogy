import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_ekyc/api/base.dart';
import 'package:smart_ekyc/features/finish_ekyc/finish-ekyc-screen.dart';
import 'package:smart_ekyc/features/upload-images/components/image-preview.dart';
import 'package:smart_ekyc/features/upload-images/components/user-info-item.dart';
import 'package:http/http.dart' as http;
import 'package:smart_ekyc/features/upload-images/upload-identity-card-screen.dart';

import 'models/user-info.dart';

class FinishScreenV2 extends StatefulWidget {
  final String path1; // image front identity card
  final String path2; // image back identity card
  final String path3; // image face 1
  final String path4; // image face 2
  final String path5; // image face 3

  FinishScreenV2({this.path1, this.path2, this.path3, this.path4, this.path5});

  @override
  _FinishScreenV2 createState() => _FinishScreenV2();
}

class _FinishScreenV2 extends State<FinishScreenV2> {
  List data = []; // lưu trữ data của CMT
  bool isloading = true; // loading dữ liệu
  var base = Base();
  String message = 'Đang so sánh khuôn mặt';
  bool matchingResult; // so sánh khuôn mặt khớp hay không do api trả về
  bool compareFace = true; // đang đợi so sánh
  String userImage = '';

  @override
  void initState() {
    getData();
    liveNess();
    super.initState();
  }

  // -------------- item hiển thị dữ liệu CMT ------------------------------------------------------------------------------------------
  Widget items(item) {
    if (item.runtimeType == UserInfo) {
      return UserInfoItem(label: item.label, value: item.value);
    } else {
      return ImagePreview(path: item);
    }
  }

// ------------------------- loading - loading dữ liệu --------------------------------------------------------------------------------
  Widget loading() {
    return Expanded(
        child: Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    ));
  }

// ------------------------- render main - hiển thị danh sách thông tin thẻ hoặc đang loading dữ liệu------------------------------------
  Widget renderMain() {
    if (isloading) {
      return loading();
    } else {
      return Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return items(data[index]);
          },
          itemCount: data.length,
        ),
      );
    }
  }

// --------------- render message - text hiển thị tiến trình so sánh khuôn mặt ------------------------------------------------------------
  Widget renderMess() {
    if (compareFace) {
      return Text('Đang so sánh khuôn mặt ...',
          style: TextStyle(color: Colors.orange));
    } else if (matchingResult) {
      return Text('Khuôn mặt và CMT trùng nhau',
          style: TextStyle(color: Colors.green));
    } else {
      return Text('Khuôn mặt và CMT không trùng nhau',
          style: TextStyle(color: Colors.red));
    }
  }
  // ------------ render button - button hoàn thành đang ký nếu khuôn mặt trùng khớp hoặc làm lại nếu không trùng ----------------------------

  Widget renderButton() {
    // ----------------đang so sánh thì không hiện gì -----------------------------------------------------
    if (compareFace) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 20, left: 20),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
        // color: Colors.blueGrey,
        child: FlatButton(
          onPressed: () => onReCapture(),
          child: Text(
            "Thực hiện lại",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          color: Colors.blueGrey,
          padding: EdgeInsets.only(bottom: 5, top: 5, left: 30, right: 30),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30)),
        ),
      );
    }
    // ---------------- so sánh trùng khớp ---------------------- ------------------------------------------
    else if (matchingResult) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 20, left: 20),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
        // color: Colors.blueGrey,
        child: FlatButton(
          onPressed: () => onComplete(),
          child: Text(
            "Hoàn tất đăng ký",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          color: Colors.blueGrey,
          padding: EdgeInsets.only(bottom: 5, top: 5, left: 30, right: 30),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30)),
        ),
      );
    }
    // ------------------- so sánh không trùng khớp ------------------------- -----------------------------
    else {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 20, left: 20),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
        // color: Colors.blueGrey,
        child: FlatButton(
          onPressed: () => onReCapture(),
          child: Text(
            "Thực hiện lại",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          color: Colors.blueGrey,
          padding: EdgeInsets.only(bottom: 5, top: 5, left: 30, right: 30),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30)),
        ),
      );
    }
  }

  // ------------------ render user images path--------------------------------------------------------------------------------------
  String checkUserImage(int num) {
    switch (num) {
      case 1:
        return widget.path3;
        break;
      case 2:
        return widget.path4;
        break;
      case 3:
        return widget.path5;
        break;
      default:
        return widget.path3;
    }
  }

  // --------------------- render user image widget ----------------------------------------------------------------------------

  Widget renderUserImage() {
    if (userImage.isNotEmpty) {
      return Container(
        padding: EdgeInsets.only(bottom: 20),
        child: CircleAvatar(
          backgroundImage: FileImage(File(userImage)),
          radius: 75,
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(bottom: 20),
        child: CircleAvatar(
          child: Icon(
            Icons.person,
            size: 100,
          ),
          radius: 75,
        ),
      );
    }
  }

  // ------------------ render screen --------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return
        //  WillPopScope(
        //     onWillPop: () {
        //       return new Future(() => false);
        //     },
        //     child:
        Scaffold(
      body: Container(
          child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 40, bottom: 10),
            decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Column(
              children: <Widget>[renderUserImage(), renderMess()],
            ),
          ),
          renderButton(),
          renderMain(),
        ],
      )),
    );
    // );
  }

  //--------------------------- thực hiện lại thao tác --------------------------------------------------------------------------
  void onReCapture() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadIdentityCardScreen()),
    );
  }

  // --------------------------- hoàn thành đăng ký ---------------------------------------------------------------------------

  void onComplete() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinishEkycScreen()),
    );
  }

  // --------------- read data ocr - đọc data ocr từ SharePreferences ----------------------------------------------------------
  Future getData() async {
    final prefs = await SharedPreferences.getInstance();
    data.add(UserInfo('Loại thẻ', prefs.getString('identCardType')));
    data.add(
        UserInfo('Chứng minh nhân dân số', prefs.getString('identCardNumber')));
    data.add(UserInfo('Họ và tên', prefs.getString('identCardName')));
    data.add(
        UserInfo('Ngày,tháng,năm,sinh', prefs.getString('identCardBirthDate')));
    data.add(UserInfo('Quê quán', prefs.getString('identCardCountry')));
    data.add(UserInfo(
        'Địa chỉ thường chú', prefs.getString('identCardAdrResidence')));
    data.add(UserInfo('Giới tính', prefs.getString('identCardGender')));
    data.add(UserInfo('Ngày cấp', prefs.getString('identCardIssueDate')));
    data.add(
        UserInfo('Có giá trị đến', prefs.getString('identCardExpireDate')));
    data.add(UserInfo('Dân tộc/Quốc tịch', prefs.getString('identCardEthnic')));
    data.add(widget.path1);
    data.add(widget.path2);

    setState(() {
      isloading = false;
    });

    log('GUID FINISH SCREEN : ' + prefs.getString('guid'));
  }

  // -------------- hàm gọi api liveness so sánh khuôn mặt ----------------------------------------------------------------------
  void liveNess() async {
    log('PATH FACE IMAGE FINISH SCREEN :' +
        widget.path3 +
        ' - ' +
        widget.path4 +
        ' - ' +
        widget.path5);

    String token, guid;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('Token');
    guid = prefs.getString('guid');
    var URL = 'http://14.224.132.206:8686/api/FaceVerify/Verify';
    var req = new http.MultipartRequest("POST", Uri.parse(URL));

    //--------------- tạo header và đẩy file ảnh và guid và params của api -----------------------------------------------------
    Map<String, String> headers = {"Authorization": "Bear " + token};
    req.files
        .add(await http.MultipartFile.fromPath('CaptureImage', widget.path3));
    req.fields['GuidID'] = guid;
    req.headers.addAll(headers);

    //------- gọi api ---------------------------------------------------------------------------------------------

    var res = await req.send();
    res.stream.transform(utf8.decoder).listen((response) async {
      log("RESPONSE_liveNess :" + response);
      var parsed = json.decode(response);
      var data = parsed['data'];

      // ----------- set state cho biết nhận diện thành công hay không -------------------------------------------
      if (data != null) {
        setState(() {
          matchingResult = data['result'];
          compareFace = false;
          userImage = checkUserImage(data['imageNumber']);
        });
      }
    });
  }
}
