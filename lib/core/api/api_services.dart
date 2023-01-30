import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/constants/api_constants.dart';
import 'package:toddle/core/api/dio_exception.dart';

//Creating Provider for aoi service
final apiServiceProvider = Provider<ApiServices>((ref) => ApiServices());

class ApiServices {
  //Post Method For Dio
  postData({required String endPoint, var data}) async {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.url,
        headers: {
          "accept": "application/json",
        },
      ),
    );
    try {
      final result = await dio.post(endPoint, data: data);
      return result.data;
    } on DioError catch (e) {
      throw DioException.fromDioError(e);
    }
  }

  //Get data with Authorize
  getDataWithAuthorize({required String endpoint}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      ),
    );

    try {
      final result = await dio.get(endpoint);
      return result.data;
    } on DioError catch (e) {
      throw DioException.fromDioError(e);
    }
  }
}
