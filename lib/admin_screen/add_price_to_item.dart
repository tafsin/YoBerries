import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Add_Price_To_Item extends StatefulWidget {
  //const Add_Price_To_Item({Key? key}) : super(key: key);
  final String menuId;
  final String country;

  const Add_Price_To_Item(this.menuId, this.country);

  @override
  State<Add_Price_To_Item> createState() => _Add_Price_To_ItemState();
}

class _Add_Price_To_ItemState extends State<Add_Price_To_Item> {
  List<int> price = [];
  List<dynamic> sizeList = [];
  Map<String, dynamic> countryCurrency = {};
  bool isMultiple = false;
  String currency = '';

  void dispose() {
    super.dispose();
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
      title: Text("Item added successfully"),
      content: Text("You have added a new item to country menu"),
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

  getItemSize() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('size')
        .get()
        .then((value) {
      sizeList = value['size'];
    });
    price = [];
    sizeList.forEach((element) {
      price.add(0);
    });

    print(sizeList);
    print(price);

    await FirebaseFirestore.instance
        .collection('master')
        .doc('currency')
        .get()
        .then((value) {
      countryCurrency = value['currency'];
      currency = countryCurrency[widget.country];
    });
  }

  createItemWithSize(List<dynamic> size, List<int> price, bool isMultiple,
      String currency) async {
    Map<String, dynamic> sizeWithPrice = {};
    for (int i = 0; i < size.length; i++) {
      sizeWithPrice.addAll({size[i]: price[i]});
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

    final items = await FirebaseFirestore.instance
        .collection('master_menu')
        .doc(widget.menuId)
        .get();
    await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .collection('menu')
        .doc(widget.menuId)
        .set({
      'item_category': items['item_category'],
      'item_name': items['item_name'],
      'itemCategoryImage': items['itemCategoryImage'],
      'itemImage': items['itemImage'],
      'sizeWithPrice': sizeWithPrice,
      'isMultiple': isMultiple,
      'price': lowPrice,
      'isDeleted': false,
      'currency': currency,
      'master_id': widget.menuId
    });
  }

  createItemWithoutSize(
      List<int> price, bool isMultiple, String currency) async {
    //print(itemCategoryImageUrl);
    int singlePrice = 0;
    price.forEach((element) {
      if (element > 0) {
        singlePrice = element;
      }
    });
    print(singlePrice);
    final items = await FirebaseFirestore.instance
        .collection('master_menu')
        .doc(widget.menuId)
        .get();

    await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .collection('menu')
        .doc(widget.menuId)
        .set({
      'price': singlePrice,
      'item_category': items['item_category'],
      'item_name': items['item_name'],
      'itemCategoryImage': items['itemCategoryImage'],
      'itemImage': items['itemImage'],
      'isMultiple': isMultiple,
      'currency': currency,
      'master_id': widget.menuId
    });
  }

  addMenuIdToStore(String menuId) async {
    await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .update({
      'menu_collection': FieldValue.arrayUnion([menuId])
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Add Price'),
      ),
      body: FutureBuilder(
          future: getItemSize(),
          builder: (context, stream) {
            return Column(
              children: [
                Container(
                  child: ListView.builder(
                      itemCount: sizeList.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: Text('${sizeList[index].toString()}'),
                          trailing: Container(
                            width: 50,
                            child: TextFormField(
                              decoration: InputDecoration(hintText: currency),
                              onChanged: (String value) {
                                if (value.length < 1) {
                                  value = "0";
                                }
                                price.removeAt(index);
                                price.insert(index, int.parse(value));
                              },
                            ),
                          ),
                        );
                      }),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.purple),
                    onPressed: () async {
                      int countPrice = 0;
                      price.forEach((element) {
                        if (element > 0) {
                          countPrice++;
                        }
                      });
                      if (countPrice > 1) {
                        isMultiple = true;
                      }

                      if (isMultiple == true) {
                        await createItemWithSize(
                            sizeList, price, isMultiple, currency);
                      }
                      if (isMultiple == false) {
                        await createItemWithoutSize(
                            price, isMultiple, currency);
                      }
                      addMenuIdToStore(widget.menuId);
                      showAlertDialog(context);
                    },
                    child: Text('Submit')),
              ],
            );
          }),
    );
  }
}
