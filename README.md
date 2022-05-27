# Flutter Chunk Upload

Hi,

We all face a lot of problems when it comes to uploading a large files to server using FLUTTER.
so I tried to help all by researching how to upload large files to server using FLUTTER and # Laravel(php) backend.

![grab-landing-page](https://github.com/awaitANTHONY/flutter_chunk_upload/blob/master/chunk_uploads.gif)

## Getting Started

### Add flutter dependency

```yaml
dependencies:
  file_picker: latest
  dio: latest
  chunked_uploader: latest
```

### Import it
Now in your Dart code, you can use:

```dart
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:chunked_uploader/chunked_uploader.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
```

### Define variable

```dart
List<PlatformFile>? _paths;
String? _extension;
double progress = 0.0;
String link = '';
```
### Super simple codes

file picker code:

```dart
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
```

Dio and ChunkedUploader:

```dart
upload() async {
    if (_paths == null) {
      print('Select a file first.');
    }
    var path = _paths![0].path!;
    String fileName = path.split('/').last;
    String url = 'https://awaitanthony.com/demo/api/v1/file_upload'; // change it with your api url
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
        },
      );
      if (kDebugMode) {
        print(response);
      }

    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
```

design part:

```dart
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
          ],
        ),
      ),
    );
  }
```
### Laravel(php) backend codes

## Installing Laravel Chunk Upload Package

**1. Install via composer**

```
composer require pion/laravel-chunk-upload
```

**2. Publish the config (Optional)**

```
php artisan vendor:publish --provider="Pion\Laravel\ChunkUpload\Providers\ChunkUploadServiceProvider"
```

Make Api route:

```routes/api.php
// post route
Route::post('/v1/file_upload', 'App\Http\Controllers\Api\v1\ApiController@file_upload');
```

### Import it

```php
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
------
use Pion\Laravel\ChunkUpload\Exceptions\UploadMissingFileException;
use Pion\Laravel\ChunkUpload\Handler\AbstractHandler;
use Pion\Laravel\ChunkUpload\Handler\HandlerFactory;
use Pion\Laravel\ChunkUpload\Receiver\FileReceiver;
use Illuminate\Http\UploadedFile;
use File;
```

Rest of laravel codes:
$img->insert('public/watermark.png');

```php
public function file_upload(Request $request)
  {   
      $validator = \Validator::make($request->all(), [

          'file' => 'required|mimes:jpg,png,doc,docx,pdf,xls,xlsx,zip,m4v,avi,flv,mp4,mov',

      ]);

      if ($validator->fails()) {
          return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
      }

      $receiver = new FileReceiver('file', $request, HandlerFactory::classFromRequest($request));
      if ($receiver->isUploaded() === false) {
          throw new UploadMissingFileException();
      }
      $save = $receiver->receive();
      if ($save->isFinished()) {
          $response =  $this->saveFile($save->getFile());

          File::deleteDirectory(storage_path('app/chunks/'));

          //your data insert code

          return response()->json([
              'status' => true,
              'link' => url($response['link']),
              'message' => 'File successfully uploaded.'
          ]);
      }
      $handler = $save->handler();
  }
```

```php
/**
 * Saves the file
 *
 * @param UploadedFile $file
 *
 * @return \Illuminate\Http\JsonResponse
 */
protected function saveFile(UploadedFile $file)
{
    $fileName = $this->createFilename($file);
    $mime = str_replace('/', '-', $file->getMimeType());
    $filePath = "public/uploads/chunk_uploads/";
    $file->move(base_path($filePath), $fileName);

    return [
        'link' => $filePath . $fileName,
        'mime_type' => $mime
    ];
}
/**
 * Create unique filename for uploaded file
 * @param UploadedFile $file
 * @return string
 */
protected function createFilename(UploadedFile $file)
{
    $extension = $file->getClientOriginalExtension();
    $filename =  rand() . time() . "." . $extension;
    return $filename;
}
```

## Contact

For more quires Mail awaitanthony@gmail.com
