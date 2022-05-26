import 'package:chunked_uploader/chunked_uploader.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chunk Upload Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Chunk Upload Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PlatformFile>? _paths;
  String? _extension;
  double progress = 0.0;
  String link = '';

  @override
  void initState() {
    super.initState();
  }

  void _pickFiles() async {
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Unsupported operation$e');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  upload() async {
    setState(() {
      link = '';
    });
    if (_paths == null) {
      showToast('Select a file first.');
    }
    var path = _paths![0].path!;
    String fileName = path.split('/').last;
    String url = 'https://awaitanthony.com/demo/api/v1/file_upload';
    ChunkedUploader chunkedUploader = ChunkedUploader(
      Dio(
        BaseOptions(
          baseUrl: url,
          headers: {
            'Content-Type': 'multipart/form-data',
            'Connection': 'Keep-Alive',
          },
        ),
      ),
    );
    try {
      Response? response = await chunkedUploader.upload(
        fileKey: "file",
        method: "POST",
        filePath: path,
        maxChunkSize: 500000000,
        path: url,
        data: {
          'additional_data': 'hiii',
        },
        onUploadProgress: (v) {
          if (kDebugMode) {
            print(v);
          }

          progress = v;
          setState(() {});
        },
      );
      if (kDebugMode) {
        print(response);
      }

      var data = response?.data;
      if (data != null && data['status'] == true) {
        setState(() {
          link = data['link'];
          progress = 0.0;
        });
        showToast(data['message']);
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _pickFiles();
              },
              child: const Text('Select File'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                upload();
              },
              child: const Text('Upload'),
            ),
            if (progress > 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearPercentIndicator(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  animation: false,
                  lineHeight: 20.0,
                  percent: double.parse(progress.toStringAsExponential(1)),
                  progressColor: Colors.green,
                  center: Text(
                    "${(progress * 100).round()}%",
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (link != '')
              Text(
                link,
                style: const TextStyle(),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
      floatingActionButton: link != ''
          ? FloatingActionButton(
              onPressed: () {
                _launchUrl(link);
              },
              child: const Icon(Icons.remove_red_eye_rounded),
            )
          : null,
    );
  }

  showToast(message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication))
      throw 'Could not launch $url';
  }
}
