import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import '../functions.dart';

class Invoice extends StatefulWidget {
  //const Invoice({Key? key}) : super(key: key);
  final String order_id;

  const Invoice(this.order_id);

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
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

  String? userEmail = "";
  String userName = '';
  String userPhoneNum = '';
  String currency = '';
  String paymentMethod = '';

  void currentUser() async {
    var currentUid;
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
      currentUid = currentUser.uid;
      print(currentUser.email);
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .get()
        .then((value) {
      userName = value['userName'];
      userPhoneNum = value['userPhoneNumber'];
    });
  }

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  getTotal() async {
    Loader.show(context);
    await FirebaseFirestore.instance
        .collection('order')
        .doc(widget.order_id)
        .get()
        .then((value) {
      print(widget.order_id);

      print(value.data()!['store_area']);

      subTotalPrice = value.data()!['subTotal'].toString();
      vat = value.data()!['vat'].toString();
      discount = value.data()!['discount'].toString();
      total = value.data()!['total'].toString();
      trx_id = value.data()!['transaction_id'];
      orderDate = value.data()!['orderDate'];
      orderTime = value.data()!['OrderTime'];
      storeArea = value.data()!['store_area'];
      storeAddress = value.data()!['store_address'];
      storePhoneNum = value['store_phone'];
      vatPercentage = value['vatPercentage'];
      currency = value['currency'];
      paymentMethod = value['paymentMethod'];
    });
    Loader.hide();

    print(subTotalPrice);
    print(vat);
    print(discount);
    print(total);

    print('s $storeArea');
    print('sD $storeAddress');
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
          child: Text(
            (docSubmissionSnapshot.data()
                    as Map<String, dynamic>)['item_quantity']
                .toString(),
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

  void initState() {
    super.initState();
    currentUser();
    //getTotal();
    //getCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Invoice'),
        backgroundColor: Colors.purple,
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
                  child: Row(
                    children: [
                      Text('Customer Name: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      Text('$userName'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Customer Phone: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('$userPhoneNum'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Pay Type: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      Text('Paid by $paymentMethod')
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('order')
                      .doc(widget.order_id)
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
                          child: FittedBox(
                            child: DataTable(
                              columnSpacing: 8.0,
                              columns: [
                                DataColumn(label: Text('Item')),
                                DataColumn(label: Text('Item\nQuantity')),
                                //DataColumn2(label: Text('Leave' '\nEnd' '\nDate')),
                                DataColumn(label: Text('unit price')),
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
    );
  }
}
