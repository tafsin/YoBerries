import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:intl/intl.dart';
import 'package:yo_berry_2/payment_credentials.dart';
import 'package:yo_berry_2/screens/cart_items.dart';

import '../functions.dart';
import 'package:http/http.dart' as http;

import '../widgets.dart';

class Favourite_order_new extends StatefulWidget {
  //const Favourite_order_new({Key? key}) : super(key: key);
  final String? country;

  const Favourite_order_new(this.country);

  @override
  State<Favourite_order_new> createState() => _Favourite_order_newState();
}

class _Favourite_order_newState extends State<Favourite_order_new> {
  String selectedPayementMethod = '';
  String trx_id = '';
  String OID = '';
  bool isPayCom = false;
  String? userEmail = '';
  int subTotal = 0;
  var count;
  int vat = 0;
  int docSize = 0;

  void initState() {
    super.initState();
    currentUser();
    //getCartItems();
  }

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  String uid = '';

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // userEmail = currentUser.email;
      uid = currentUser.uid;
      userEmail = currentUser.email;
      print(currentUser.email);
    }
  }

  int point = 0;




  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = Row(
      children: [
        FlatButton(
          child: Text("No"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Return to Cart"),
          onPressed: () async {
            Navigator.of(context).pop();

            Navigator.push(context, MaterialPageRoute(builder: (context)=>CartItems(vat,widget.country)));

          },
        ),
        FlatButton(
          child: Text("Remove"),
          onPressed: () async {
            await clearCart();
            Navigator.of(context).pop();
          },
        ),

      ],
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Remove your Previous cart items?"),
      content: Text(
          "You still have products in your cart.\n Shall we start over a fresh cart?"),
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

  itemNotAvailableAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = Row(
      children: [
        FlatButton(
          // color: Colors.grey,
          child: Text("No"),
          onPressed: () async {
            await clearCart();
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          //color: Colors.purple,
          child: Text("Yes"),
          onPressed: () {
            Navigator.pop(context);

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CartItems(vat, widget.country)));
          },
        )
      ],
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Some Items are no longer available."),
      content: Text("Do you want to place order with rest items?"),
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

  bool complete = false;

  clearCart() async {
    Loader.show(context);
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

    Loader.hide();
  }

  Future cal(DocumentSnapshot documentSnapshot) async {
    int subt = 0;
    final items = await FirebaseFirestore.instance
        .collection('order')
        .doc(documentSnapshot.id)
        .collection('order_items')
        .get();
    setState(() {
      count = items.size;
      docSize = items.size;
    });

    for (var element in items.docs) {
      String item_id = element['item_id'];
      print(item_id);
      int quantity = element['item_quantity'];
      print(quantity);
      bool isMultiple = element['isMultiple'];
      print(isMultiple);
      String size = '';
      String item_name = '';
      String item_img = '';
      String item_category = '';
      String currency = '';
      var unit_price;
      int price = 0;
      Map<String, dynamic> sizeWithP = {};

      try {
        await FirebaseFirestore.instance
            .collection('country_menu')
            .doc(widget.country)
            .collection('menu')
            .doc(item_id)
            .get()
            .then((value) async {
          item_name = value['item_name'];
          item_img = value['itemImage'];
          item_category = value['item_category'];

          currency = value['currency'];
          if (isMultiple == true) {
            size = element['size'];
            sizeWithP = value['sizeWithPrice'];

            print(sizeWithP);
            print(sizeWithP[size]);
            unit_price = sizeWithP[size];

            if(unit_price != 0){
              price = unit_price * quantity;
              subt = subt + price;
            }
            else{
              count--;
            }
            print('cal priceeee $subt');
          }
          else {
            unit_price = value['price'];
          if(unit_price != 0){
            price = unit_price * quantity;
            subt = subt + price;
          }
            print('cal priceeee $subt');
          }
          if(unit_price != 0){
            if (value['isMultiple'] == true) {
              Loader.show(context);

              await FirebaseFirestore.instance
                  .collection('customer_cart')
                  .doc(userEmail)
                  .collection('cart_items')
                  .doc()
                  .set({
                'isMultiple': true,
                'price': price,
                'size': size,
                'unit_price': unit_price,
                'item_name': item_name,
                'itemImage': item_img,
                'item_quantity': quantity,
                'item_category': item_category,
                'item_id': item_id,
                'currency': currency
              });
              Loader.hide();
            }
            else {
              Loader.show(context);
              await FirebaseFirestore.instance
                  .collection('customer_cart')
                  .doc(userEmail)
                  .collection('cart_items')
                  .doc()
                  .set({
                'isMultiple': false,
                'price': price,
                'unit_price': unit_price,
                'item_name': item_name,
                'itemImage': item_img,
                'item_quantity': quantity,
                'item_category': item_category,
                'item_id': item_id,
                'currency': currency
              });
              Loader.hide();
            }
          }
        });
      } catch (e) {
        setState(() {
          count = count - 1;
        });
      }
    }
    ;

    print('com');

    return subt;
  }

  reOrder(DocumentSnapshot documentSnapshot) async {
    var itemId = [];
    setState(() {
      vat = documentSnapshot['vatPercentage'];
    });

    // items.docs.forEach((element) {
    //   itemId.add(element['item_id']);
    // });
    print('Item Id List $vat');

    await getOrSetTotal(documentSnapshot['userEmail']);
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .get()
        .then((value) async {
      try {
        if (value['subTotal'] > 0) {
          showAlertDialog(context);
        } else if (value['subTotal'] == 0) {
          Loader.show(context);
          var subtotal = await cal(documentSnapshot);
          Loader.hide();

          if (count != 0) {
            await FirebaseFirestore.instance
                .collection('customer_cart')
                .doc(userEmail)
                .update({
              'subTotal': subtotal,
              'uid': uid,
              'store_id': documentSnapshot['store_id'],
              'zipCode': documentSnapshot['store_zipCode'],
              'userEmail': userEmail,
              'isOrderPlaced': false,
              'storeAddress': documentSnapshot['store_address'],
              'storeArea': documentSnapshot['store_area'],
              'country': widget.country,
              'countryNameCode': documentSnapshot['countryCode'],
              'storePhoneNum': documentSnapshot['store_phone'],
              'currency': documentSnapshot['currency']
            });
          }
        }
      } catch (e) {
        print('ERRRORRRR $e');
      }
    });
  }

  getOrSetTotal(String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('customer_cart')
          .doc(email)
          .get()
          .then((value) => {
                setState(() {
                  subTotal = value['subTotal'];
                  // total = value[total];
                })
              });
    } catch (e) {
      await FirebaseFirestore.instance
          .collection('customer_cart')
          .doc(userEmail)
          .set({'subTotal': 0});
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
                        .orderBy('orderDateTime', descending: true)
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
                                                      Loader.show(context);
                                                      await reOrder(document);
                                                      Loader.hide();
                                                      if (count == docSize) {
                                                        print('docSize $docSize');
                                                        print('count $count');
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    CartItems(
                                                                        vat,
                                                                        widget
                                                                            .country)));
                                                      }
                                                      else if(count > 0 &&
                                                          count < docSize) {
                                                        itemNotAvailableAlertDialog(
                                                            context);
                                                      }
                                                      else {
                                                        errorAlert(context,
                                                            'Items are no longer available!');
                                                      }
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
