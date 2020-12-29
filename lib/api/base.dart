class Base {
  // ignore: non_constant_identifier_names

//PRODUCT
  // final String URL_GET_TOKEN = 'https://bioapi.hyperlogy.com/api/Token/Get';
  // final String URL_OCR = 'https://bioapi.hyperlogy.com/api/ProcessAutomation/OCR';
  // final String URL_FACE =
  //     'https://bioapi.hyperlogy.com/api/FaceVerify/Liveness';
  // final String publicKey = 'Hyper@1234';

// DEV
  final String URL_GET_TOKEN = 'http://14.224.132.206:8688/api/Token/Get';
  // final String URL_OCR = 'http://14.224.132.206:8681/api/ProcessAutomation/OCR';
  final String URL_OCR = 'http://14.224.132.206:8686/api/ProcessAutomation/OCR';
  final String URL_FACE = 'http://14.224.132.206:8681/api/FaceVerify/Liveness';
  final String publicKey = 'Hyper@1234';

// JITSI
  final String JITSI_MAKE_CALL =
      'https://smartform02.hyperlogy.com/SmartForm/CallCenter/RequestCall';
  final String JITSI_INFO_CALL =
      'https://smartform02.hyperlogy.com/SmartForm/CallCenter/InfoCall';
}
