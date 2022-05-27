# Flutter Chunk Upload

Hi,

We all face a lot of problems when it comes to uploading a large files to server using FLUTTER.
so I tried to help all by researching how to upload large files to server using FLUTTER and # Laravel(php) backend.

## Getting Started

### Add dependency

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
