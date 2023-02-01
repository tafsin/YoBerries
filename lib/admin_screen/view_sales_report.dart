import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:intl/intl.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:yo_berry_2/pdf_viewer.dart';

class View_Sales_Report extends StatefulWidget {
  //const View_Sales_Report({Key? key}) : super(key: key);
  final String storeID;
  final String storeArea;
  final String storeAddress;
  final String storePhone;

  const View_Sales_Report(
      this.storeID, this.storeArea, this.storeAddress, this.storePhone);

  @override
  State<View_Sales_Report> createState() => _View_Sales_ReportState();
}

class _View_Sales_ReportState extends State<View_Sales_Report> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  TextEditingController from = TextEditingController();
  TextEditingController to = TextEditingController();
  late File file;
  late DateTime fromDateTime;
  late DateTime toDateTime;
  bool showTable = false;

  // List <Product> dataRow = [];
  List dataRowList = [];
  String orderId = '';
  String orderDate = '';
  String storeBranch = '';
  String total = '';
  String totalAmount = '';
  var headers = ['Order Date', "Order Id", 'StoreBranch', 'Total'];

  Future<void> createPDF() async {
    String rName = 'YoBerries';
    String fromRDate = from.text;
    String toRDate = to.text;
    String reportTime = 'Sales report from ' + fromRDate + ' to ' + toRDate;
    String totalAmountPdf = 'Total Amount: $totalAmount';
    //final Uint8List fontData = File('arial.ttf').readAsBytesSync();
//Create a PDF true type font object.
    //final PdfFont font = PdfTrueTypeFont(fontData, 12);
    //Create a PDF document.
    PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfLayoutResult layoutResult1 = PdfTextElement(
            text: rName,
            font: PdfStandardFont(PdfFontFamily.helvetica, 25,
                style: PdfFontStyle.bold),
            brush: PdfSolidBrush(PdfColor(106, 13, 173)))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(
                0, 0, page.getClientSize().width, page.getClientSize().height),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;
    final PdfLayoutResult layoutResult2 = PdfTextElement(
            text: widget.storeArea,
            font: PdfStandardFont(PdfFontFamily.helvetica, 20),
            brush: PdfSolidBrush(PdfColor(0, 0, 0)))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(
                0, 50, page.getClientSize().width, page.getClientSize().height),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;
    final PdfLayoutResult layoutResult3 = PdfTextElement(
            text: widget.storeAddress,
            font: PdfStandardFont(PdfFontFamily.helvetica, 16),
            brush: PdfSolidBrush(PdfColor(0, 0, 0)))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(
                0, 80, page.getClientSize().width, page.getClientSize().height),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;
    final PdfLayoutResult layoutResult4 = PdfTextElement(
            text: widget.storePhone,
            font: PdfStandardFont(PdfFontFamily.helvetica, 14),
            brush: PdfSolidBrush(PdfColor(106, 13, 173)))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(0, 100, page.getClientSize().width,
                page.getClientSize().height),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;
    final PdfLayoutResult layoutResult5 = PdfTextElement(
            text: reportTime,
            font: PdfStandardFont(PdfFontFamily.helvetica, 14,
                style: PdfFontStyle.underline),
            brush: PdfSolidBrush(PdfColor(0, 0, 0)))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(0, layoutResult4.bounds.bottom + 10,
                page.getClientSize().width, page.getClientSize().height),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;

// Create a PDF grid class to add tables.
    final PdfGrid grid = PdfGrid();
// Specify the grid column count.
    grid.columns.add(count: 3);
// Add a grid header row.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = 'Order Date';
    headerRow.cells[1].value = 'Order Id';

    headerRow.cells[2].value = 'Total';
// Set header font.
    headerRow.style.font =
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    dataRowList.forEach((element) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = element['orderDate'];
      row.cells[1].value = element['orderId'];

      row.cells[2].value = element['total'];
    });

// Set grid format.
    grid.style.cellPadding = PdfPaddings(left: 5, top: 5);
