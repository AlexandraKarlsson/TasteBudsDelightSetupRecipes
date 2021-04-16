// import 'dart:convert' as convert;
import 'package:http/http.dart' as http;


import 'common.dart';
import 'settings.dart';

Settings settings = Settings();

String getBackendURL() {
  return 'http://${settings.backendAddress}:${settings.backendPort}/tastebuds';
}

// Create user
Future<ResponseReturned> createUser(String userJson) async {
  print('Running createUser, userJson = $userJson');

  String url = '${getBackendURL()}/user';

  const headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8'
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: userJson,
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

// Login user
Future<ResponseReturned> loginUser(String loginJson) async {
  print('Running loginUser, loginJson = $loginJson');

  String url = '${getBackendURL()}/user/login';

  const headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8'
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: loginJson,
    );
    if (response.statusCode == 200) {
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

// Create recipe
Future<ResponseReturned> createRecipe(
    String recipeJson, String userToken) async {
  print('Running createRecipe, recipeJson: $recipeJson, Token = $userToken.');

  String url = '${getBackendURL()}/recipe';

  var headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'x-auth': userToken
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: recipeJson,
    );
    if (response.statusCode == 201) {
      print('response ${response.body}');
      return ResponseReturned(ResponseState.successful, response);
    } else {
      print('response ${response.body}');
      print('Request failed with status: ${response.statusCode}.');
      return ResponseReturned(ResponseState.failure, null);
    }
  } catch (error) {
    print('Request failed with error: $error.');
    return ResponseReturned(ResponseState.error, null);
  }
}

// Logout user
Future<ResponseReturned> logoutUser(String userToken) async {
  print('Running logoutUser, Token = $userToken');

  String url = '${getBackendURL()}/user/me/token';
  var headers = <String, String>{'x-auth': userToken};

  try {
    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 200) {
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
