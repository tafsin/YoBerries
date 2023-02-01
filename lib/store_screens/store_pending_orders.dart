import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yo_berry_2/store_screens/order_details.dart';

class Store_Pending_Orders extends StatefulWidget {
  const Store_Pending_Orders({Key? key}) : super(key: key);

  @override
  State<Store_Pending_Orders> createState() => _Store_Pending_OrdersState();
}

class _Store_Pending_OrdersState extends State<Store_Pending_Orders> {
  String storeId = '2';
  String uid = '';

  void initState() {
    super.initState();
    currentUser();
    getStoreId();
  }

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      //userEmail = currentUser.email;
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
  }

  int count = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Pending Orders'),
      ),
      body: ListView(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('order')
                .where('store_id', isEqualTo: storeId)
                .where('isComplete', isEqualTo: false)
                .orderBy('OrderTime')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Container(
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((document) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 8, right: 8),
                      child: GestureDetector(
                        onTap: () {
                          String docId = document.id;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Order_Details(docId)));

                          //Navigator.push(context, MaterialPageRoute(builder: (context)=> AddToCart(docId,widget.storeId,widget.storeAddress,widget.storeArea,widget.itemCategory)));
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('Order#'),
                                    Text(document['orderDate']),

                                    //Text(document['OrderTime'])
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(document['OrderTime']),
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
    );
  }
}
