import 'dart:io';

import 'package:http/http.dart' as http;

import 'network.dart';

enum HttpMethod { get, post, put, delete }

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
    },
  });

  ///Helper method
  Future<NetworkResponse<dynamic>> uploadFile(
    String path,
    File file, {
    Map<String, String?>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);

      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: file.path.split('/').last,
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse.completed(response.body);
      } else {
        return NetworkResponse.error('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      return NetworkResponse.error('Upload failed: $e');
    }
  }
}
