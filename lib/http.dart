import 'dart:convert';

import 'package:http/http.dart' as http;

class Http {
  static const _authority = "api.collectapi.com";
  static const _unencodedPath = "/dictionary/wordSearchTurkish";
  static const _api = "apikey 2uI6KqvTZAorkBUznXY8b3:0xRcDjnYedOE0Djyr1weo7";

  static Future checkIfWordExists(String word) async {
    try {
      final queryParameters = {
        'query': word.toLowerCase(),
      };
      final headers = {
        'content-type': "application/json;charset=UTF-8",
        'authorization': _api
      };

      final uri = Uri.https(_authority, _unencodedPath, queryParameters);
      final response = await http.get(uri, headers: headers);

      final json = jsonDecode(response.body);
      return json["success"];
    } catch (ex) {
      print(ex.toString());
    }
  }
}
