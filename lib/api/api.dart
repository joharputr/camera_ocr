import 'package:dio/dio.dart';

class ApiOcr {
  Dio dio = Dio();

  Future<dynamic> postOcr(String imagePath) async {
    final url = "https://api.platerecognizer.com/v1/plate-reader/";
    final response = await dio.post(url, data:);
  }
}