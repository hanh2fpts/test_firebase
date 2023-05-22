import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

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
                    trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
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
}
