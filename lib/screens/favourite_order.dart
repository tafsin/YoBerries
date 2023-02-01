import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:intl/intl.dart';
import 'package:yo_berry_2/payment_credentials.dart';

import '../functions.dart';
import 'package:http/http.dart' as http;

import '../widgets.dart';

class Favourite_order extends StatefulWidget {
  const Favourite_order({Key? key}) : super(key: key);

  @override
  State<Favourite_order> createState() => _Favourite_orderState();
}

class _Favourite_orderState extends State<Favourite_order> {
  String selectedPayementMethod = '';
  String trx_id = '';
  String OID = '';
  bool isPayCom = false;

  void initState() {
    super.initState();
    currentUser();
    //getCartItems();
  }

  String uid = '';

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // userEmail = currentUser.email;
      uid = currentUser.uid;
      print(currentUser.email);
    }
  }

  int point = 0;

  calRewardPoint(var total) async {
    if (total >= 100) {
      point = (total / 100).toInt();
    }
    print('point = $point');
    int preReward = 0;
    var pointCUid = FirebaseAuth.instance.currentUser?.uid;
    print("uid $uid");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(pointCUid)
        .get()
        .then((value) => {preReward = value['reward_point']});
    print('pre poind $preReward');
    point = point + preReward;
    print('after point $point');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(pointCUid)
        .update({'reward_point': point});
  }

  walletCal(var total, String storeId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      print(value['balance']);
      print('bbbbb');

      if (value['balance'] >= total) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'balance': value['balance'] - total});
        await FirebaseFirestore.instance.collection('payments').add({
          "amount": total.toString(),
          "customer_id": uid,
          "store_id": storeId,
          "transaction_id": transactionIdGenerator(),
          "transaction_time": DateTime.now(),
        });
        setState(() {
          isPayCom = true;
        });
      } else {
        errorAlert(context, 'Insufficient Balance');
        //Navigator.pop(context);
      }
    });
  }

  send_api_sms(String sms, String number) async {
    var response = await http.post(Uri.parse(
        "http://sms.felnadma.com/api/v1/send?api_key=44516430986385661643098638&contacts=$number&senderid=8801847431161&msg=$sms"));
    print('res ${response.statusCode}');
  }

  reOrder(DocumentSnapshot documentSnapshot) async {
    //
    DateTime orderDate = DateTime.now();
    String oDocId = '';
    String orderIdYear = DateFormat('yy').format(orderDate);
    String orderIdMonth = DateFormat('MM').format(orderDate);
    String orderIdDate = DateFormat('dd').format(orderDate);
    String orderIdHour = DateFormat.H().format(orderDate);
    String orderIdMin = DateFormat.m().format(orderDate);
    print("order Id Year $orderIdYear");
    print('order Id Month $orderIdMonth');
    print('order Id Date $orderIdDate');
    print('order Id Time $orderIdHour');
    print('order Id Time $orderIdMin');
    String orderId = '';

    final items = await FirebaseFirestore.instance
        .collection('order')
        .doc(documentSnapshot.id)
        .collection('order_items')
        .get();
    if (selectedPayementMethod == 'YoBerries Wallet') {
      await walletCal(documentSnapshot['total'], documentSnapshot['store_id']);
    }

    if (isPayCom == true) {
      setState(() {
        OID = documentSnapshot['countryCode'] +
            documentSnapshot['store_zipCode'] +
            orderIdYear +
            orderIdMonth +
            orderIdDate +
            orderIdHour +
            orderIdMin;
      });

      await FirebaseFirestore.instance.collection('order').add({
        'store_id': documentSnapshot['store_id'],
        'store_area': documentSnapshot['store_area'],
        'store_address': documentSnapshot['store_address'],
        'userEmail': documentSnapshot['userEmail'],
        'uid': documentSnapshot['uid'],
        'total': documentSnapshot['total'],
        'subTotal': documentSnapshot['subTotal'],
        'vat': documentSnapshot['vat'],
        'vatPercentage': documentSnapshot['vatPercentage'],
        'isComplete': false,
        'orderDate': DateFormat('dd-MM-yy').format(DateTime.now()),
        'orderDateTime': DateTime.now(),
        'OrderTime': DateFormat.Hms().format(DateTime.now()),
        'isFavourite': false,
        'discount': 0,
        'transaction_id': trx_id,
        'paymentMethod': selectedPayementMethod,
        'currency': documentSnapshot['currency'],
        'orderId': documentSnapshot['countryCode'] +
            documentSnapshot['store_zipCode'] +
            orderIdYear +
            orderIdMonth +
            orderIdDate +
            orderIdHour +
            orderIdMin
      }).then((value) => {
            items.docs.forEach((element) async {
              await FirebaseFirestore.instance
                  .collection('order')
                  .doc(value.id)
                  .collection('order_items')
                  .doc()
                  .set(element.data());
            })
          });
      await calRewardPoint(documentSnapshot['total']);
    }
  }

  setIsFavourite(String order_docId, bool fav) async {
    print('order Id $order_docId');

    print('fav $fav');

    Loader.show(context);
    await FirebaseFirestore.instance
        .collection('order')
        .doc(order_docId)
        .update({'isFavourite': fav});

    Loader.hide();
    setState(() {});
  }

  deleteFromFav(String orderId) async {
    String favId = '';
    await FirebaseFirestore.instance
        .collection('Favourite_Order')
        .where("order_id", isEqualTo: orderId)
        .get()
        .then((value) => {favId = value.docs.first.id});
    await FirebaseFirestore.instance
        .collection('Favourite_Order')
        .doc(favId)
        .delete();
    // print('')
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Favourite Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Favourite_Order')
            .where('customer_uid', isEqualTo: uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            //getStoreDetails(snapshot.data!.docs['store_id']);
            //print(snapshot.data!.docs[])
            print(snapshot.data!.size);
            return ListView(
              shrinkWrap: true,
              children: snapshot.data!.docs.map((document) {
                print(snapshot.data);
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('order')
                        .where('uid', isEqualTo: uid)
                        .where('isFavourite', isEqualTo: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Container(
                          height: 700,
                          child: ListView(
                            shrinkWrap: true,
                            children: snapshot.data!.docs.map((document) {
                              print(snapshot.data);
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          spreadRadius: 1,
                                          offset: Offset(0, 5)),
                                    ],
                                  ),
                                  child: Column(
                                    // mainAxisAlignment:
                                    // MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Row(
                                                //   children: [
                                                //     Text('OrderDate: ',style: TextStyle(color: Colors.purple,fontSize: 15,fontWeight: FontWeight.w600),),
                                                //     Text(document['orderDate'].toString()),
                                                //   ],
                                                // ),

                                                Text(
                                                  document['store_area'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),

                                                IconButton(
                                                    onPressed: () async {
                                                      await setIsFavourite(
                                                          document.id, false);
                                                      await deleteFromFav(
                                                          document.id);
                                                    },
                                                    icon: Icon(
                                                      Icons.favorite,
                                                      color: Colors.red,
                                                    ))
                                              ],
                                            ),
                                            Container(
                                              child: Text(
                                                'Order Items:',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.purple,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Container(
                                              child:
                                                  StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('order')
                                                    .doc(document.id)
                                                    .collection('order_items')
                                                    .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot) {
                                                  if (!snapshot.hasData) {
                                                    print('hh');
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  } else {
                                                    print(snapshot.data!.size);
                                                    return ListView(
                                                      // scrollDirection: Axis.horizontal,
                                                      shrinkWrap: true,
                                                      children: snapshot
                                                          .data!.docs
                                                          .map((document) {
                                                        return Container(
                                                            child: Text(
                                                          document['item_name'],
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54),
                                                        ));
                                                      }).toList(),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Row(
                                              children: [
                                                Text('Total: '),
                                                Text(
                                                  document['total'].toString(),
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                Text("Tk")
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  dateTimeFormatter(document[
                                                      'orderDateTime']),
                                                  style: TextStyle(
                                                      color: Colors.black38),
                                                ),
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary:
                                                                Colors.purple),
                                                    onPressed: () async {
                                                      String trx =
                                                          transactionIdGenerator();
                                                      return showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Select Payment Method'),
                                                              actions: [
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);
                                                                    setState(
                                                                        () {
                                                                      selectedPayementMethod =
                                                                          'YoBerries Wallet';
                                                                    });
                                                                    setState(
                                                                        () {
                                                                      trx_id =
                                                                          trx;
                                                                    });

                                                                    await reOrder(
                                                                        document);
                                                                    if (isPayCom ==
                                                                        true) {
                                                                      await send_api_sms(
                                                                          'Hello, Dear Customer. Your order has been successfully placed. Your order Id is $OID',
                                                                          '01766424191');
                                                                    }
                                                                    //asdasdas
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    child: Text(
                                                                      'Pay from YoBerries Wallet',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.purple),
                                                                    ),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);
                                                                    setState(
                                                                        () {
                                                                      selectedPayementMethod =
                                                                          'Mobile Banking/ Credit Card';
                                                                    });
                                                                    await sslCommerzCustomizedCall(
                                                                            double.parse(document['total']
                                                                                .toString()),
                                                                            trx)
                                                                        .then(
                                                                            (value) async {
                                                                      setState(
                                                                          () {
                                                                        trx_id =
                                                                            trx;
                                                                        isPayCom =
                                                                            true;
                                                                      });

                                                                      await reOrder(
                                                                          document);
                                                                      await send_api_sms(
                                                                          'Hello, Dear Customer. Your order has been successfully placed. Your order Id is $OID',
                                                                          '01766424191');
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    child: Text(
                                                                        'Pay Online',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.purple)),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                    },
                                                    child: Text('Re-Order'))
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
