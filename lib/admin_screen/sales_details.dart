import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../pdf_viewer.dart';

class Sales_details extends StatefulWidget {
  //const Sales_details({Key? key}) : super(key: key);
  final String orderId;

  const Sales_details(this.orderId);

  @override
  State<Sales_details> createState() => _Sales_detailsState();
}

class _Sales_detailsState extends State<Sales_details> {
  String subTotalPrice = '';
  String vat = '';
  String total = '';
  String discount = '';
  String orderDate = '';
  String orderTime = '';
  String trxTime = '';
  String trx_id = '';
  String trxDate = '';
  String storeArea = '';
  String storeAddress = '';
  String storePhoneNum = '';
  int vatPercentage = 0;
  String currency = '';
  String customerUid = '';
  String customerName = '';
  String customerPhone = '';
  String order_id = '';

  String? userEmail = "";
  late File file;
  List<Product> orderItemsRowList = [];
  var headers = ['Item', "Unit Price", 'Item_Quantity', 'Total'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  getTotal() async {
    print('total');
    Loader.show(context);
    await FirebaseFirestore.instance
        .collection('order')
        .doc(widget.orderId)
        .get()
        .then((value) async {
      print(value['vat']);

      subTotalPrice = value.data()!['subTotal'].toString();
      vat = value.data()!['vat'].toString();
      discount = value.data()!['discount'].toString();
      total = value.data()!['total'].toString();
      trx_id = value.data()!['transaction_id'];
      orderDate = value.data()!['orderDate'];
      orderTime = value.data()!['OrderTime'];
      orderTime = value.data()!['OrderTime'];
      storeArea = value.data()!['store_area'];
      storeAddress = value.data()!['store_address'];
      storePhoneNum = value['store_phone'];
      vatPercentage = value['vatPercentage'];
      currency = value['currency'];
      customerUid = value['uid'];
      order_id = value['orderId'];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(value['uid'])
          .get()
          .then((v) {
        //print(customerUid);
        print(v['uid']);
        print(v['userName']);
        customerName = v['userName'];
        customerPhone = v['userPhoneNumber'];
        // print(value['userPhoneNumber']);
        //
        // customerName = value['userName'];
        // customerPhone = value['userPhoneNumber'];
      });
    });
    Loader.hide();
  }

  generateTable() async {
    final pdf = pw.Document();
    // final image = (await rootBundle.load('assets/images/yo_berries_logo.png')).buffer.asUint8List();
    final data = orderItemsRowList
        .map((product) => [
              product.item_name,
              product.unit_price,
              product.i_quantity,
              product.i_total
            ])
        .toList();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: [
            //pw.Image(MemoryImage(image)),

            pw.Text('YoBerries',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(storeArea),
            pw.Text(storeAddress),
            pw.SizedBox(height: 20),
            pw.Row(children: [
              pw.Text("Store Phone Number: ",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(storePhoneNum),
            ]),
            pw.Row(children: [
              pw.Text("Invoice Number: ",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(trx_id)
            ]),
            pw.Row(children: [
              pw.Text('Customer Name: ',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('$customerName'),
            ]),

            pw.Row(children: [
              pw.Text('Customer Phone: ',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('$customerPhone'),
            ]),

            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 30),
            pw.Padding(
              padding: const pw.EdgeInsets.all(16.0),
              child: pw.Container(
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Subtotal:  ',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Row(
                          children: [
                            pw.Text('$subTotalPrice',
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(' $currency',
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold))
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('Vat: ('),
                            pw.Text(vatPercentage.toString()),
                            pw.Text('%)')
                          ],
                        ),
                        pw.Row(
                          children: [pw.Text(vat), pw.Text(' $currency')],
                        ),
                      ],
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Discount:  '),
                        pw.Row(
                          children: [pw.Text(discount), pw.Text(' $currency')],
                        ),
                      ],
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total:  ',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Row(
                          children: [
                            pw.Text(total,
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(' $currency',
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold))
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]); // Center
        }));
    var bytes = await pdf.save();
    // Dispose the document

    Directory directory = (await getApplicationDocumentsDirectory())!;
//Get directory path
    String path = directory.path;
//Create an empty file to write PDF data
    file = File('$path/Sales_Report.pdf');
//Write PDF data
    await file.writeAsBytes(bytes, flush: true);
    print('done');
  }

  List<DataRow> createPendingRows(employeeLeave) {
    print(employeeLeave);
    print('test1');
    List<DataRow> newRow = employeeLeave.docs
        .map<DataRow>((DocumentSnapshot docSubmissionSnapshot) {
      return DataRow(cells: [
        DataCell(Text(
          (docSubmissionSnapshot.data() as Map<String, dynamic>)['item_name'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        )),
        DataCell(Center(
          child: Row(
            children: [
              Text(
                (docSubmissionSnapshot.data()
                        as Map<String, dynamic>)['unit_price']
                    .toString(),
              ),
              SizedBox(
                width: 3,
              ),
              Text(
                (docSubmissionSnapshot.data()
                    as Map<String, dynamic>)['currency'],
              ),
            ],
          ),
        )),
        DataCell(Center(
          child: Text(
            (docSubmissionSnapshot.data()
                    as Map<String, dynamic>)['item_quantity']
                .toString(),
          ),
        )),
        DataCell(Row(
          children: [
            Text(
              (docSubmissionSnapshot.data() as Map<String, dynamic>)['price']
                  .toString(),
            ),
            SizedBox(
              width: 3,
            ),
            Text(
              (docSubmissionSnapshot.data()
                  as Map<String, dynamic>)['currency'],
            ),
          ],
        )),
      ]);
    }).toList();
    return newRow;
  }

  createData() async {
    orderItemsRowList = [];
    print('create Data');
    final orderItemsDetials = await FirebaseFirestore.instance
        .collection('order')
        .doc(widget.orderId)
        .collection('order_items')
        .get();
    orderItemsDetials.docs.forEach((element) {
      String itemName = element['item_name'];
      String unitPrice = element['unit_price'].toString();
      String quantity = element['item_quantity'].toString();
      String total = element['price'].toString() + ' ' + element['currency'];

      orderItemsRowList.add(Product(itemName, unitPrice, quantity, total));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Sale Details'),
      ),
      body: FutureBuilder(
          future: getTotal(),
          builder: (context, stream) {
            return ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Yo",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple)),
                      Text('Berries',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent))
                    ],
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '$storeArea',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$storeAddress',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '$storePhoneNum',
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Icon(
                        Icons.phone_enabled,
                        size: 20,
                        color: Colors.blue,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Row(
                      children: [
                        Text('Order# ',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple)),
                        Text(
                          order_id,
                          style: TextStyle(color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Row(
                      children: [
                        Text('Invoice Number: ',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple)),
                        Text(
                          trx_id,
                          style: TextStyle(color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        orderTime,
                        style: TextStyle(color: Colors.black38),
                      ),
                      Text(', '),
                      Text(
                        orderDate,
                        style: TextStyle(color: Colors.black38),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Customer Name: $customerName'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Customer Phone: $customerPhone'),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('order')
                      .doc(widget.orderId)
                      .collection('order_items')
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: FittedBox
                            (
                            child: DataTable(
                              columnSpacing: 8.0,
                              columns: [
                                DataColumn(label: Text('Item')),
                                DataColumn(label: Text('unit price')),
                                DataColumn(label: Text('Item\nQuantity')),
                                DataColumn(label: Text('price')),
                              ],
                              rows:
                                  createPendingRows(snapshot.data).cast<DataRow>(),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal:  ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text('$subTotalPrice',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text(' $currency',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('Vat: ('),
                                Text(vatPercentage.toString()),
                                Text('%)')
                              ],
                            ),
                            Row(
                              children: [Text(vat), Text(' $currency')],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Discount:  '),
                            Row(
                              children: [Text(discount), Text(' $currency')],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:  ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(total,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text(' $currency',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red[800],
        onPressed: () async {
          await createData();
          await generateTable();
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

class Product {
  final dynamic item_name;
  final dynamic unit_price;
  final dynamic i_quantity;
  final dynamic i_total;

  Product(this.item_name, this.unit_price, this.i_quantity, this.i_total);
}
