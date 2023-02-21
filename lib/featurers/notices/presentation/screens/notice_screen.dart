import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/core/darkmode_notifier.dart';

import '../controllers/notice_controller.dart';

class NoticeScreen extends ConsumerWidget {
  static const routeName = "/notices";
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notices'),
      ),
      body: ref.watch(noticeControllerProvider).when(
            data: (data) {
              bool darkmode = ref.watch(darkmodeNotifierProvider);
              return RefreshIndicator(
                onRefresh: () => ref
                    .refresh(noticeControllerProvider.notifier)
                    .fetchNotice(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.02,
                    horizontal: screenSize.width * 0.04,
                  ),
                  child: ListView.builder(
                    itemBuilder: (ctx, i) => Padding(
                      padding:
                          EdgeInsets.only(bottom: screenSize.height * 0.02),
                      child: ListTile(
                        tileColor: darkmode
                            ? Theme.of(context).cardColor
                            : AppConstants.cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            data[i].notice,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        subtitle: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 5),
                            child: Text(data[i].date),
                          ),
                        ),
                      ),
                    ),
                    itemCount: data.length,
                  ),
                ),
              );
            },
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }
}
