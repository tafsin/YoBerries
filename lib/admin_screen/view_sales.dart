import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:yo_berry_2/admin_screen/view_store_sales.dart';

class View_Sales extends StatefulWidget {
  //const View_Sales({Key? key}) : super(key: key);
  final String country;

  const View_Sales(this.country);

  @override
  State<View_Sales> createState() => _View_SalesState();
}

class _View_SalesState extends State<View_Sales> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  //getMenu();
                  //NavigationDrawer();

                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.purple,
                  size: 30,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Choose a Store First",
                    style: TextStyle(
                        color: Colors.purple,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
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
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: 80,
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
                                          height: 8.0,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              document['address'],
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            Text(', '),
                                            Text(
                                              document['zipCode'],
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4.0,
                                        ),
                                        SizedBox(
                                          height: 4.0,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              size: 20,
                                              color: Colors.purple,
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              document['storePhoneNum'],
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 15),
                                            ),
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
                                              builder: (context) =>
                                                  View_Store_Sales(
                                                      document.id,
                                                      document['areaName'],
                                                      document['zipCode'])));
                                    },
                                    child: Text(
                                      'View Sales',
                                      style: TextStyle(fontSize: 10.5),
                                    ),
                                  )
                                  // Icon(
                                  //   Icons.location_on,
                                  //   size: 40,
                                  //   color: Colors.purple,
                                  // )
                                ],
                              ),
                              DottedLine(),
                            ],
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
