import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Add_To_Store_Menu extends StatefulWidget {
  //const Add_To_Store_Menu({Key? key}) : super(key: key);
  final String docId;

  const Add_To_Store_Menu(this.docId);

  @override
  State<Add_To_Store_Menu> createState() => _Add_To_Store_MenuState();
}

class _Add_To_Store_MenuState extends State<Add_To_Store_Menu> {
  @override
  // bool isMenuIsSame = false;
  void initState() {
    super.initState();

    getMenuIds();
  }

  var menuIdList = [];

  getMenuIds() async {
    try {
      await FirebaseFirestore.instance
          .collection('store_collection')
          .doc(widget.docId)
          .get()
          .then((value) => {menuIdList = value['menu_collection']});
      print('menu id list $menuIdList');
    } catch (e) {
      print('error $e');
    }
  }

  postToStoreMenuWithoutSize(
      String item_name,
      String item_category,
      int price,
      isMultiple,
      String itemCategoryImage,
      String itemImage,
      String docId) async {
    await FirebaseFirestore.instance
        .collection('store_collection')
        .doc(widget.docId)
        .collection('menu')
        .doc(docId)
        .set({
      'item_name': item_name,
      'item_category': item_category,
      'price': price,
      'isMultiple': isMultiple,
      'isDeleted': false,
      'itemCategoryImage': itemCategoryImage,
      'itemImage': itemImage
    });
  }

  postToStoreMenuWithtSize(
      String item_name,
      String item_category,
      int singlePrice,
      isMultiple,
      String itemCategoryImage,
      String itemImage,
      Map<String, dynamic> sizeWithPrice,
      String docId) async {
    await FirebaseFirestore.instance
        .collection('store_collection')
        .doc(widget.docId)
        .collection('menu')
        .doc(docId)
        .set({
      'item_name': item_name,
      'item_category': item_category,
      'price': singlePrice,
      'isMultiple': isMultiple,
      'isDeleted': false,
      'itemCategoryImage': itemCategoryImage,
      'itemImage': itemImage,
      'sizeWithPrice': sizeWithPrice
    });
  }

  addMenuIdToStore(String menuId) async {
    await FirebaseFirestore.instance
        .collection('store_collection')
        .doc(widget.docId)
        .update({
      'menu_collection': FieldValue.arrayUnion([menuId])
    });
  }

  isSameMenuId(String menuId) {
    bool menu = false;
    menuIdList.forEach((element) {
      if (element == menuId) {
        menu = true;
      }
    });

    print('is M $menu');
    return menu;
  }

  removeMenu(String menuId) async {
    await FirebaseFirestore.instance
        .collection('store_collection')
        .doc(widget.docId)
        .update({
      'menu_collection': FieldValue.arrayRemove([menuId])
    });
    await FirebaseFirestore.instance
        .collection('store_collection')
        .doc(widget.docId)
        .collection('menu')
        .doc(menuId)
        .delete();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Add Items to Store Menu'),
      ),
      body: Container(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('master_menu')
                .orderBy('item_category')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                print(snapshot.data!.size);
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((document) {
                          // isSameMenuId(document.id);
                          print(snapshot.data);
                          return Container(
                            height: document['isMultiple'] ? 400 : 350,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 80,
                                  width: 100,
                                  color: Colors.black54,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Image.network(document['itemImage']),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  document['item_name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text('Item Category: ',
                                        style: TextStyle(
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Text(document['item_category']),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text('Price: ',
                                        style: TextStyle(
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    document['isMultiple']
                                        ? Row(
                                            children: [
                                              Text('from '),
                                              Text(
                                                  document['price'].toString()),
                                              Text(' Tk')
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Text(
                                                  document['price'].toString()),
                                              Text(' Tk'),
                                            ],
                                          )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                document['isMultiple']
                                    ? Expanded(
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: document['sizeWithPrice']
                                                .length,
                                            itemBuilder: (context, index) {
                                              print(document['sizeWithPrice']
                                                  .length);
                                              Map<String, dynamic> sizeList =
                                                  {};
                                              List<String> size = [];
                                              List<int> price = [];
                                              sizeList.addAll(
                                                  document['sizeWithPrice']);
                                              var sortedKeys = sizeList.keys
                                                  .toList(growable: false)
                                                ..sort((k1, k2) => sizeList[k1]
                                                    .compareTo(sizeList[k2]));
                                              LinkedHashMap sortedMap =
                                                  new LinkedHashMap
                                                          .fromIterable(
                                                      sortedKeys,
                                                      key: (k) => k,
                                                      value: (k) =>
                                                          sizeList[k]);
                                              sortedMap.forEach((key, value) {
                                                size.add(key);
                                                price.add(value);
                                              });
                                              print(size);
                                              print(price);

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 2.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      size[index],
                                                      style: TextStyle(
                                                          color: Colors.purple,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                                    Text(':  '),
                                                    Text(price[index]
                                                        .toString()),
                                                    Text(' Tk')
                                                  ],
                                                ),
                                              );
                                            }),
                                      )
                                    : Text('size not available'),
                                FutureBuilder(
                                    future: getMenuIds(),
                                    builder: (context, stream) {
                                      return ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: menuIdList
                                                      .contains(document.id)
                                                  ? Colors.red
                                                  : Colors.green),
                                          onPressed: () async {
                                            bool isMenuPresent =
                                                isSameMenuId(document.id);

                                            if (isMenuPresent == false) {
                                              document['isMultiple']
                                                  ? await postToStoreMenuWithtSize(
                                                      document['item_name'],
                                                      document['item_category'],
                                                      document['price'],
                                                      document['isMultiple'],
                                                      document[
                                                          'itemCategoryImage'],
                                                      document['itemImage'],
                                                      document['sizeWithPrice'],
                                                      document.id)
                                                  : await postToStoreMenuWithoutSize(
                                                      document['item_name'],
                                                      document['item_category'],
                                                      document['price'],
                                                      document['isMultiple'],
                                                      document[
                                                          'itemCategoryImage'],
                                                      document['itemImage'],
                                                      document.id);
                                              await addMenuIdToStore(
                                                  document.id);
                                              setState(() {});
                                            } else {
                                              await removeMenu(document.id);
                                              setState(() {});
                                            }
                                          },
                                          child:
                                              menuIdList.contains(document.id)
                                                  ? Text('Remove')
                                                  : Text("Add"));
                                    }),
                                Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
