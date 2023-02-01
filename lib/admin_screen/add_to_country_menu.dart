import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:yo_berry_2/admin_screen/add_price_to_item.dart';
import 'package:yo_berry_2/admin_screen/edit_item_price.dart';

class Add_To_Country_Menu extends StatefulWidget {
  // const Add_To_Country_Menu({Key? key}) : super(key: key);
  final String country;

  const Add_To_Country_Menu(this.country);

  @override
  State<Add_To_Country_Menu> createState() => _Add_To_Country_MenuState();
}

class _Add_To_Country_MenuState extends State<Add_To_Country_Menu> {
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
    Loader.hide();
  }

  var menuIdList = [];

  getMenuIds() async {
    try {
      Loader.show(context);
      await FirebaseFirestore.instance
          .collection('country_menu')
          .doc(widget.country)
          .get()
          .then((value) {
        Loader.hide();
        menuIdList = value['menu_collection'];
      });
      print('menu id list $menuIdList');
    } catch (e) {
      print('error $e');
    }
  }

  isSameMenuId(String menuId) {
    bool menu = false;
    Loader.show(context);
    menuIdList.forEach((element) {
      if (element == menuId) {
        menu = true;
      }
    });
    Loader.hide();

    print('is M $menu');
    return menu;
  }

  removeMenu(String menuId) async {
    await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .update({
      'menu_collection': FieldValue.arrayRemove([menuId])
    });
    await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .collection('menu')
        .doc(menuId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Add Item to Country Menu'),
      ),
      body: Container(
        child: FutureBuilder(
            future: getMenuIds(),
            builder: (context, stream) {
              return SafeArea(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('master_menu')
                      .orderBy('item_category')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                  height: 350,
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
                                          child: Image.network(
                                              document['itemImage']),
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
                                      // Row(
                                      //   children: [
                                      //     Text('Price: ',style: TextStyle(color: Colors.purple,fontWeight: FontWeight.bold,fontSize: 15)),
                                      //     document['isMultiple'] ? Row(
                                      //       children: [
                                      //         Text('from '),
                                      //         Text(document['price'].toString()),
                                      //         Text(' Tk')
                                      //       ],
                                      //     ): Row(
                                      //       children: [
                                      //         Text(document['price'].toString()),
                                      //         Text(' Tk'),
                                      //       ],
                                      //     )
                                      //   ],
                                      // ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      // document['isMultiple'] ? Expanded(
                                      //   child: ListView.builder(
                                      //       shrinkWrap: true,
                                      //       itemCount: document['sizeWithPrice'].length,
                                      //       itemBuilder: (context, index) {
                                      //         print(document['sizeWithPrice'].length);
                                      //         Map<String,dynamic> sizeList ={};
                                      //         List<String> size =[];
                                      //         List<int> price =[];
                                      //         sizeList.addAll(document['sizeWithPrice']);
                                      //         var sortedKeys = sizeList.keys.toList(growable: false)
                                      //           ..sort((k1, k2) => sizeList[k1].compareTo(sizeList[k2]));
                                      //         LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
                                      //             key: (k) => k, value: (k) => sizeList[k]);
                                      //         sortedMap.forEach((key, value) {
                                      //           size.add(key);
                                      //           price.add(value);
                                      //         });
                                      //         print(size);
                                      //         print(price);
                                      //
                                      //         return Padding(
                                      //           padding: const EdgeInsets.only(bottom: 2.0),
                                      //           child: Row(
                                      //             children: [
                                      //               Text(size[index],style: TextStyle(color: Colors.purple,fontWeight: FontWeight.bold,fontSize: 15),),
                                      //               Text(':  '),
                                      //               Text(price[index].toString()),
                                      //               Text(' Tk')
                                      //             ],
                                      //           ),
                                      //         );
                                      //       }
                                      //   ),
                                      // ): Text('size not available'),

                                      Row(
                                        children: [
                                          menuIdList.contains(document.id)
                                              ? ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary: Colors.red),
                                                  onPressed: () async {
                                                    await removeMenu(
                                                        document.id);
                                                    setState(() {});
                                                  },
                                                  child: Text('Remove'))
                                              : ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary:
                                                              Colors.green),
                                                  onPressed: () async {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Add_Price_To_Item(
                                                                    document.id,
                                                                    widget
                                                                        .country)));
                                                    setState(() {});
                                                  },
                                                  child: Text("Add")),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          menuIdList.contains(document.id)
                                              ? ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Colors
                                                                  .lightGreen)),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Edit_Item_Price(
                                                                    document.id,
                                                                    widget
                                                                        .country)));
                                                  },
                                                  child: Text('Edit Price'))
                                              : Container()
                                        ],
                                      ),

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
              );
            }),
      ),
    );
  }
}