// Draw table in the PDF page.
    final PdfLayoutResult? layoutResultGrid = grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
            0, 200, page.getClientSize().width, page.getClientSize().height));
    final PdfLayoutResult layoutResult6 = PdfTextElement(
            text: totalAmountPdf,
            font: PdfStandardFont(PdfFontFamily.helvetica, 25,
                style: PdfFontStyle.bold),
            brush: PdfSolidBrush(PdfColor(0, 0, 0)))
        .draw(
            page: page,
            bounds: Rect.fromLTWH(0, layoutResultGrid!.bounds.bottom + 20,
                page.getClientSize().width, page.getClientSize().height),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;
    var bytes = await document.save();
    // Dispose the document

    Directory directory = (await getApplicationDocumentsDirectory());
//Get directory path
    String path = directory.path;
//Create an empty file to write PDF data
    file = File('$path/Sales_Report.pdf');
//Write PDF data
    await file.writeAsBytes(bytes, flush: true);
    print('done');
  }

  createData() async {
    dataRowList = [];
    final dataRow = await FirebaseFirestore.instance
        .collection('order')
        .where('store_id', isEqualTo: widget.storeID)
        .where('orderDateTime', isGreaterThanOrEqualTo: fromDateTime)
        .where('orderDateTime', isLessThanOrEqualTo: toDateTime)
        .get();
    int t = 0;
    String c = '';
    dataRow.docs.forEach((element) {
      Map dataList = {};
      dataList['orderDate'] = element['orderDate'];
      dataList['orderId'] = element['orderId'];
      //dataList['storeBranch'] = element['store_area'];
      dataList['total'] =
          element['total'].toString() + ' ' + element['currency'];
      t = t + int.parse(element['total'].toString());
      print(t);
      c = element['currency'];
      dataRowList.add(dataList);
    });
    totalAmount = t.toString();
    totalAmount = totalAmount + " " + c;

    print(dataRowList);
  }

  List<DataRow> createPendingRows(employeeLeave) {
    // print(employeeLeave['orderId']);
    List<DataRow> newRow = employeeLeave.docs
        .map<DataRow>((DocumentSnapshot docSubmissionSnapshot) {
      return DataRow(cells: [
        DataCell(Text(
          (docSubmissionSnapshot.data() as Map<String, dynamic>)['orderDate'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        )),
        DataCell(Center(
          child: Text(
            (docSubmissionSnapshot.data() as Map<String, dynamic>)['orderId']
                .toString(),
          ),
        )),
        DataCell(Center(
          child: Text(
            (docSubmissionSnapshot.data() as Map<String, dynamic>)['store_area']
                .toString(),
          ),
        )),
        DataCell(Row(
          children: [
            Row(
              children: [
                Text(
                  (docSubmissionSnapshot.data()
                          as Map<String, dynamic>)['total']
                      .toString(),
                ),
                SizedBox(
                  width: 2,
                ),
                Text(
                  (docSubmissionSnapshot.data()
                      as Map<String, dynamic>)['currency'],
                ),
              ],
            ),
          ],
        )),
      ]);
    }).toList();

    return newRow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Sales Report'),
      ),
      body: Container(
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text("From"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          height: 50,
                          width: 150,
                          // height: 110,
                          child: TextFormField(
                            controller: from,
                            decoration: InputDecoration(
                              labelText: "Pick a Date",
                              labelStyle: TextStyle(
                                fontSize: 12,
                                // fontWeight: FontWeight.w900,
                              ),
                              errorStyle: TextStyle(fontSize: 0),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                  borderRadius: BorderRadius.circular(10)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime.now());
                              if (pickedDate != null) {
                                print(pickedDate);
                                String formattedDate =
                                    DateFormat('dd-MM-yy').format(pickedDate);
                                print(formattedDate);
                                setState(() {
                                  from.text = formattedDate;
                                  fromDateTime = pickedDate;
                                  showTable = false;
                                });
                              }
                              // else {
                              //   setState(() {
                              //     from.text = 'select a date';
                              //   });
                              //   print('date is not selected');
                              // }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text("To"),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Container(
                          height: 50,
                          width: 150,
                          //height: 110,
                          child: TextFormField(
                            controller: to,
                            decoration: InputDecoration(
                              labelText: "Pick a Date",
                              labelStyle: TextStyle(
                                fontSize: 12,
                              ),
                              errorStyle: TextStyle(fontSize: 0),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                  borderRadius: BorderRadius.circular(10)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime.now());
                              if (pickedDate != null) {
                                print(pickedDate);
                                String formattedDate =
                                    DateFormat('dd-MM-yy').format(pickedDate);
                                print(formattedDate);
                                setState(() {
                                  to.text = formattedDate;
                                  toDateTime =
                                      pickedDate.add(Duration(days: 1));
                                  showTable = false;
                                });
                              }
                              // else {
                              //   setState(() {
                              //     to.text = 'select a date';
                              //   });
                              //   print('date is not selected');
                              // }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.purple),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  showTable = true;
                                });
                                await createData();

                              }
                            },
                            child: Text('Submit')),
                      ],
                    ),
                  )
                ],
              ),
            ),
            showTable
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('order')
                        .where('store_id', isEqualTo: widget.storeID)
                        .where('orderDateTime',
                            isGreaterThanOrEqualTo: fromDateTime)
                        .where('orderDateTime', isLessThanOrEqualTo: toDateTime)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        print(snapshot.data!.size);
                        return Container(
                          child: DataTable(
                            columnSpacing: 6.0,
                            columns: [
                              DataColumn(label: Text('Order\nDate')),
                              DataColumn(label: Text('Order Id')),
                              //DataColumn2(label: Text('Leave' '\nEnd' '\nDate')),
                              DataColumn(label: Text('Store_Branch')),
                              DataColumn(label: Text('Total')),
                            ],
                            rows: createPendingRows(snapshot.data)
                                .cast<DataRow>(),
                          ),
                        );
                      }
                    },
                  )
                : Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red[800],
        onPressed: () async {
          await createPDF();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PDFViewer(
                        file: file,
                      )));
          print('completed');
        },
        label: Text(
          "Generate PDF",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
