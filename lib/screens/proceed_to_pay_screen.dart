import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:yo_berry_2/screens/cart_items.dart';
import 'package:yo_berry_2/screens/oder_now.dart';
import 'package:yo_berry_2/screens/welcome_page.dart';

import 'package:yo_berry_2/widgets.dart';

import '../payment_credentials.dart';
import 'package:http/http.dart' as http;

class Proceed_To_Pay extends StatefulWidget {
  // const Proceed_To_Pay({Key? key}) : super(key: key);
  final int total;
  final int vat;
  final int discount;
  final String pCodeId;
  final int vatPercen;

  const Proceed_To_Pay(
      this.total, this.vat, this.discount, this.pCodeId, this.vatPercen);

  @override
  State<Proceed_To_Pay> createState() => _Proceed_To_PayState();
}

class _Proceed_To_PayState extends State<Proceed_To_Pay> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String subTotalPrice = '';
  String? userEmail = "";
  int point = 0;
  String uid = '';
  String country = '';
  bool complete = false;
  String storeAddress = '';
  String storeArea = '';
  String storePhoneNum = '';
  String currency = '';
  String customerPhone = '';
  var selectedIndex;
  String selectedPaymentMethod = '';

  var paymentMethod = ['YoBerries Wallet', 'Mobile Banking/ Credit Card'];
  bool isPayChange = false;
  String OID = '';
  String SID = '';
  int initialIndex = 0;
  List<String> options = ['In Store', 'Pick Up'];
  late String selectedOption = options[0];
  String orderType = 'In Store';

  TextEditingController pickUpTime = TextEditingController();

  void initState() {
    super.initState();
    currentUser();
    getTotal();
    getPaymentMethod();
    getCurrentUserPhoneNum();
  }

  void dispose() {
    super.dispose();
    Loader.hide();
  }

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
      //uid = currentUser.uid;
      print(currentUser.email);
    }
  }

  getCurrentUserPhoneNum() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      customerPhone = value['userPhoneNumber'];
    });
  }

  void sending_SMS(String msg, List<String> list_receipents) async {
    String send_result =
        await sendSMS(message: msg, recipients: list_receipents)
            .catchError((err) {
      print(err);
    });
    print(send_result);
  }

  getTotal() async {
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .get()
        .then((value) {
      setState(() {
        subTotalPrice = value.data()!['subTotal'].toString();
        storeAddress = value['storeAddress'];
        SID = value['store_id'];
        storeArea = value['storeArea'];
        storePhoneNum = value['storePhoneNum'];
        currency = value['currency'];
      });
    });
  }

  getPaymentMethod() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        selectedPaymentMethod = value['defaultPaymentMethod'];
      });
    });
    print(selectedPaymentMethod);
  }

  calRewardPoint() async {
    if (widget.total >= 100) {
      point = (widget.total / 100).toInt();
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

  clearCart() async {
    // define document location (Collection Name > Document Name > Collection Name >)
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .collection("cart_items")
        .get()
        .then((value) async {
      for (DocumentSnapshot ds in value.docs) {
        await ds.reference.delete();
      }
    });

    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .delete();
  }

  send_api_sms(String sms, String number) async {
    var response = await http.post(Uri.parse(
        "http://sms.felnadma.com/api/v1/send?api_key=44516430986385661643098638&contacts=$number&senderid=8801847431161&msg=$sms"));
    print('res ${response.statusCode}');
  }

  walletCal() async {
    var storeId;
    var cUid;
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .get()
        .then((value) async {
      // subtotal = value.data()!['subTotal'];

      storeId = value.data()!['store_id'];
      cUid = value.data()!['uid'];
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cUid)
        .get()
        .then((value) async {
      print(value['balance']);
      print('bbbbb');

      if (value['balance'] >= widget.total) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cUid)
            .update({'balance': value['balance'] - widget.total});
        await FirebaseFirestore.instance.collection('payments').add({
          "amount": widget.total.toString(),
          "customer_id": uid,
          "store_id": storeId,
          "transaction_id": transactionIdGenerator(),
          "transaction_time": DateTime.now(),
        });
        setState(() {
          complete = true;
        });
      } else {
        errorAlert(context, 'Insufficient Balance');
        //Navigator.pop(context);
      }
    });
  }

  placeOrder(String trx) async {
    DateTime orderDate = DateTime.now();
    String orderFormatDate = DateFormat('dd-MM-yy').format(orderDate);
    String orderFormatTime = DateFormat.Hms().format(orderDate);
    Timestamp orderDateTime = Timestamp.fromDate(orderDate);
    print(orderDate);
    print(orderDateTime);
    print(orderFormatDate);
    print('Order Time $orderFormatTime');
    print(userEmail);
    print('place order');
    DocumentReference docref =
        await FirebaseFirestore.instance.collection('order').doc();
    var id = docref.id;
    print('document $id ');

    var storeId;
    // var uid;
    var storeArea;
    var storeAddress;
    var zipCode;
    var countryNameCode;

    //NEEDS TO Changed

    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .get()
        .then((value) async {
      // subtotal = value.data()!['subTotal'];
      try {
        storeId = value.data()!['store_id'];
        uid = value.data()!['uid'];
        storeArea = value.data()!['storeArea'];
        storeAddress = value['storeAddress'];
        zipCode = value.data()!['zipCode'];
        countryNameCode = value.data()!['countryNameCode'];
        setState(() {
          country = value['country'];
        });

        print('store_id $storeId');
        print('uid is $uid');
      } catch (e) {
        print(e);
      }

      //await FirebaseFirestore.instance.collection('customer_cart').doc(userEmail).collection('cart_items').get();
    });

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
    String orderId = countryNameCode +
        zipCode +
        orderIdYear +
        orderIdMonth +
        orderIdDate +
        orderIdHour +
        orderIdMin;

    print("ORDER ID $orderId");

    OID = orderId;

    await FirebaseFirestore.instance.collection('order').doc(id).set({
      'store_id': storeId,
      'subTotal': int.parse(subTotalPrice),
      'store_area': storeArea,
      'store_address': storeAddress,
      'store_zipCode': zipCode,
      'uid': uid,
      'userEmail': userEmail,
      'total': widget.total,
      'vat': widget.vat,
      'discount': widget.discount,
      'isComplete': false,
      'orderDate': orderFormatDate,
      'orderDateTime': orderDate,
      'OrderTime': orderFormatTime,
      'isFavourite': false,
      'transaction_id': trx,
      'orderId': orderId,
      'store_phone': storePhoneNum,
      'vatPercentage': widget.vatPercen,
      'currency': currency,
      'paymentMethod': selectedPaymentMethod,
      'countryCode': countryNameCode,
    });
    //await FirebaseFirestore.instance.collection('order').doc(id).set({details.data()});
    final items = await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .collection('cart_items')
        .get();
    items.docs.forEach((element) async {
      await FirebaseFirestore.instance
          .collection('order')
          .doc(id)
          .collection('order_items')
          .add(element.data())
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('order')
            .doc(id)
            .collection('order_items')
            .doc(value.id)
            .update({
          'store_id': storeId,
          'orderDateTime': orderDateTime,
        });
      });
    });
    if (isPayChange) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'defaultPaymentMethod': selectedPaymentMethod});
    }
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
            fontWeight: FontWeight.w500,
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

  sendNotificationToStore(String store_id) async {
    print(store_id);
    final endpoint = "https://fcm.googleapis.com/fcm/send";

    final header = {
      'Authorization':
          'key=AAAA3gbk_qA:APA91bEoU2IvOCI_fV8n938Q1fjITt6XKY4xYWkJoQcm7RfPIfmiCcrcl0GwSCM9iN2WRj5vJY3yCnzlqrv0ibZ8FP2MBW13qFQdmNdisOrvp-Du7Bkcjwqmj0tzzrDDUg8QS6HLtMlV',
      'Content-Type': 'application/json'
    };

    http.Response response = await http.post(Uri.parse(endpoint),
        headers: header,
        body: jsonEncode({
          "to": "/topics/$store_id",
          "priority": "high",
          "notification": {
            "body": "$OID is placed by a customer",
            "title": "YoBerries",
          }
        }));
    print(response.statusCode);
    print(response.body);
  }

  void showBottomSheetForNewAddress(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        elevation: 2,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext currentContext, StateSetter setState) {
            return Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: SizedBox(
                height: 200,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: pickUpTime,
                    //keyboardType: TextInputType.none,
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        hintText: 'Start Time',
                        hintStyle: TextStyle(fontSize: 14),
                        prefixIcon: Icon(Icons.access_time, size: 18),
                        filled: true,
                        //fillColor: MyColor.grayBackground,
                        border: InputBorder.none),
                    readOnly: true,
                    onTap: () {
                      DateTime? pickedDate;
                      DatePicker.showTimePicker(context,
                          currentTime: DateTime.now(), onChanged: (date) {
                        pickedDate = date;
                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat().add_Hm().format(pickedDate!);
                          setState(() {
                            pickUpTime.text = formattedDate;
                            // leaveStartDate = pickedDate;
                          });
                        } else {
                          setState(() {
                            pickUpTime.text = 'Please select a time!';
                          });
                        }
                      }, onConfirm: (date) {
                        pickedDate = date;
                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat().add_Hm().format(pickedDate!);
                          setState(() {
                            pickUpTime.text = formattedDate;
                            // leaveStartDate = pickedDate;
                          });
                        } else {
                          setState(() {
                            pickUpTime.text = 'Please select a time!';
                          });
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a time!';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            );
          });
        });
    print(pickUpTime.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Order Summary'),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: ListView(
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
            SizedBox(
              height: 10,
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customer_cart')
                  .doc(userEmail)
                  .collection('cart_items')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  //print('hh');
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
                          rows: createPendingRows(snapshot.data).cast<DataRow>(),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(' $currency',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
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
                            Text(widget.vatPercen.toString()),
                            Text('%)'),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              widget.vat.toString(),
                            ),
                            Text(' $currency')
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
                        Text('Discount:  '),
                        Row(
                          children: [
                            Text(
                              widget.discount.toString(),
                            ),
                            Text(' $currency')
                          ],
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
                            Text(widget.total.toString(),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(' $currency',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 300,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wallet_sharp,
                            color: Colors.purple,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Payment Method'),
                          Expanded(
                            child: SizedBox(
                              width: 5,
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Container(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: paymentMethod.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              leading: Radio<int>(
                                                value: index,
                                                groupValue: selectedIndex,
                                                //activeColor: Colors.purple,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedIndex = index;
                                                    print(
                                                        "selected index $selectedIndex");

                                                    selectedPaymentMethod =
                                                        paymentMethod[
                                                            selectedIndex];
                                                    isPayChange = true;
                                                    print(selectedIndex);
                                                    print(
                                                        'selected payment method $selectedPaymentMethod');
                                                  });

                                                  Navigator.pop(context);
                                                },
                                              ),
                                              title: Text(paymentMethod[index]),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.purple,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payments_sharp,
                            color: Colors.purple[200],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(selectedPaymentMethod,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
      bottomSheet: Container(
        margin: EdgeInsets.only(left: 18, bottom: 8),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: Size(350, 45)
                //minimumSize: (100.0,40)
                ),
            onPressed: () async {
              //'Mobile Banking/ Credit Card'
              if (selectedPaymentMethod == "YoBerries Wallet") {
                String trx = transactionIdGenerator();
                await walletCal();
                if (complete == true) {
                  showYoBerriesAlertDialog(context, trx);
                }
              } else {
                String trx = transactionIdGenerator();
                await sslCommerzCustomizedCall((widget.total).toDouble(), trx)
                    .then((value) async {
                  print('success');
                  await showAlertDialog(context, trx);
                });
              }
            },
            child: Text(
              'Proceed to Pay',
              style: TextStyle(fontSize: 15),
            )),
      ),
    );
  }

  showAlertDialog(BuildContext context, String trx) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.of(context).pop();

        Loader.show(context);
        await placeOrder(trx);
        print(SID);
        await sendNotificationToStore(SID);
        await calRewardPoint();
        await clearCart();
        Loader.hide();
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

         var sCountry = sharedPreferences.getString('country');
         var sUserName = sharedPreferences.getString('userName');
         var sUid = sharedPreferences.getString('uid');
         var sImgUrl = sharedPreferences.getString('imgUrl');


        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>Welcome_Page(sCountry, sUid, sUserName, sImgUrl),
          ),
              (route) => false,
        );

        await send_api_sms(
            'Hello, Dear Customer. Your order has been successfully placed. Your order Id is $OID',
            '01766424191');
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Success"),
      content: Text("Your payment successful."),
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

  showYoBerriesAlertDialog(BuildContext context, String trx) {
    // Create button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () async {
          Navigator.of(context).pop();

          Loader.show(context);

          await placeOrder(trx);
          await calRewardPoint();
          await clearCart();
          await send_api_sms(
              'Hello, Dear Customer. Your order has been successfully placed. Your order Id is $OID',
              '01766424191');
          await sendNotificationToStore(storeID);
          Loader.hide();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => CartItems(widget.vat,country),
            ),
                (route) => false,
          );
        });

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Success"),
      content: Text("Your payment successful."),
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
}
