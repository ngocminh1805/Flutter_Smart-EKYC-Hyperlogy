import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_ekyc/api/base.dart';
import 'package:smart_ekyc/features/upload-images/finish-screen.dart';
import 'package:http/http.dart' as http;

class UploadIdentityCardScreen extends StatefulWidget {
  @override
  _UploadIdentityCardScreen createState() => new _UploadIdentityCardScreen();
}

class _UploadIdentityCardScreen extends State<UploadIdentityCardScreen> {
  var base = Base();
  CameraController controller;
  List cameras;
  int selectedCameraIdx; // choose front camera or back camera
  int step =
      0; // step capture picture (0: chụp mặt trước, 1: chụp mặt sau, 2: chụp khuôn mặt )
  String imagePath1; // front identitycard
  String imagePath2; // back indentitycard
  String imagePath3; // face image 1
  String imagePath4; // face image 2
  String imagePath5; // face image 3
  bool preview = false; // preview ảnh sau khi chụp
  String token; // user token
  String ocr_messages = ''; // messages được ocr trả về
  double process_value = 0.1; // giá trị của process bar chụp ảnh khuôn mặt

  @override
  void initState() {
    super.initState();
    // 1
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      // 3
      print('Error: $err.code\nError Message: $err.message');
    });
    //
  }
//

// ------------------- khởi tạo camere controller -----------------------------------------
  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    // 4
    controller.addListener(() {
      // 5
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    // 6
    try {
      await controller.initialize();
    } on CameraException catch (e) {
      // _showCameraException(e);
      print("Camera Err: ${e}");
    }

    if (mounted) {
      setState(() {});
    }
  }

  ///---------- render main screen - hiển thị camera hoặc chế độ preview ảnh sau khi chụp -----------------------------------------------
  Widget renderMainScreen() {
    if (preview && step == 0) {
      return previewImage(imagePath1);
    } else if (preview && step == 1) {
      return previewImage(imagePath2);
    } else {
      return Container(
        alignment: Alignment.center,
        child: Stack(
          children: <Widget>[_cameraPreviewWidget(), _sq()],
        ),
      );
    }
  }

  //--------------------------- camera widget - hiển thị camera -------------------------------------------------
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    return AspectRatio(
      // aspectRatio: controller.value.aspectRatio,
      aspectRatio: 9 / 16,
      child: CameraPreview(controller),
    );
  }

  //--------------- render preview screen - preview ảnh sau khi chụp  ----------------------
  Widget previewImage(String path) {
    return Container(
      child: Image(
        image: FileImage(File(path)),
      ),
    );
  }

  // ------------- render title - title của thanh toolbar ------------------------------

  String title() {
    if (!preview && step == 0) {
      return "Chụp mặt trước";
    } else if (preview && step == 0) {
      return "Xem ảnh mặt trước";
    } else if (!preview && step == 1) {
      return "Chụp mặt sau";
    } else if (preview && step == 1) {
      return "Xem ảnh mặt sau";
    } else {
      return "Chụp ảnh khuôn mặt";
    }
  }

  // ------------ render button ctn - hiển thị các nút bấm theo từng step  -----------------------------
  Widget buttonConatiner() {
    if (preview) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, right: 20, left: 20),
              child: FlatButton(
                onPressed: () => onConfirm(),
                child: Text(
                  "Ok",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                color: Colors.blueGrey,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(8)),
              ),
            ),
            Container(
              child: FlatButton(
                onPressed: () => onReCapture(),
                child: Text(
                  "Chụp Lại",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                color: Colors.blueGrey,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(8)),
              ),
            )
          ],
        ),
      );
    } else if (step > 1) {
      return Container(
          height: 70,
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Đặt mặt vào khung camera',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 30, left: 30),
                  child: LinearProgressIndicator(
                    value: process_value,
                    backgroundColor: Colors.blueGrey,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                )
              ],
            ),
          ));
    } else {
      return Container(
        height: 60,
        width: 60,
        margin: EdgeInsets.only(top: 5),
        child: FlatButton(
          child: Icon(
            Icons.camera,
            color: Colors.white,
            size: 45,
          ),
          padding: EdgeInsets.all(0),
          onPressed: () => onCapturePressed(),
          color: Colors.blueGrey,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30)),
        ),
      );
    }
  }

  // --------- render sq - khung ảnh nằm phía trên camera để định vị vị trí thẻ và khuôn mặt  ------------------------------

  Widget _sq() {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    if (step < 2) {
      return Positioned.fill(
          child: Opacity(
        opacity: 0.5,
        child: Image(
          image: AssetImage('assets/sq.png'),
          fit: BoxFit.fitHeight,
        ),
      ));
    } else {
      return Positioned.fill(
          child: Opacity(
        opacity: 0.5,
        child: Image(
          image: AssetImage('assets/sq2.png'),
          fit: BoxFit.fitWidth,
        ),
      ));
    }
  }

  // ----------------------- build -----------------------------------------
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
        padding: EdgeInsets.only(
          top: 30,
          right: 10,
          left: 10,
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                title(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: renderMainScreen(),
            ),
            buttonConatiner()
          ],
        ),
      ),
      // )
    );
  }

  // ----------- capture image - hàm chụp ảnh trả về đường dẫn ảnh  --------------------------------

  Future<String> capture() async {
    try {
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.jpeg',
      );
      await controller.takePicture(path);
      return path;
    } catch (e) {
      print(e);
    }
    return '';
  }

  // ----------- on press capture - chụp ảnh CMT bằng btn  -----------------------
  void onCapturePressed() async {
    capture().then((path) => {
          if (step == 0)
            {
              setState(() {
                imagePath1 = path;
                preview = true;
              })
            }
          else if (step == 1)
            {
              setState(() {
                imagePath2 = path;
                preview = true;
              })
            }
        });
  }

