import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:yo_berry_2/screens/cart_items.dart';
import 'package:yo_berry_2/widgets.dart';

class AddToCart extends StatefulWidget {
  //const AddToCart({Key? key}) : super(key: key);
  final String docId;
  final String storeId;
  final String storeAddress;
  final String storeArea;
  final String itemCategory;
  final int vat;
  final String zipCode;
  final String? country;
  final String storePhoneNum;

  const AddToCart(
      this.docId,
      this.storeId,
      this.storeAddress,
      this.storeArea,
      this.itemCategory,
      this.vat,
      this.zipCode,
      this.country,
      this.storePhoneNum);

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  String itemName = '';
  String itemImage = '';
  bool isMultiple = false;
  List index = [0, 0, 0, 0, 0];
  int price = 0;
  var _selectedIndex;
  int selectedItemPrice = 0;
  String? userEmail = '';
  String? uid = "";

  // int total = 0;
  int subTotal = 0;
  var selectedSize;
  String itemSize = '';
  String itemID = '';
  bool isItemID = false;
  bool isSize = false;
  String element_id = '';
  bool flag = false;

  //int initialPrice =0;

  Map<String, dynamic> sizeList = {};
  Map<String, dynamic> countryNameCodeMap = {};
  List<size> sizeWithPriceList = [];
  String countryNameCode = '';
  String currency = '';

  void dispose() {
    super.dispose();
    Loader.hide();
  }

