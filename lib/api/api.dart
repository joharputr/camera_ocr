import 'dart:convert';
import 'dart:io';

import 'package:camera2/model/ocr_model.dart';
import 'package:dio/dio.dart';

class ApiOcr {
  Dio dio = Dio();

  Future<dynamic> postOcr(File file) async {
    String fileName = file.path.split('/').last;

    FormData data = FormData.fromMap({
      "upload": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    print("dataaaa = ${data.boundary}");

    final url = "https://api.platerecognizer.com/v1/plate-reader/";

    var headers = {
      "Authorization": "Token 845d3d6f4cb306f6fb462b7a6bb71c1fbc542902",
    };

    try {
      final response = await dio.post(url,
          options: Options(
              headers: headers,
              sendTimeout: 10 * 1000, // 60 seconds
              receiveTimeout: 10 * 1000 // 60 seconds
              ),
          data: data);

      print("responseBody = ${json.encode(response.data)}");
      print("resuuult = ${response.data['results']}");
      List<dynamic> result = response.data['results'];

      if (response.statusCode == 201 && result.isNotEmpty) {
        return ocrModelFromJson(response.data);
      } else {
        return "Plat Nomor Tidak Ditemukan";
      }
    } on DioError catch (e) {
      print("DioError = ${e}");
    }
  }
}
