import 'package:flutter/material.dart';
import 'package:toddle/constants/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceCard extends StatelessWidget {
  final String title;
  final String filePath;

  const ResourceCard({required this.title, required this.filePath, super.key});

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Card(
      elevation: 7,
      shadowColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Divider(
              color: Colors.grey.shade400,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: () {
                    _launchInBrowser(
                        Uri.parse('${ApiConstants.resourceUrl}/$filePath'));
                  },
                  child: const Text(
                    'View Resource',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
