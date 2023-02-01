import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:intl/intl.dart';
import 'package:yo_berry_2/screens/oder_now.dart';
import 'package:yo_berry_2/screens/proceed_to_pay_screen.dart';

class CartItems extends StatefulWidget {
  // final int initialPrice ;
  // const CartItems(this.initialPrice);
  // const CartItems({Key? key}) : super(key: key);
  final int vat;
  final String? country;

  const CartItems(this.vat, this.country);

  @override
  State<CartItems> createState() => _CartItemsState();
}

class _CartItemsState extends State<CartItems> {
  TextEditingController promo = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  String? userEmail;

  void initState() {
    super.initState();
    currentUser();
    getTotal();
    getDate();
  }

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
    }
  }

  String subTotalPrice = '';
  int subtotal = 0;
  int total = 0;
  int calVat = 0;
  int discount = 0;
  String pCode = '';
  String currency = '';

  getTotal() async {
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .get()
        .then((value) {
      setState(() {
        subtotal = value['subTotal'];
        subTotalPrice = value['subTotal'].toString();
        currency = value['currency'];
      });
    });
    setState(() {
      calVat = (subtotal * (widget.vat / 100)).toInt();
      total = subtotal + calVat;
    });
    // print('cal Vat $calVat');
    //  print('total after vat added $total');
  }

  String todayF = '';
  late DateTime today;
  late Timestamp todayTimeSt;

  getDate() {
    today = DateTime.now().subtract(Duration(days: 1));
    todayF = DateFormat('dd-MM-yy').format(today);
    todayTimeSt = Timestamp.fromDate(today);
    print('today time stamp $todayTimeSt');
  }

  //&& ((element['expiryDate'].compareTo(todayTimeSt)== 0) ||(element['expiryDate'].compareTo(todayTimeSt) > 0))
  calPromo(String promoVoucher) async {
    bool voucherMatched = false;
    var selectedOption;
    print(widget.country);
    // print('Apply Promo $promoVoucher');
    await FirebaseFirestore.instance
        .collection('promo')
        .doc(widget.country)
        .collection('promo_codes')
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        if (element['expiryDate'].compareTo(todayTimeSt) == 0) {
          print('date same');
        } else if (element['expiryDate'].compareTo(todayTimeSt) > 0) {
          print('after');
        } else if (element['expiryDate'].compareTo(todayTimeSt) < 0) {
          print('before');
        }
        // print(element['code']);
        if (element['code'] == promoVoucher) {
          if (pCode == '' || pCode != element['code']) {
            if (element['isActive'] == true &&
                element['minimumPurchase'] <= total &&
                element['quantity'] > 0 &&
                element['expiryDate'].compareTo(todayTimeSt) > 0) {
              voucherMatched = true;
              pCode = element['code'];
              selectedOption = element['selectedOption'];
              print('pCode');
              print(selectedOption);
              Loader.show(context);
              if (selectedOption == 'fixed amount') {
                setState(() {
                  total = total - int.parse(element['discount'].toString());
                  discount = element['discount'];
                });
              }
              if (selectedOption == 'fixed percentage') {
                var percentage =
                    ((int.parse(element['discount'].toString()) / 100) * total)
                        .toInt();
                print(percentage);
                setState(() {
                  total = total - percentage;
                  discount = percentage;
                });
              }

              Loader.hide();
              successVoucherAlertDialog(context);
              // print('calPromo $total');
              // print('calPromo $discount');
            }
          } else {
            voucherMatched = true;
            showAlertDialog(context);
          }
        }
      });
      if (voucherMatched == false) {
        incorrectVoucherAlertDialog(context);
      }
    });
  }

  successVoucherAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Success!"),
      content: Text("Voucher applied"),
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

  incorrectVoucherAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Sorry!"),
      content: Text("Invalid voucher."),
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

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Sorry!"),
      content: Text("Voucher already applied."),
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

  Future subQuantity(int quantity, int unitPrice, var docId) async {
    if (quantity > 0) {
      if (quantity == 1) {
        int subTotalP = int.parse(subTotalPrice);
        subTotalP = subTotalP - unitPrice;

        setState(() {
          subTotalPrice = subTotalP.toString();
          calVat = (subTotalP * (widget.vat / 100)).toInt();
          total = subTotalP + calVat;
        });
        Loader.show(context);
        await FirebaseFirestore.instance
            .collection('customer_cart')
            .doc(userEmail)
            .collection('cart_items')
            .doc(docId)
            .delete();
        Loader.hide();
        Loader.show(context);
        await FirebaseFirestore.instance
            .collection('customer_cart')
            .doc(userEmail)
            .update({'subTotal': subTotalP});
        Loader.hide();

        if (subTotalP == 0) {
          await FirebaseFirestore.instance
              .collection('customer_cart')
              .doc(userEmail)
              .delete();
        }
      } else {
        quantity = quantity - 1;

        int subTotalP = int.parse(subTotalPrice);
        //  print('before $subTotalP');
        subTotalP = subTotalP - unitPrice;
        subTotalPrice = subTotalP.toString();
        setState(() {
          calVat = (subTotalP * (widget.vat / 100)).toInt();
          total = subTotalP + calVat;
        });
        // print('after $subTotalP');
        await FirebaseFirestore.instance
            .collection('customer_cart')
            .doc(userEmail)
            .update({'subTotal': subTotalP});
        int calculatedPrice = unitPrice * quantity;

        await FirebaseFirestore.instance
            .collection('customer_cart')
            .doc(userEmail)
            .collection('cart_items')
            .doc(docId)
            .update({'item_quantity': quantity, 'price': calculatedPrice});
      }
    }
  }

  Future addQuantity(int quantity, int unitPrice, var docId) async {
    quantity = quantity + 1;
    int calculatedPrice = unitPrice * quantity;
    Loader.show(context);
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .collection('cart_items')
        .doc(docId)
        .update({'item_quantity': quantity, 'price': calculatedPrice}).then(
            (value) async {
      int subTotalP = int.parse(subTotalPrice);
      // print('before $subTotalP');
      subTotalP = subTotalP + unitPrice;
      subTotalPrice = subTotalP.toString();
      setState(() {
        calVat = (subTotalP * (widget.vat / 100)).toInt();
        total = subTotalP + calVat;
      });

      // print('after $subTotalP');
      Loader.show(context);
      await FirebaseFirestore.instance
          .collection('customer_cart')
          .doc(userEmail)
          .update({'subTotal': subTotalP});
      Loader.hide();
    });
    Loader.hide();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customer_cart')
                  .doc(userEmail)
                  .collection('cart_items')
                  .orderBy('item_name')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.data?.size == 0) {
                  // got data from snapshot but it is empty

                  return Center(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            'Hungry?',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'You have not added anything to your cart!',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.purple),
                              onPressed: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             Order_Now(widget.country)));

                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (c) => Order_Now(widget.country)), (route) => false);
                              },
                              child: Text('Order Now'))
                        ],
                      ),
                    ),
                  );
                }

                // else if (snapshot.connectionState == ConnectionState.waiting) {
                //   return CircularProgressIndicator();
                // }
                else {
                  return Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * .5,
                        child: ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map((document) {
                            //  print(snapshot.data);
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                              child: Container(
                                //height: 100,
                                // padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            child: FittedBox(
                                              fit: BoxFit.fill,
                                              child: Image.network(
                                                  document['itemImage']),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(document['item_name'],
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                IconButton(
                                                    onPressed: () async {
                                                      // print('remove');
                                                      Loader.show(context);
                                                      await subQuantity(
                                                          document[
                                                              'item_quantity'],
                                                          document[
                                                              'unit_price'],
                                                          document.id);
                                                      Loader.hide();
                                                      setState(() {});
                                                    },
                                                    icon: Icon(Icons.remove)),
                                                Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: Text(
                                                        document[
                                                                'item_quantity']
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ),
                                                ),
                                                IconButton(
                                                    onPressed: () async {
                                                      Loader.show(context);
                                                      await addQuantity(
                                                          document[
                                                              'item_quantity'],
                                                          document[
                                                              'unit_price'],
                                                          document.id);
                                                      Loader.hide();
                                                      setState(() {});
                                                    },
                                                    icon: Icon(Icons.add)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            width: 10,
                                          ),
                                        ),
                                        Text(
                                          "${document['price'].toString()} ${document['currency']}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.purple,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      thickness: 2,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                width: 250,
                                child: TextFormField(
                                  autofocus: false,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Field cannot be empty';
                                    }

                                    return null;
                                  },
                                  controller: promo,
                                  onSaved: (value) {
                                    promo.text = value!;
                                  },
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.card_giftcard,
                                      color: Colors.purple[200],
                                    ),
                                    //contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                    hintText: 'Apply a voucher',
                                    hintStyle: TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w600),
                                    enabledBorder: const OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderSide: const BorderSide(
                                          color: Colors.black54, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.purple),
                                onPressed: () async {
                                  await calPromo(promo.text);
                                  promo.clear();
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                },
                                child: Text(
                                  "Apply",
                                  style: TextStyle(color: Colors.white),
                                ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal:  ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      Text('$subTotalPrice',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text(' $currency',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('Vat: ('),
                                      Text(widget.vat.toString()),
                                      Text('%)')
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '$calVat',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Discount:  '),
                                  Row(
                                    children: [
                                      Text(
                                        '$discount',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total:  ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      Text('$total ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text('$currency',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                          height: 50,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  minimumSize: Size(350, 45)
                                  //minimumSize: (100.0,40)
                                  ),
                              onPressed: () {
                                //placeOrder();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Proceed_To_Pay(
                                            total,
                                            calVat,
                                            discount,
                                            pCode,
                                            widget.vat)));
                              },
                              child: Text(
                                'CheckOut',
                                style: TextStyle(fontSize: 15),
                              )))
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
