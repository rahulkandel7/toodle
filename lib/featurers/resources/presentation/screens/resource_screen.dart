import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/resources/presentation/screens/widgets/resource_card.dart';

import '../controllers/resource_controller.dart';

class ResourceScreen extends ConsumerStatefulWidget {
  static const routeName = '/resource';
  const ResourceScreen({super.key});

  @override
  ResourceScreenState createState() => ResourceScreenState();
}

class ResourceScreenState extends ConsumerState<ResourceScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resources',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      body: ref.watch(resourceControllerProvider).when(
            data: (data) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.02,
                    horizontal: screenSize.width * 0.04,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View all resources',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                      const Divider(),
                      SizedBox(
                        height: screenSize.height * 0.9,
                        child: ListView.builder(
                          itemBuilder: (ctx, i) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10.0, left: 10.0),
                            child: ResourceCard(
                              title: data[i].title,
                              filePath: data[i].filePath,
                            ),
                          ),
                          itemCount: data.length,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            error: (e, s) => Text(e.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }
}
