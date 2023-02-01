import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:yo_berry_2/admin_screen/sales_details.dart';

class View_Store_Sales extends StatefulWidget {
  //const View_Store_Sales({Key? key}) : super(key: key);
  final String storeId;
  final String storeArea;
  final String zipCode;

  const View_Store_Sales(this.storeId, this.storeArea, this.zipCode);

  @override
  State<View_Store_Sales> createState() => _View_Store_SalesState();
}

class _View_Store_SalesState extends State<View_Store_Sales> {
  //today = new DateTime(today.year, today.month, today.day);
  late String todayF;
  late DateTime firstDayOfCurrentMonth;
  late DateTime lastWeek;
  late DateTime today;
  late DateTime lastMonth;
  late DateTime todayIN;
  TextEditingController from = TextEditingController();
  TextEditingController to = TextEditingController();
  late DateTime fromDateTime;
  late DateTime toDateTime;
  bool showTable = false;
  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    getDate();
  }

  getDate() {
    today = DateTime.now();
    todayF = DateFormat('dd-MM-yy').format(today);
    todayIN = DateTime.utc(today.year, today.month, today.day);
    lastWeek = DateTime.utc(today.year, today.month, today.day - 7);
    //lastMonth = DateTime.utc(today.year,today.month-1,today.day);
    firstDayOfCurrentMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    lastMonth = DateTime.utc(firstDayOfCurrentMonth.year,
        firstDayOfCurrentMonth.month - 1, firstDayOfCurrentMonth.day);
    print('lastWeek $lastWeek');
    print('lastMonth $lastMonth');
  }

  // List<DataRow> createPendingRows(employeeLeave) {
  //   print(employeeLeave);
  //   print('test1');
  //   List<DataRow> newRow = employeeLeave.docs
  //       .map<DataRow>((DocumentSnapshot docSubmissionSnapshot) {
  //     return DataRow(cells: [
  //       DataCell(Text(
  //         (docSubmissionSnapshot.data() as Map<String, dynamic>)['orderDate'],
  //         style: TextStyle(
  //           fontWeight: FontWeight.w600,
  //         ),
  //       )),
  //       DataCell(Center(
  //         child: Text(
  //           (docSubmissionSnapshot.data()
  //           as Map<String, dynamic>)['orderId'].toString(),
  //         ),
  //       )),
  //
  //       DataCell(Center(
  //         child: Text(
  //           (docSubmissionSnapshot.data()
  //           as Map<String, dynamic>)['store_area'].toString(),
  //         ),
  //       )),
  //       DataCell(Row(
  //         children: [
  //           Text(
  //             (docSubmissionSnapshot.data() as Map<String, dynamic>)['total'].toString(),
  //           ),
  //
  //
  //         ],
  //       )),
  //     ]);
  //   }).toList();
  //   return newRow;
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Row(
            children: [Text(widget.storeArea), Text(' Sales')],
          ),
          bottom: TabBar(
            tabs: [
              Text('Today'),
              Text('Last Week'),
              Text('Last Month'),
              Text('All'),
              Text('Filter by Date')
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('order')
                      .where('store_id', isEqualTo: widget.storeId)
                      .where('isComplete', isEqualTo: true)
                      .where('orderDate', isEqualTo: todayF)
                      .orderBy('orderDateTime', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((document) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 8, right: 8),
                            child: Container(
                              height: 80,
                              //width: 200,
                              decoration: BoxDecoration(
                                  //\color: Colors.cyan[900],
                                  color: Colors.white,
                                  // border: Border.all(
                                  //   color: Colors.purple,
                                  //   width: 4.0,
                                  // ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 10.0,
                                        spreadRadius: 1,
                                        offset: Offset(0, 5)),
                                  ],
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, top: 5, bottom: 5, right: 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Order#'),
                                                Text(document['orderId'],
                                                    style: TextStyle(
                                                        color: Colors.purple)),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  document['orderDate'],
                                                  style: TextStyle(
                                                      color: Colors.black54),
                                                ),
                                                Text(', '),
                                                Text(
                                                  document['OrderTime'],
                                                  style: TextStyle(
                                                      color: Colors.purple),
                                                )
                                              ],
                                            ),

                                            //Text(document['OrderTime'])
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.purple),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Sales_details(
                                                            document.id)));
                                          },
                                          child: Text('Details')),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('order')
                      .where('store_id', isEqualTo: widget.storeId)
                      .where('isComplete', isEqualTo: true)
                      .where('orderDateTime', isGreaterThanOrEqualTo: lastWeek)
                      .where('orderDateTime', isLessThan: today)
                      .orderBy('orderDateTime', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((document) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 8, right: 8),
                            child: Container(
                              height: 80,
                              //width: 200,
                              decoration: BoxDecoration(
                                  //\color: Colors.cyan[900],
                                  color: Colors.white,
                                  // border: Border.all(
                                  //   color: Colors.purple,
                                  //   width: 4.0,
                                  // ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 10.0,
                                        spreadRadius: 1,
                                        offset: Offset(0, 5)),
                                  ],
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, top: 5, bottom: 5, right: 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Order#'),
                                                Text(document['orderId'],
                                                    style: TextStyle(
                                                        color: Colors.purple)),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  document['orderDate'],
                                                  style: TextStyle(
                                                      color: Colors.black54),
                                                ),
                                                Text(', '),
                                                Text(
                                                  document['OrderTime'],
                                                  style: TextStyle(
                                                      color: Colors.purple),
                                                )
                                              ],
                                            ),

                                            //Text(document['OrderTime'])
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.purple),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Sales_details(
                                                            document.id)));
                                          },
                                          child: Text('Details')),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('order')
                      .where('store_id', isEqualTo: widget.storeId)
                      .where('isComplete', isEqualTo: true)
                      .where('orderDateTime', isGreaterThanOrEqualTo: lastMonth)
                      .where('orderDateTime',
                          isLessThan: firstDayOfCurrentMonth)
                      .orderBy('orderDateTime', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((document) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 8, right: 8),
                            child: Container(
                              height: 80,
                              //width: 200,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 10.0,
                                        spreadRadius: 1,
                                        offset: Offset(0, 5)),
                                  ],
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, top: 5, bottom: 5, right: 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Order#'),
                                                Text(document['orderId'],
                                                    style: TextStyle(
                                                        color: Colors.purple)),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  document['orderDate'],
                                                  style: TextStyle(
                                                      color: Colors.black54),
                                                ),
                                                Text(', '),
                                                Text(
                                                  document['OrderTime'],
                                                  style: TextStyle(
                                                      color: Colors.purple),
                                                )
                                              ],
                                            ),

                                            //Text(document['OrderTime'])
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.purple),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Sales_details(
                                                            document.id)));
                                          },
                                          child: Text('Details')),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('order')
                      .where('store_id', isEqualTo: widget.storeId)
                      .where('isComplete', isEqualTo: true)
                      .orderBy('orderDateTime', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((document) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 8, right: 8),
                            child: GestureDetector(
                              onTap: () {
                                String docId = document.id;
                                //Navigator.push(context, MaterialPageRoute(builder: (context)=> Order_Details(docId)));
                              },
                              child: Container(
                                height: 80,
                                //width: 200,
                                decoration: BoxDecoration(
                                    //\color: Colors.cyan[900],
                                    color: Colors.white,
                                    // border: Border.all(
                                    //   color: Colors.purple,
                                    //   width: 4.0,
                                    // ),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 10.0,
                                          spreadRadius: 1,
                                          offset: Offset(0, 5)),
                                    ],
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, top: 5, bottom: 5, right: 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text('Order#'),
                                                  Text(document['orderId'],
                                                      style: TextStyle(
                                                          color:
                                                              Colors.purple)),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    document['orderDate'],
                                                    style: TextStyle(
                                                        color: Colors.black54),
                                                  ),
                                                  Text(', '),
                                                  Text(
                                                    document['OrderTime'],
                                                    style: TextStyle(
                                                        color: Colors.purple),
                                                  )
                                                ],
                                              ),

                                              //Text(document['OrderTime'])
                                            ],
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.purple),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Sales_details(
                                                              document.id)));
                                            },
                                            child: Text('Details')),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
            ListView(
              physics: AlwaysScrollableScrollPhysics(),
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
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
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
                                        DateFormat('dd-MM-yy')
                                            .format(pickedDate);
                                    print(formattedDate);
                                    setState(() {
                                      from.text = formattedDate;
                                      fromDateTime = DateTime.utc(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day);
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
                            width: 10.0,
                          ),
                          Text("To"),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
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
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
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
                                        DateFormat('dd-MM-yy')
                                            .format(pickedDate);
                                    print(formattedDate);
                                    setState(() {
                                      to.text = formattedDate;
                                      toDateTime =
                                          pickedDate.add(Duration(days: 1));
                                      print('to $toDateTime');
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
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                showTable = true;
                              });
                            }
                            else{
                              print('date');
                            }
                          },
                          child: Text('Submit'))
                    ],
                  ),
                ),
                showTable == true
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('order')
                            .where('store_id', isEqualTo: widget.storeId)
                            .where('isComplete', isEqualTo: true)
                            .where('orderDateTime',
                                isGreaterThanOrEqualTo:
                                    Timestamp.fromDate(fromDateTime))
                            .where('orderDateTime',
                                isLessThanOrEqualTo:
                                    Timestamp.fromDate(toDateTime))
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
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                children: snapshot.data!.docs.map((document) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, left: 8, right: 8),
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 10.0,
                                                spreadRadius: 1,
                                                offset: Offset(0, 5)),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            top: 5,
                                            bottom: 5,
                                            right: 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Order#'),
                                                        Text(
                                                            document['orderId'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .purple)),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),

                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          document['orderDate'],
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                        Text(', '),
                                                        Text(
                                                          document['OrderTime'],
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .purple),
                                                        )
                                                      ],
                                                    ),

                                                    //Text(document['OrderTime'])
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary:
                                                              Colors.purple),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Sales_details(
                                                                    document
                                                                        .id)));
                                                  },
                                                  child: Text('Details')),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      )
                    : Container()
              ],
            )
          ],
        ),
      ),
    );
  }
}
