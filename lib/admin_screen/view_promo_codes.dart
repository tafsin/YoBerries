import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class View_Promo_Codes extends StatefulWidget {
  const View_Promo_Codes({Key? key}) : super(key: key);

  @override
  State<View_Promo_Codes> createState() => _View_Promo_CodesState();
}

class _View_Promo_CodesState extends State<View_Promo_Codes>
    with TickerProviderStateMixin {
  late Future futureCountry;
  String? countryValue;
  String country = '';
  List<Tab> _tabs = [];
  int a = 0;
  TabController? tabController;
  List countryList = [];
  List<String> countryS = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  getList() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('countryArray')
        .get()
        .then((value) {
      countryList = value['countryArray'];
    });
  }

  TabController getTabController() {
    return TabController(length: _tabs.length, vsync: this);
  }

  List<Tab> getTabs(int count) {
    _tabs.clear();
    for (int i = 0; i < count; i++) {
      _tabs.add(getTab(i));
    }
    return _tabs;
  }

  Tab getTab(int widgetNumber) {
    var val = countryList[widgetNumber];
    return Tab(
      text: "$val",
    );
  }

  promoActiveDeactive(bool a, String docCountry, String docPromo) async {
    if (a == true) {
      await FirebaseFirestore.instance
          .collection('promo')
          .doc(docCountry)
          .collection('promo_codes')
          .doc(docPromo)
          .update({'isActive': false});
    } else {
      await FirebaseFirestore.instance
          .collection('promo')
          .doc(docCountry)
          .collection('promo_codes')
          .doc(docPromo)
          .update({'isActive': true});
    }
  }

  promoRemove(String docCountry, String docPromo) async {
    await FirebaseFirestore.instance
        .collection('promo')
        .doc(docCountry)
        .collection('promo_codes')
        .doc(docPromo)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Promo Codes'),
      ),
      body: FutureBuilder(
          future: getList(),
          builder: (context, stream) {
            _tabs = getTabs(countryList.length);
            tabController = getTabController();
            return Column(
              children: [
                Container(
                  height: 100,
                  width: double.maxFinite,
                  child: TabBar(
                      controller: tabController,
                      isScrollable: true,
                      labelColor: Colors.lightGreen,
                      unselectedLabelColor: Colors.purple,
                      onTap: (index) {
                        a = index;
                      },
                      tabs: _tabs),
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 250,
                    child: TabBarView(
                      controller: tabController,
                      children:
                          List<Widget>.generate(countryList.length, (index) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('promo')
                              .doc(countryList[index])
                              .collection('promo_codes')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return Container(
                              height: MediaQuery.of(context).size.height - 10,
                              child: ListView(
                                shrinkWrap: true,
                                children: snapshot.data!.docs.map((document) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, left: 8, right: 8),
                                    child: Container(
                                      height: 130,
                                      //width: 200,
                                      decoration: BoxDecoration(
                                          //\color: Colors.cyan[900],
                                          color: Colors.white,
                                          // border: Border.all(
                                          //   color: Colors.purple,
                                          //   width: 4.0,
                                          // ),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 10.0,
                                                spreadRadius: 1,
                                                offset: Offset(0, 5)),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            top: 5,
                                            bottom: 5,
                                            right: 0),
                                        child: Row(
                                          // crossAxisAlignment: CrossAxisAlignment.center,
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text(document['code'],
                                                        style: TextStyle(
                                                          color: Colors.purple,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    SizedBox(
                                                      width: 30,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Expired on: ',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                        Text(document[
                                                            'promoExpiryDate'])
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      document['discount']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          color: Colors
                                                              .lightGreen),
                                                    ),
                                                    countryList[index] ==
                                                            'Bangladesh'
                                                        ? Text(
                                                            ' BDT',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .purple),
                                                          )
                                                        : Text(
                                                            ' USD',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .purple),
                                                          ),
                                                    Text(
                                                      ' discount on minimum purchase ',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.purple),
                                                    ),
                                                    Text(
                                                        document[
                                                                'minimumPurchase']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            color: Colors
                                                                .lightGreen)),
                                                    countryList[index] ==
                                                            'Bangladesh'
                                                        ? Text(
                                                            ' BDT',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .purple),
                                                          )
                                                        : Text(
                                                            ' USD',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .purple),
                                                          )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          promoRemove(
                                                              countryList[a],
                                                              document.id);
                                                          setState(() {});
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                primary:
                                                                    Colors.red),
                                                        child: Text('Remove')),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          promoActiveDeactive(
                                                              document[
                                                                  'isActive'],
                                                              countryList[a],
                                                              document.id);
                                                          setState(() {});
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            primary: document[
                                                                    'isActive']
                                                                ? Colors
                                                                    .lightGreen
                                                                : Colors.grey),
                                                        child: document[
                                                                'isActive']
                                                            ? Text(
                                                                'Deactivated')
                                                            : Text('Activated'))
                                                  ],
                                                )
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
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
