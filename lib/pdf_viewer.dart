import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewer extends StatelessWidget {
  final File file;

  const PDFViewer({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfPdfViewer.file(file),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red[800],
        onPressed: () async {
          try {
            await Share.shareFiles([file.path]);
          } on PlatformException catch (ex) {
            print(ex);
          } catch (ex) {
            print(ex);
          }
        },
        label: Text(
          "Save PDF",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
