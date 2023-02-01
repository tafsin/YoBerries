import 'dart:io';

import 'package:flutter/services.dart';
//import 'package:open_document/open_document.dart';

import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> generateTable(String text) async {
    var dataFont = await rootBundle
        .load("assets/font/OpenSans-VariableFont_wdth,wght.ttf");
    var myFont = Font.ttf(dataFont);
    var myStyle = TextStyle(font: myFont);

    final pdf = Document();
    final headers = ['oderDate', 'orderId', 'storeBranch', 'total'];
    final data = [
      ['1', '2', '3', '4'],
      ['1', '2', '3', '4'],
      ['1', '2', '3', '4'],
      ['1', '2', '3', '4']
    ];

    pdf.addPage(Page(
        build: (context) =>
            //     Table.fromTextArray(
            //   headers:  headers,
            //   data: data
            //
            // )
            Text(text, style: myStyle)));
    return saveDocument(name: 'salesReport', pdf: pdf);
  }

  // Future<String> get _localPath async {
  //   final directory = await getApplicationDocumentsDirectory();
  //
  //   return directory.path;
  // }

  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();

    final dir = await directory.path;
    final file = File('$dir/$name');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    print('open doc $file');
    final url = file.path;
    print('open file method $url');
    await PDF().fromPath(url);

    //await OpenFile.open(url);
  }
}
