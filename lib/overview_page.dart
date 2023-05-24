import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late Future<ListResult> futureFiles;
  @override
  void initState() {
    futureFiles = FirebaseStorage.instance.ref().listAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ListResult>(
        future: futureFiles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final files = snapshot.data!.items;
            return ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return ListTile(
                    title: Text(file.name),
                    trailing: IconButton(
                        onPressed: () => compute(downloadFile, file),
                        icon: const Icon(Icons.download)),
                  );
                });
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  static Future downloadFile(Reference ref) async {
    try {
      final url = await ref.getDownloadURL();
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${ref.name}';
      await Dio().download(url, path);
      if (url.contains('.mp4')) {
        await GallerySaver.saveVideo(path, toDcim: true);
      } else if (url.contains('.jpg')) {
        await GallerySaver.saveImage(path, toDcim: true);
      }
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'test', parameters: {'content': e});
    }
    //showMessage(ref);
  }

  void showMessage(Reference ref) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download ${ref.name}')));
  }
}
// test commit