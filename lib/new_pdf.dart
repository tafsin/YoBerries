import 'dart:io';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class NewPdf {
  Future<void> createPDF() async {
    //Create a PDF document.
    var document = PdfDocument();
    //Add page and draw text to the page.
    document.pages.add().graphics.drawString(
        'Hello World!', PdfStandardFont(PdfFontFamily.helvetica, 18),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 0, 500, 30));
    //Save the document
    var bytes = await document.save();
    // Dispose the document
    document.dispose();
    Directory directory = (await getApplicationDocumentsDirectory())!;
//Get directory path
    String path = directory.path;
//Create an empty file to write PDF data
    File file = File('$path/Output.pdf');
//Write PDF data
    await file.writeAsBytes(bytes, flush: true);
  }

//Open the PDF document in mobile

}
