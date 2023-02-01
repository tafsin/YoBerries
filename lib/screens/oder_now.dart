import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yo_berry_2/screens/menu_screen.dart';
import 'package:yo_berry_2/screens/view_menu.dart';
import 'package:yo_berry_2/screens/welcome_page.dart';

class Order_Now extends StatefulWidget {
  // const Order_Now({Key? key}) : super(key: key);
  final String? country;

  const Order_Now(this.country);

  @override
  _Order_NowState createState() => _Order_NowState();
}

class _Order_NowState extends State<Order_Now> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Center(child: Text("Select Store")),
        automaticallyImplyLeading: false,

      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          // Row(
          //
          //   children: [
          //     IconButton(
          //       onPressed: () {
          //         //getMenu();
          //         //NavigationDrawer();
          //
          //         Navigator.pop(context);
          //       },
          //       icon: Icon(
          //         Icons.arrow_back,
          //         color: Colors.purple,
          //         size: 30,
          //       ),
          //     ),
          //     Expanded(
          //       child: Center(
          //         child: Text(
          //           "Select Store",
          //           style: TextStyle(
          //               color: Colors.purple,
          //               fontSize: 30,
          //               fontWeight: FontWeight.bold),
          //         ),
          //       ),
          //     ),
          //
          //   ],
          // ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('store_collection')
                  .where('country', isEqualTo: widget.country)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  print(snapshot.data!.size);
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((document) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        child: Material(
                          // decoration: BoxDecoration(
                          //     color: Colors.cyan[900],
                          //     border: Border.all(
                          //       color: Colors.green,
                          //       width: 4.0,
                          //     ),
                          //     borderRadius: BorderRadius.circular(5.0)),
                          child: SizedBox(
                            width: 80,
                            height: 130,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(document['areaName'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                document['address'],
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54),
                                              ),
                                              Text(', '),
                                              Text(
                                                document['zipCode'],
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                document['storePhoneNum'],
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 15),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  onPressed: () {
                                                    _makePhoneCall(document[
                                                        'storePhoneNum']);
                                                  },
                                                  icon: Icon(
                                                    Icons.phone_enabled,
                                                    color: Colors.purple,
                                                    size: 25,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.purple,
                                          minimumSize: Size(55, 35)),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => View_Menu(
                                                    document.id,
                                                    document['areaName'],
                                                    document['address'],
                                                    document['vat'],
                                                    widget.country,
                                                    document['storePhoneNum'],
                                                    document['zipCode'])));
                                      },
                                      child: Text(
                                        'Continue',
                                        style: TextStyle(fontSize: 10.5),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                DottedLine(),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
