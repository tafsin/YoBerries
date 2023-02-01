import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Store_Dashboard_Menu extends StatefulWidget {
  // const Store_Dashboard_Menu({Key? key}) : super(key: key);
  final String storeId;
  final String country;

  const Store_Dashboard_Menu(this.storeId, this.country);

  @override
  State<Store_Dashboard_Menu> createState() => _Store_Dashboard_MenuState();
}

class _Store_Dashboard_MenuState extends State<Store_Dashboard_Menu> {
  // String country = '';
  @override
  void initState() {
    super.initState();
    //getCountry();
  }

  // getCountry () async{
  //   await FirebaseFirestore.instance.collection('store_collection').doc(widget.storeId).get().then((value) => {
  //    setState((){
  //      country = value['country'];
  //    })
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Menu'),
      ),
      body: Container(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('country_menu')
                .doc(widget.country)
                .collection('menu')
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
                            height: document['isMultiple'] ? 300 : 250,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
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
                                      fontSize: 18,
                                      color: Colors.purple),
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