  getCountryNameCode() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('countryNameCode')
        .get()
        .then((value) {
      countryNameCodeMap = value['countryNameCode'];
      countryNameCode = countryNameCodeMap[widget.country];
      print(countryNameCodeMap);
    });
    print('Country Name Code $countryNameCode');
  }

  checkCart() async {
    await getOrSetTotal();
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .get()
        .then((value) async {
      try {
        if (value['subTotal'] > 0) {
          if (value['store_id'] == widget.storeId) {
            final items = await FirebaseFirestore.instance
                .collection('customer_cart')
                .doc(userEmail)
                .collection('cart_items')
                .get();
            bool itemIdP = false;
            String mId = '';
            if (isMultiple == false) {
              items.docs.forEach((element) async {
                if (element['item_id'] == widget.docId) {
                  itemIdP = true;
                  mId = element.id;
                }
              });
              if (itemIdP == true) {
                await doUpdateQuantity(mId);
              } else {
                await addCart();
              }
            }
            if (isMultiple == true) {
              var cartItemsId = [];
              String matchSizeId = '';
              items.docs.forEach((element) async {
                if (element['item_id'] == widget.docId) {
                  cartItemsId.add(element.id);
                }
              });
              print('cart item id list $cartItemsId');
              var count = cartItemsId.length;
              print('length $count');

              for (var id in cartItemsId) {
                await FirebaseFirestore.instance
                    .collection('customer_cart')
                    .doc(userEmail)
                    .collection('cart_items')
                    .doc(id)
                    .get()
                    .then((value) => {
                          if (value['size'] == selectedSize)
                            {matchSizeId = value.id},
                          count = count - 1,
                          print('count in $count')
                        });
              }

              print('count $count');
              if (count == 0) {
                print('match Size $matchSizeId');
                if (matchSizeId != '') {
                  await doUpdateQuantity(matchSizeId);
                } else {
                  print('else add cart of multi');
                  await addCart();
                }
              }
            }
          } else {
            showAlertDialog(context);
          }
        }
        if (value['subTotal'] == 0) {
          final items = await FirebaseFirestore.instance
              .collection('customer_cart')
              .doc(userEmail)
              .collection('cart_items')
              .get();
          bool itemIdP = false;
          String mId = '';
          if (isMultiple == false) {
            items.docs.forEach((element) async {
              if (element['item_id'] == widget.docId) {
                itemIdP = true;
                mId = element.id;
              }
            });
            if (itemIdP == true) {
              await doUpdateQuantity(mId);
            } else {
              await addCart();
            }
          }
          if (isMultiple == true) {
            var cartItemsId = [];
            String matchSizeId = '';
            items.docs.forEach((element) async {
              if (element['item_id'] == widget.docId) {
                cartItemsId.add(element.id);
              }
            });
            print('cart item id list $cartItemsId');
            var count = cartItemsId.length;
            print('lenth $count');

            for (var id in cartItemsId) {
              await FirebaseFirestore.instance
                  .collection('customer_cart')
                  .doc(userEmail)
                  .collection('cart_items')
                  .doc(id)
                  .get()
                  .then((value) => {
                        if (value['size'] == selectedSize)
                          {matchSizeId = value.id},
                        count = count - 1,
                        print('count in $count')
                      });
            }

            print('count $count');
            if (count == 0) {
              print('match Size $matchSizeId');
              if (matchSizeId != '') {
                await doUpdateQuantity(matchSizeId);
              } else {
                print('else add cart of multi');
                await addCart();
              }
            }
          }
        }
      } catch (e) {
        print(e);
      }
    });
  }

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


            Navigator.push(context, MaterialPageRoute(builder: (context)=>CartItems(widget.vat,widget.country)));
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
          "You still have products from our another branch.\n Shall we start over a fresh cart?"),
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

  addCart() async {
    print('add to cat');

    //Loader.show(context);
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .get()
        .then((value) => {
              setState(() {
                subTotal = value['subTotal'];
              })
            });

    //  print('add to cart before $subTotal');
    var subTotalU = subTotal + price;
    setState(() {
      subTotal = subTotalU;
    });
    // print('add to cart $subTotal');
    // print("pp $price");
    // print(widget.storeId);
    //
    // print('subtotal $subTotal');
    Loader.show(context);
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .update({
      'subTotal': subTotal,
      'uid': uid,
      'store_id': widget.storeId,
      'zipCode': widget.zipCode,
      'userEmail': userEmail,
      'isOrderPlaced': false,
      'storeAddress': widget.storeAddress,
      'storeArea': widget.storeArea,
      'country': widget.country,
      'countryNameCode': countryNameCode,
      'storePhoneNum': widget.storePhoneNum,
      'currency': currency
    });
    if (isMultiple == true) {
      await FirebaseFirestore.instance
          .collection('customer_cart')
          .doc(userEmail)
          .collection('cart_items')
          .doc()
          .set({
        'isMultiple': true,
        'price': price,
        'size': selectedSize,
        'unit_price': price,
        'item_name': itemName,
        'itemImage': itemImage,
        'item_quantity': 1,
        'item_category': widget.itemCategory,
        'item_id': widget.docId,
        'currency': currency
      });
    } else {
      await FirebaseFirestore.instance
          .collection('customer_cart')
          .doc(userEmail)
          .collection('cart_items')
          .doc()
          .set({
        'isMultiple': false,
        'price': price,
        'unit_price': price,
        'item_name': itemName,
        'itemImage': itemImage,
        'item_quantity': 1,
        'item_category': widget.itemCategory,
        'item_id': widget.docId,
        'currency': currency
      });
    }
    Loader.hide();

    print('added');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CartItems(widget.vat, widget.country)));
  }

  doUpdateQuantity(String itemDocId) async {
    print('do update callled');
    int totalUpdate = 0;
    int subTotalUpdate = 0;
    int quantity = 0;
    int unitPrice = 0;

    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .get()
        .then((value) => {subTotalUpdate = value['subTotal']});
    print('Element id $element_id');
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .collection('cart_items')
        .doc(itemDocId)
        .get()
        .then((value) => {
              setState(() {
                quantity = value['item_quantity'];
                unitPrice = value['unit_price'];
              })
            });

    print('SUBTOTAAAAAAL $subTotalUpdate');
    subTotalUpdate = subTotalUpdate + unitPrice;

    print('after $subTotalUpdate');
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .update({'subTotal': subTotalUpdate});

    quantity = quantity + 1;
    int calculatedPrice = unitPrice * quantity;
    await FirebaseFirestore.instance
        .collection('customer_cart')
        .doc(userEmail)
        .collection('cart_items')
        .doc(itemDocId)
        .update({'item_quantity': quantity, 'price': calculatedPrice});
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CartItems(widget.vat, widget.country)));
  }

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
      uid = currentUser.uid;
    }
  }

  getOrSetTotal() async {
    try {
      await FirebaseFirestore.instance
          .collection('customer_cart')
          .doc(userEmail)
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

  getItemSize() async {
    final size = await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .collection('menu')
        .doc(widget.docId)
        .get();
    sizeList.addAll(size['sizeWithPrice']);

    var sortedKeys = sizeList.keys.toList(growable: false)
      ..sort((k1, k2) => sizeList[k1].compareTo(sizeList[k2]));
    LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => sizeList[k]);

    sizeWithPriceList = await convertMapToList(sortedMap);
  }

  List<size> convertMapToList(Map sizeLists) {
    Loader.show(context);
    List<size> sizes = [];

    sizeLists.forEach((key, value) {
      if (sizeLists[key] != 0) {
        sizes.add(size(sizetype: key, price: value));
      }
      sizes.forEach((element) {});
    });
    Loader.hide();

    return sizes;
  }

  getItemDetails() async {
    // Loader.show(context);
    await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .collection('menu')
        .doc(widget.docId)
        .get()
        .then((value) => {
              setState(() {
                itemName = value['item_name'];
                isMultiple = value['isMultiple'];
                itemImage = value['itemImage'];
                price = value['price'];
                currency = value['currency'];
                //itemID = value['item_id'];
                // itemSize = value['size'];
              })
            });

    if (isMultiple == true) {
      Loader.show(context);
      await getItemSize();
      Loader.hide();
    }
  }

  //New
  //New end
  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();
    currentUser();

    _future = getItemDetails();
    getCountryNameCode();
    //getOrSetTotal();
    //alreadyInCart();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<dynamic>(
          future: _future,
          builder: (context, stream) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              //shrinkWrap: true,
              children: [
                Column(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).padding.top,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(itemImage),
                          fit: BoxFit.fill,
                          // scale: 50.0
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
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
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$itemName',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          isMultiple
                              ? Text(
                                  'from $price $currency',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                )
                              : Text(
                                  '$price $currency',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                )
                        ],
                      ),
                    ),
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: sizeWithPriceList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: Radio<int>(
                              value: index,
                              groupValue: _selectedIndex,
                              activeColor: Colors.purple,
                              onChanged: (value) {
                                setState(() {
                                  _selectedIndex = value!;

                                  price =
                                      sizeWithPriceList[_selectedIndex].price;
                                  selectedSize =
                                      sizeWithPriceList[_selectedIndex]
                                          .sizetype;
                                });
                                //var p = sizeWithPriceList[_selectedIndex].price;
                              },
                            ),
                            // Loader.hide();
                            title: Text(sizeWithPriceList[index].sizetype),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(sizeWithPriceList[index].price.toString()),
                                Text(currency)
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Expanded(
                //   child: SizedBox(
                //     height: 10,
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size(300, 45)
                          //minimumSize: (100.0,40)
                          ),
                      onPressed: () async {
                        if (isMultiple == true) {
                          if (selectedSize != null) {
                            Loader.show(context);
                            await checkCart();
                            Loader.hide();
                          } else {
                            errorAlert(context, "Please select a size first");
                          }
                        } else {
                          Loader.show(context);
                          await checkCart();
                          Loader.hide();
                        }
                      },
                      child: Text(
                        "Add To Cart",
                        style: TextStyle(fontSize: 18),
                      )),
                )

                // Expanded(child: SizedBox(height: 300,)),
              ],
            );
          }),
    );
  }
}

class size {
  final String sizetype;
  final int price;

  size({required this.sizetype, required this.price});
}
