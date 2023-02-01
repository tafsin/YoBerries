import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:yo_berry_2/screens/login_screen.dart';
import 'package:yo_berry_2/store_screens/store_dahsboard_menu.dart';
import 'package:yo_berry_2/store_screens/store_pending_orders.dart';
import 'package:yo_berry_2/store_screens/store_qr_payment.dart';
import 'package:yo_berry_2/store_screens/store_qr_payment_scanner_new.dart';
import 'package:yo_berry_2/store_screens/store_sales.dart';
import 'package:yo_berry_2/store_screens/store_sales_report.dart';

import '../local_notifi.dart';
import 'order_details.dart';

class Store_Dashboard extends StatefulWidget {
  const Store_Dashboard({Key? key}) : super(key: key);

  @override
  State<Store_Dashboard> createState() => _Store_DashboardState();
}

class _Store_DashboardState extends State<Store_Dashboard> {
  String areaName = '';
  String address = '';
  String phoneNumber = '';
  String? uid = '';
  String? userEmail = '';
  String storeId = '';
  int count = 0;
  String orderCount = '';
  String country = '';
  late Future pendingFuture;

  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser();

    getStoreId();

    LocalNotificationService.initialize(context);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print(message.data);
        print(message.notification!.title);
        print(message.notification!.body);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Ok it dose not work");
        print(message.data);
        print(message.notification!.title);
        print(message.notification!.body);

        LocalNotificationService.display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        print(message.data);
        print(message.notification!.title);
        print(message.notification!.body);

        final routeName = message.data['route'];
        print(routeName);
        Navigator.of(context).pushNamed(routeName);
      }
    });
  }

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
      uid = currentUser.uid;
      print(currentUser.email);
    }
  }

  getStoreId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) => {
              setState(() {
                storeId = value['store_id'];
              })
            });
    print(storeId);
    await getAreaDetails();
    // await getSize();
  }

  getAreaDetails() async {
    final user = await FirebaseFirestore.instance
        .collection('store_collection')
        .doc(storeId)
        .get();
    try {
      if (user != null) {
        setState(() {
          areaName = user['areaName'];
          address = user['address'];
          phoneNumber = user['storePhoneNum'];
          country = user['country'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut().then((value) async {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(storeId);
    }).then((value){
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => Login_Page()), (route) => false);
    });

  }

  getSize() async {
    print('get size');
    String sid = '';
    // Loader.show(context);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      sid = value['store_id'];
      await FirebaseFirestore.instance
          .collection('order')
          .where('store_id', isEqualTo: sid)
          .where('isComplete', isEqualTo: false)
          .get()
          .then((value) => {count = value.size});
      // Loader.hide();
      print('count $count');
      orderCount = count.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('$areaName'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            ListTile(
              title: Text(
                'Scan Payment',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Store_Payment_Scanner_New()));
              },
            ),
            ListTile(
              title: Text(
                'View Sales',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Store_Sales(storeId, areaName)));
              },
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: Text(
                'View Menu',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Store_Dashboard_Menu(storeId, country)));
              },
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: Text(
                'Sales Report',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Store_Sales_Report(
                            storeId, areaName, address, phoneNumber)));
              },
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: Text(
                'Log out',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              onTap: () async {
                await FirebaseMessaging.instance
                    .unsubscribeFromTopic("$storeId");
                _signOut();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: getSize(),
            builder: (context, stream) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Pending Orders',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' ($orderCount)',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('order')
                              .where('store_id', isEqualTo: storeId)
                              .where('isComplete', isEqualTo: false)
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
                              height: MediaQuery.of(context).size.height - 30,
                              child: ListView(
                                shrinkWrap: true,
                                children: snapshot.data!.docs.map((document) {
                                  //getSize(snapshot.data!.size.toString());
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, left: 8, right: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        String docId = document.id;
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Order_Details(docId)));

                                        //Navigator.push(context, MaterialPageRoute(builder: (context)=> AddToCart(docId,widget.storeId,widget.storeAddress,widget.storeArea,widget.itemCategory)));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('Order#'),
                                                    Text(document['orderId']),

                                                    //Text(document['OrderTime'])
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Text(
                                                      document['OrderTime']),
                                                )
                                              ],
                                            ),
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
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
