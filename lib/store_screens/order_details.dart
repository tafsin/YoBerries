import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:yo_berry_2/store_screens/store_dashboard.dart';

class Order_Details extends StatefulWidget {
  //const Order_Details({Key? key}) : super(key: key);
  final String orderId;

  const Order_Details(this.orderId);

  @override
  State<Order_Details> createState() => _Order_DetailsState();
}

class _Order_DetailsState extends State<Order_Details> {
  String orderDate = '';
  String orderId = '';
  int total = 0;
  String oId = "";
  String currency = '';

  void initState() {
    super.initState();
    getOrderDetails();
  }

  getOrderDetails() async {
    oId = widget.orderId;
    await FirebaseFirestore.instance
        .collection('order')
        .doc(widget.orderId)
        .get()
        .then((value) => {
              setState(() {
                orderDate = value['orderDate'];
                total = value['total'];
                orderId = value['orderId'];
                currency = value['currency'];
              })
            });
  }

  completeOrder() async {
    await FirebaseFirestore.instance
        .collection('order')
        .doc(widget.orderId)
        .update({'isComplete': true});
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => Store_Dashboard()))
            .then((value) {
          Loader.show(context);
          setState(() {});
          Loader.hide();
        });
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Order Completed Successfully",
        style: TextStyle(color: Colors.purple),
      ),
      content: Text("You have completed the order"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text('Order Details'),
        ),
        body: Container(
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  height: MediaQuery.of(context).size.height - 100,
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          Text('Order#'),
                          Text(orderId),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Date:  $orderDate'),
                      //SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount:  $total $currency'),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.purple),
                              onPressed: () async {
                                await completeOrder();
                                showAlertDialog(context);
                              },
                              child: Text('Complete')),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        child: StreamBuilder<QuerySnapshot>(
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
                                height:
                                    MediaQuery.of(context).size.height - 140,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: snapshot.data!.docs.map((document) {
                                    print(snapshot.data);
                                    return Column(
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 100,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    // width:75,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: FittedBox(
                                                        child: Image.network(
                                                          document['itemImage'],
                                                          height: 60,
                                                          width: 60,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 8.0,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5, bottom: 5),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [

                                                            Text(
                                                                document[
                                                                    'item_name'],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                )),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        3.0),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                        'Item_Quantity: '),
                                                                    Text(
                                                                        document['item_quantity']
                                                                            .toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        )),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Price: ',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        document['price']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.purple,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  Text(
                                                    document['currency'],
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        //DottedLine(),
                                        Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Divider(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
