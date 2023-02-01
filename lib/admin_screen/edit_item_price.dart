import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Edit_Item_Price extends StatefulWidget {
  final String menuId;
  final String country;

  const Edit_Item_Price(this.menuId, this.country);

  @override
  State<Edit_Item_Price> createState() => _Edit_Item_PriceState();
}

class _Edit_Item_PriceState extends State<Edit_Item_Price> {
  List<int> price = [];
  List<dynamic> sizeList = [];
  Map<String, dynamic> countryCurrency = {};
  Map<String, dynamic> sizeWithPriceList = {};
  var preSize = [];
  var prePrice = [];
  bool isMultiple = false;
  String currency = '';
  int pp = 0;
  var _selectedIndex;
  String selectedSize = '';
  String item_id = '';
  late Future myfuture;

  @override
  void initState() {
    super.initState();
    myfuture = getAddedPriceFromCountryMenu();
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Item price updated successful!"),
      content: Text("You have updated the item price."),
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

  createItemWithSize(
      List<dynamic> preSize, List<dynamic> price, bool isMultiple) async {
    Map<String, dynamic> sizeWithPrice = {};
    for (int i = 0; i < preSize.length; i++) {
      sizeWithPrice.addAll({preSize[i]: price[i]});
    }
    print(sizeWithPrice);
    // print(itemCategoryImageUrl);
    price.sort();
    List<int> priceWithoutZero = [];
    price.forEach((element) {
      if (element > 0) {
        priceWithoutZero.add(element);
      }
    });
    print("price Without Zero $priceWithoutZero");
    int lowPrice = priceWithoutZero[0];
    print(lowPrice);
    //print(price);

    await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .collection('menu')
        .doc(widget.menuId)
        .update({
      'sizeWithPrice': sizeWithPrice,
      'isMultiple': isMultiple,
      'price': lowPrice,
    });
  }

  createItemWithoutSize(List<dynamic> price, bool isMultiple) async {
    //print(itemCategoryImageUrl);
    int singlePrice = 0;
    price.forEach((element) {
      if (element > 0) {
        singlePrice = element;
      }
    });
    print(singlePrice);
    //final items = await FirebaseFirestore.instance.collection('master_menu').doc(widget.menuId).get();

    await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .collection('menu')
        .doc(widget.menuId)
        .update({
      'price': singlePrice,
      'isMultiple': isMultiple,
    });
  }

  List<size> uSizeWithPriceList = [];

  getAddedPriceFromCountryMenu() async {
    prePrice = [];
    preSize = [];
    print(widget.menuId);
    int sPrice = 0;
    try {
      await FirebaseFirestore.instance
          .collection('country_menu')
          .doc(widget.country)
          .collection('menu')
          .where('master_id', isEqualTo: widget.menuId)
          .get()
          .then((value) async {
        print('id');
        print(value.docs.first.id);
        item_id = value.docs.first.id;
        if (value.docs.first['isMultiple'] == true) {
          sizeWithPriceList = value.docs.first['sizeWithPrice'];
          var sortedKeys = sizeWithPriceList.keys.toList(growable: false)
            ..sort((k1, k2) =>
                sizeWithPriceList[k1].compareTo(sizeWithPriceList[k2]));
          LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
              key: (k) => k, value: (k) => sizeWithPriceList[k]);
          print(sortedMap);
          sortedMap.forEach((key, value) {
            print(sortedMap[key]);
            preSize.add(key);
            prePrice.add(value);
          });
        } else {
          sPrice = value.docs.first['price'];
          print(sPrice);
          preSize = await getItemSize();

          preSize.forEach((element) {
            prePrice.add(0);
          });
          for (int i = 0; i < preSize.length; i++) {
            if (preSize[i] == 'Regular') {
              prePrice[i] = sPrice;
            }
          }
        }
      });

      print('pre price $prePrice');
      print('pre size $preSize');
    } catch (e) {
      print(e);
    }
  }

  getItemSize() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('size')
        .get()
        .then((value) {
      sizeList = value['size'];
    });
    price = [];

    await FirebaseFirestore.instance
        .collection('master')
        .doc('currency')
        .get()
        .then((value) {
      countryCurrency = value['currency'];
      currency = countryCurrency[widget.country];
    });
    return sizeList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Edit Price'),
      ),
      body: FutureBuilder(
          future: myfuture,
          builder: (context, stream) {
            return Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: ListView.builder(
                      itemCount: preSize.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: Text('${preSize[index].toString()}'),
                          trailing: Container(
                            width: 50,
                            child: TextFormField(
                              initialValue: prePrice[index].toString(),
                              decoration: InputDecoration(hintText: currency),
                              onChanged: (String value) {
                                print(prePrice);
                                if (value.length < 1) {
                                  value = "0";
                                }
                                print('i $index');
                                prePrice.removeAt(index);

                                prePrice.insert(index, int.parse(value));
                                print(prePrice);
                              },
                            ),
                          ),
                        );
                      }),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.purple),
                    onPressed: () async {
                      print('hello');

                      int countPrice = 0;
                      print(prePrice.length);
                      prePrice.forEach((element) {
                        print(element);
                        if (element > 0) {
                          print('greater than 0 $element');
                          countPrice++;
                        }
                        print(countPrice);
                      });
                      if (countPrice > 1) {
                        isMultiple = true;
                      }

                      if (isMultiple == true) {
                        await createItemWithSize(preSize, prePrice, isMultiple);
                      }
                      if (isMultiple == false) {
                        await createItemWithoutSize(prePrice, isMultiple);
                      }

                      showAlertDialog(context);
                    },
                    child: Text('Update')),
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
