import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:intl/intl.dart';
import 'package:yo_berry_2/functions.dart';
import 'package:yo_berry_2/screens/invioce.dart';

class Customer_Recent_Orders extends StatefulWidget {
  const Customer_Recent_Orders({Key? key}) : super(key: key);

  @override
  State<Customer_Recent_Orders> createState() => _Customer_Recent_OrdersState();
}

class _Customer_Recent_OrdersState extends State<Customer_Recent_Orders> {
  @override
  void initState() {
    super.initState();
    currentUser();
    //getCartItems();
  }

  String uid = '';

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      //userEmail = currentUser.email;
      uid = currentUser.uid;
      print(currentUser.email);
    }
  }

  // getRecentOrder()async{
  //   await FirebaseFirestore.instance.collection('order').where('uid',isEqualTo: uid).get().then((value) => {
  //
  //   });
  // }
  // getStoreDetails(var store_id)async{
  //
  // }
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

  addToFavourite(String order_docId, String customer_uid) async {
    await FirebaseFirestore.instance
        .collection('Favourite_Order')
        .doc()
        .set({"order_id": order_docId, 'customer_uid': customer_uid});
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

  reOrder(DocumentSnapshot documentSnapshot) async {
    //
    String oDocId = '';

    final items = await FirebaseFirestore.instance
        .collection('order')
        .doc(documentSnapshot.id)
        .collection('order_items')
        .get();

    await FirebaseFirestore.instance.collection('order').add({
      'store_id': documentSnapshot['store_id'],
      'store_area': documentSnapshot['store_area'],
      'userEmail': documentSnapshot['userEmail'],
      'uid': documentSnapshot['uid'],
      'total': documentSnapshot['total'],
      'isComplete': false,
      'orderDate': DateFormat('dd-MM-yy').format(DateTime.now()),
      'orderDateTime': DateTime.now(),
      'OrderTime': DateFormat.Hms().format(DateTime.now()),
      'isFavourite': false
    }).then((value) => {
          items.docs.forEach((element) async {
            // await FirebaseFirestore.instance.collection('order').doc(value.id).collection('order_items').add({
            //   'item_Image':element['itemImage'],
            //   'item_category': element['item_category'],
            //   'item_id': element['item_id'],
            //   'item_name': element['item_name'],
            //   'item_quantity': element['item_quantity'],
            //   'item_name': element['item_name'],
            //   'unit_price':element['unit_price'],
            //   'price': element['price'],
            //   if(element.data().containsKey('size')){
            //     'size':element[size];
            //   }
            //
            // });
            await FirebaseFirestore.instance
                .collection('order')
                .doc(value.id)
                .collection('order_items')
                .doc()
                .set(element.data());
          })
        });

    //await FirebaseFirestore.instance.collection('order').doc(oDocId).collection('order_items').doc().set();

    // DateTime orderDate = DateTime.now();
    // String orderFormatDate =
    // DateFormat('dd-MM-yy').format(orderDate);
    // String orderFormatTime =  DateFormat.Hms().format(orderDate);
    // Timestamp orderDateTime = Timestamp.fromDate(orderDate);
    // print(orderDate);
    // print(orderDateTime);
    // print(orderFormatDate);
    // print('Order Time $orderFormatTime');
    //
    // print('place order');
    // DocumentReference docref = await FirebaseFirestore.instance.collection('order').doc();
    // var id = docref.id;
    // print('document $id ');
    //
    // var total = 0;
    // var storeId ;
    // var uid;
    // var storeArea;
    // var userEmail;
    //
    // //NEEDS TO Changed
    //
    // await FirebaseFirestore.instance.collection('customer_cart').doc(orderId).get().then((value) async {
    //   total = value.data()!['total'];
    //   storeId = value.data()!['store_id'];
    //   uid = value.data()!['uid'];
    //   storeArea = value.data()!['storeArea'];
    //   userEmail = value.data()!['userEmail'];
    //   print(' doctotal is $total');
    //   print('store_id $storeId');
    //   print('uid is $uid');
    //
    //   //await FirebaseFirestore.instance.collection('customer_cart').doc(userEmail).collection('cart_items').get();
    // });
    // await FirebaseFirestore.instance.collection('order').doc(id).set({
    //   'store_id':storeId,
    //   'store_area': storeArea,
    //   'uid':uid,
    //   'userEmail': userEmail,
    //   'total': total,
    //   'isComplete': false,
    //   'orderDate': orderFormatDate,
    //   'orderDateTime': orderDate,
    //   'OrderTime': orderFormatTime,
    //   'isFavourite' : false
    // });
    // //await FirebaseFirestore.instance.collection('order').doc(id).set({details.data()});
    // final item = await FirebaseFirestore.instance.collection('order').doc(orderId).collection('order_items').get();
    // items.docs.forEach((element) async{
    //   await FirebaseFirestore.instance.collection('order').doc(id).collection('order_items').doc().set(element.data());
    // });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('RECENT ORDERS'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('order')
            .where('uid', isEqualTo: uid)
            .orderBy('orderDateTime', descending: false)
            .limitToLast(20)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            //print('hh');
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            //getStoreDetails(snapshot.data!.docs['store_id']);
            //print(snapshot.data!.docs[])
            print(snapshot.data!.size);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.reversed.map((document) {
                  print(snapshot.data);
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      //width: 80,
                      // height: 250,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),

                                    document['isFavourite']
                                        ? IconButton(
                                            onPressed: () async {
                                              await setIsFavourite(
                                                  document.id, false);
                                              await deleteFromFav(document.id);
                                            },
                                            icon: Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            ))
                                        : IconButton(
                                            onPressed: () async {
                                              print('add_to_fav');
                                              await setIsFavourite(
                                                  document.id, true);
                                              await addToFavourite(
                                                  document.id, uid);
                                            },
                                            icon: Icon(
                                              Icons.favorite_outline_rounded,
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
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('order')
                                        .doc(document.id)
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
                                        return ListView(
                                          // scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          children: snapshot.data!.docs
                                              .map((document) {
                                            return Container(
                                                child: Text(
                                              document['item_name'],
                                              style: TextStyle(
                                                  color: Colors.black54),
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
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text("Tk")
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    Text('Status: '),
                                    document['isComplete']
                                        ? Text(
                                            'Completed',
                                            style: TextStyle(
                                                color: Colors.lightGreen),
                                          )
                                        : Text(
                                            'Pending',
                                            style: TextStyle(color: Colors.red),
                                          )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateTimeFormatter(
                                          document['orderDateTime']),
                                      style: TextStyle(color: Colors.black38),
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.purple),
                                        onPressed: () async {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Invoice(document.id)));
                                        },
                                        child: Text('Invoice'))
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
  }
}
