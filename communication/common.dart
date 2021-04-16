import 'package:http/http.dart' as http;

enum ResponseState { successful, failure, error }

class ResponseReturned {
  ResponseState state;
  http.Response response;
  ResponseReturned(this.state, this.response);
}