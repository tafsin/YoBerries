import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_list_tab_scroller/scrollable_list_tab_scroller.dart';
import 'package:url_launcher/url_launcher.dart';

import 'add_to_cart.dart';
import 'cart_items.dart';

class View_Menu extends StatefulWidget {
  //const View_Menu({Key? key}) : super(key: key);
  final String storeDocId, storeArea, storeAddress;
  final int vat;
  final String? country;
  final String store_phone;
  final String store_zipCode;

  const View_Menu(this.storeDocId, this.storeArea, this.storeAddress, this.vat,
      this.country, this.store_phone, this.store_zipCode);

  @override
  State<View_Menu> createState() => _View_MenuState();
}

class _View_MenuState extends State<View_Menu> with TickerProviderStateMixin {
  String store_address = '';
  String store_zipCode = '';
  String store_area = '';
  String store_phone_num = '';
  int val = 0;
  List<Tab> _tabs = [];
  TabController? tabController;

  // bool com = false;
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
    Loader.hide();
  }

  TabController getTabController() {
    return TabController(length: _tabs.length, vsync: this);
  }

  List itemCategory1 = [];

  late Map<dynamic, List?> menuMap = {};
  Map<dynamic, Map> menuMap2 = {};
  String img = '';
  String itemName = '';
  int price = 0;
  String currency = '';
  bool isMultiple = false;
  bool isVal = false;

  getStoreItemCategoryList() async {
    Loader.show(context);
    final menuList = await FirebaseFirestore.instance
        .collection('country_menu')
        .doc(widget.country)
        .collection('menu')
        .get();
    Loader.hide();
    menuList.docs.forEach((element) {
      if (!itemCategory1.contains(element['item_category'])) {
        itemCategory1.add(element['item_category']);
      }
      ;
    });
    // print(itemCategory1);
    // print(menuList.docs.first.data());
    Loader.show(context);
    for (var i = 0; i < itemCategory1.length; i++) {
      var itemList2 = [];
      for (var j = 0; j < menuList.docs.length; j++) {
        Map<String, dynamic> itemDetails = {};
        if (menuList.docs[j]['item_category'] == itemCategory1[i]) {
          itemDetails['item_image'] = menuList.docs[j]['itemImage'];
          itemDetails['item_name'] = menuList.docs[j]['item_name'];
          itemDetails['price'] = menuList.docs[j]['price'];
          itemDetails['currency'] = menuList.docs[j]['currency'];
          itemDetails['isMultiple'] = menuList.docs[j]['isMultiple'];
          itemDetails['itemDocId'] = menuList.docs[j].id;

          itemList2.add(itemDetails);
        }
      }
      menuMap[itemCategory1[i]] = itemList2;
    }
    Loader.hide();
  }

  List<Tab> getTabs(int count) {
    _tabs.clear();
    for (int i = 0; i < count; i++) {
      _tabs.add(getTab(i));
    }
    return _tabs;
  }

  Tab getTab(int widgetNumber) {
    var val = itemCategory1[widgetNumber];
    return Tab(
      text: "$val",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Center(child: Text('Menu')),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CartItems(widget.vat, widget.country)));
              },
              icon: Icon(
                Icons.shopping_cart_sharp,
                color: Colors.white,
              ))
        ],
      ),
      body: FutureBuilder(
          future: getStoreItemCategoryList(),
          builder: (context, stream) {
            _tabs = getTabs(itemCategory1.length);
            tabController =
                TabController(length: itemCategory1.length, vsync: this);
            return Container(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 250,
                        child: ScrollableListTabScroller(
                          tabBuilder:
                              (BuildContext context, int index, bool active) =>
                                  Text(
                            menuMap.keys.elementAt(index),
                            style: !active
                                ? null
                                : TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 20),
                          ),
                          itemCount: menuMap.length,
                          itemBuilder: (BuildContext context, int index) =>
                              Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Container(
                                    child: Text(
                                      menuMap.keys.elementAt(index),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.purple),
                                    ),
                                  ),
                                ),
                              ),
                              ...menuMap.values
                                  .elementAt(index)!
                                  .asMap()
                                  .map(
                                    (index, value) => MapEntry(
                                      index,
                                      ListTile(
                                        title: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => AddToCart(
                                                            value['itemDocId']
                                                                .toString(),
                                                            widget.storeDocId,
                                                            widget.storeAddress,
                                                            widget.storeArea,
                                                            menuMap.keys
                                                                .elementAt(
                                                                    index),
                                                            widget.vat,
                                                            widget
                                                                .store_zipCode,
                                                            widget.country,
                                                            widget
                                                                .store_phone)));
                                              },
                                              child: Container(
                                                height: 300,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          top: 5,
                                                          bottom: 5,
                                                          right: 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Material(
                                                            shadowColor:
                                                                Colors.black12,
                                                            // shape: RoundedRectangleBorder(
                                                            //   borderRadius: BorderRadius.circular(10),
                                                            //   side: const BorderSide(color: Colors.grey, width: 1),
                                                            //
                                                            //
                                                            // ),

                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      10.0),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                child:
                                                                    Container(
                                                                  height: 200,
                                                                  width: 200,
                                                                  //color:Colors.black54,

                                                                  child:
                                                                      FittedBox(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    child: Image
                                                                        .network(
                                                                      value[
                                                                          'item_image'],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  value[
                                                                      'item_name'],
                                                                  style: GoogleFonts.abel(
                                                                      textStyle: TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.black87))),
                                                              SizedBox(
                                                                width: 50,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  value[
                                                                          'isMultiple']
                                                                      ? Row(
                                                                          children: [
                                                                            Text('from ',
                                                                                style: const TextStyle(fontSize: 16.0, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                                                                            Text(value['price'].toString(),
                                                                                style: const TextStyle(fontSize: 16.0, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                                                                          ],
                                                                        )
                                                                      : Text(
                                                                          value['price']
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontSize: 16.0,
                                                                              color: Colors.purpleAccent,
                                                                              fontWeight: FontWeight.bold)),
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                      value[
                                                                          'currency'],
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              16.0,
                                                                          color: Colors
                                                                              .purpleAccent,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      // Expanded(
                                                      //   child: SizedBox(
                                                      //     height: 8.0,
                                                      //   ),
                                                      // ),

                                                      SizedBox(
                                                        height: 4.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.grey,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .values,
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}
