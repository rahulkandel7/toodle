import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> toast({
  required BuildContext context,
  required String label,
  required Color color,
  String? subTitle,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          subTitle != null ? Text(subTitle) : const SizedBox(),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
    ),
  );
}