//------------- switch camera - hàm đổi chiều camera -----------------------------
  void onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    _initCameraController(selectedCamera);
  }

  // ----------- comfirm - preview ảnh CMT ok   --------------------
  void onConfirm() {
    if (step == 1) {
      onSwitchCamera();
      setState(() {
        preview = false;
        step++;
      });
      checkFace();
    }
    setState(() {
      preview = false;
      step++;
    });
  }

  // ------------ reCapture - chụp lại ảnh CMT --------------------
  void onReCapture() {
    setState(() {
      preview = false;
    });
  }

  // ------------ check face - hàm gọi ocr và chụp 3 ảnh  khuôn mặt (sau khi ocr thực hiện xong sẽ tiến hành chụp ảnh khuôn mặt)
  void checkFace() {
    ocr().then((value) => null).whenComplete(() => {
          if (ocr_messages.trim().toLowerCase() == 'cắt góc' ||
              ocr_messages.trim().toLowerCase() == "đục lỗ" ||
              ocr_messages.trim().toLowerCase() == "mờ" ||
              ocr_messages.trim().toLowerCase() == "lóa")
            {showMessage(ocr_messages)}
          else
            {
              log('............... Check Face ........................'),
              // Future.delayed(const Duration(milliseconds: 3000), () {
// --------------------------- capture face image 1 --------------------
              capture()
                  .then((path) => {
                        setState(() {
                          imagePath3 = path;
                          process_value = 0.4;
                        })
                      })
                  .whenComplete(() =>
                      Future.delayed(const Duration(milliseconds: 1500), () {
// ----------------------------- capture face image 2 -------------------
                        capture()
                            .then((path) => setState(() {
                                  imagePath4 = path;
                                  process_value = 0.7;
                                }))
                            .whenComplete(() => Future.delayed(
                                    const Duration(milliseconds: 1500), () {
// ----------------------------- capture face image 3 -------------------------
                                  capture()
                                      .then((path) => setState(() {
                                            imagePath5 = path;
                                            process_value = 1;
                                          }))
                                      .whenComplete(() => {
                                            log('PATH FACE IMAGE :' +
                                                imagePath3 +
                                                ' - ' +
                                                imagePath4 +
                                                ' - ' +
                                                imagePath5),
                                            Navigator.push(
                                              this.context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FinishScreen(
                                                        path1: imagePath1,
                                                        path2: imagePath2,
                                                        path3: imagePath3,
                                                        path4: imagePath4,
                                                        path5: imagePath5,
                                                      )),
                                            )
                                          });
                                }));
                      }))
            }

          // })
        });
  }

  // --------------- OCR - hàm gọi API OCR để lấy thông tin giấy tờ ----------------------------
  Future ocr() async {
    String token;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('Token');
    log('TOKEN_SharedPreferences : ' + token);
    // ignore: non_constant_identifier_names
    var URL = base.URL_OCR;
    var req = new http.MultipartRequest("POST", Uri.parse(URL));

    // ------ tạo header cho api -----------
    Map<String, String> headers = {"Authorization": "Bear " + token};

    // ---- truyền file ảnh vào params của Api-------------------
    req.files.add(await http.MultipartFile.fromPath('IdCardFront', imagePath1));
    req.files.add(await http.MultipartFile.fromPath('IdCardBack', imagePath2));
    req.headers.addAll(headers);
    //-------------- gọi api -------------------------------
    var res = await req.send();
    res.stream.transform(utf8.decoder).listen((response) async {
      log("RESPONSE_OCR :" + response);
      var parsed = json.decode(response);
      var data = parsed['data']['idCard'];
      log("RESPONSE_OCR_DATA :" + parsed['data']['idCard'].toString());

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('identCardType', data['identCardType'].toString());
      prefs.setString('identCardNumber', data['identCardNumber'].toString());
      prefs.setString('identCardName', data['identCardName'].toString());
      prefs.setString(
          'identCardBirthDate', data['identCardBirthDate'].toString());
      prefs.setString('identCardEthnic', data['identCardEthnic'].toString());
      prefs.setString('identCardCountry', data['identCardCountry'].toString());
      prefs.setString(
          'identCardAdrResidence', data['identCardAdrResidence'].toString());
      prefs.setString(
          'identCardIssueDate', data['identCardIssueDate'].toString());
      prefs.setString('identCardGender', data['identCardGender'].toString());
      prefs.setString(
          'identCardExpireDate', data['identCardExpireDate'].toString());
      prefs.setString('guid', data['guid']);

      var message = parsed['data']['messages '];
      if (message != null) {
        setState(() {
          ocr_messages = message;
        });
        log('OCR_MESSAGES: ' + message);
      }
    });
  }

  // ---------- show message - hiển thị alert message ocr -------------------------
  void showMessage(String msg) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Lỗi"),
      content: Text('Ảnh chụp không hợp lệ: ' + msg),
      actions: <Widget>[
        FlatButton(onPressed: () => oncloseDialog(), child: Text('Ok'))
      ],
    );

    // show the dialog
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //-------------------- close dialog - đóng dialog và thực hiện chụp ảnh lại-----------
  void oncloseDialog() {
    // Navigator.pushAndRemoveUntil(
    //     this.context,
    //     MaterialPageRoute(builder: (context) => UploadIdentityCardScreen()),
    //     (route) => false);
    Navigator.pushReplacement(
      this.context,
      MaterialPageRoute(builder: (context) => UploadIdentityCardScreen()),
    );
  }
}
