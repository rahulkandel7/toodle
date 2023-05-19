import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/constants/api_constants.dart';
import 'package:toddle/featurers/offline_storage/data/models/offline_exam.dart';
import 'package:toddle/featurers/offline_storage/data/models/offline_question.dart';
import 'package:toddle/featurers/offline_storage/data/sources/offline_data_source.dart';

class OfflineStorageController {
  OfflineStorageController();

  Future<bool> storeInHive({
    required int id,
    required String setNumber,
    required String examType,
  }) async {
    // OfflineExam offlineExam = OfflineExam(
    //     examType: examType, id: id, questions: questions, setNumber: setNumber);
    // * Shared Prefrences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // * DIO
    Dio dio = Dio();
    try {
      // * Fetching all questions
      var response = await dio.get('${ApiConstants.url}start-exam/$id',
          options: Options(
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer ${prefs.getString('token')}',
            },
          ));

      // * getting all 40 questions and storing as List
      final result = response.data['data'] as List<dynamic>;

      // List<OfflineQuestions> offQus = result.map((e) {
      //   if (e != null) {
      //     print('--------------------------');

      //     print(e['id']);
      //     print('--------------------------');

      //     return OfflineQuestions.fromMap(e);
      //   }
      // }).toList();

      List<OfflineQuestions> offQus =
          result.map((e) => OfflineQuestions.fromMap(e)).toList();

      for (var qus in offQus) {
        if (qus.filePath != null) {
          String url = '${ApiConstants.questionFileUrl}${qus.filePath}';
          var tempDir = await getApplicationSupportDirectory();
          String fullPath = '${tempDir.path}/${qus.filePath!}';
          downloadFile(dio, url, fullPath);
        }
        if (qus.isImage != "No" || qus.isOptionAudio == 'Yes') {
          // * For Option 1 download
          if (qus.option1.isNotEmpty) {
            String url = '${ApiConstants.answerImageUrl}${qus.option1}';
            var tempDir = await getApplicationSupportDirectory();
            String fullPath = '${tempDir.path}/${qus.option1}';
            downloadFile(dio, url, fullPath);
          }
          // * For Option2 download
          if (qus.option2.isNotEmpty) {
            String url = '${ApiConstants.answerImageUrl}${qus.option2}';
            var tempDir = await getApplicationSupportDirectory();
            String fullPath = '${tempDir.path}/${qus.option2}';

            downloadFile(dio, url, fullPath);
          }

          // * For option 3 download
          if (qus.option3.isNotEmpty) {
            String url = '${ApiConstants.answerImageUrl}${qus.option3}';
            var tempDir = await getApplicationSupportDirectory();
            String fullPath = '${tempDir.path}/${qus.option3}';

            downloadFile(dio, url, fullPath);
          }

          // * For Option 4 download
          if (qus.option4.isNotEmpty) {
            String url = '${ApiConstants.answerImageUrl}${qus.option4}';
            var tempDir = await getApplicationSupportDirectory();
            String fullPath = '${tempDir.path}/${qus.option4}';

            downloadFile(dio, url, fullPath);
          }
        }
        if (qus.isAudio == 'Yes' || qus.isOptionAudio == 'Yes') {
          String url = '${ApiConstants.questionFileUrl}${qus.filePath}';
          var tempDir = await getApplicationSupportDirectory();
          String fullPath = '${tempDir.path}/${qus.filePath!}';
          downloadFile(dio, url, fullPath);
        }
        if (qus.audioPath != null) {
          String url = '${ApiConstants.questionFileUrl}${qus.audioPath}';
          var tempDir = await getApplicationSupportDirectory();
          String fullPath = '${tempDir.path}/${qus.audioPath!}';
          downloadFile(dio, url, fullPath);
        }
      }

      final box = OfflineDataSource.getOfflineExam();

      OfflineExam offlineExam = OfflineExam(
        examType: examType,
        questions: offQus,
        setNumber: setNumber,
      );

      box.put('$examType$setNumber', offlineExam);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future downloadFile(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      // print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      log(e.toString());
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      log((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  List<String> calculateScore(
      {required List<String> questions,
      required List<String> answers,
      required List<OfflineQuestions> data}) {
    int obtainedMarks = 0;
    int fullMarks = data.length;

    for (var i = 0; i < answers.length; i++) {
      OfflineQuestions question =
          data.firstWhere((element) => element.id == int.parse(questions[i]));
      if (question.correctOption == answers[i]) {
        obtainedMarks++;
      }
    }

    List<String> msg = [fullMarks.toString(), obtainedMarks.toString()];
    return msg;
  }
}

final offlineStorageProvider = Provider<OfflineStorageController>((ref) {
  return OfflineStorageController();
});
