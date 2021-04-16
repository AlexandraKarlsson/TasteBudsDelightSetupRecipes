// import 'dart:io';
// import 'package:path/path.dart';

import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;

import 'common.dart';

Future<ResponseReturned> uploadImage(File image, dynamic name) async {
  print('Running uploadImage, name = $name.');

  const URL = 'http://localhost:8010/image';
  var base64Image = convert.base64Encode(image.readAsBytesSync());
  try {
    final response = await http.post(
      URL,
      body: {"image": base64Image, "name": name},
    );

    if (response.statusCode == 201) {
      print('response ${response.body}');
      return ResponseReturned(ResponseState.successful, response);
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return ResponseReturned(ResponseState.failure, null);
    }
  } catch (error) {
    print('Request failed with error: $error.');
    return ResponseReturned(ResponseState.error, null);
  }
}
