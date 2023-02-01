import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class View_Promotion_Image extends StatefulWidget {
  const View_Promotion_Image({Key? key}) : super(key: key);

  @override
  State<View_Promotion_Image> createState() => _View_Promotion_ImageState();
}

class _View_Promotion_ImageState extends State<View_Promotion_Image>
    with TickerProviderStateMixin {
  late Future futureCountry;
  String? countryValue;
  String country = '';
  List<Tab> _tabs = [];
  int a = 0;
  TabController? tabController;
  List<String> countryS = [];
  List countryList = [];

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
    tabController?.dispose();
  }

  promoRemove(String docCountry, String docPromo) async {
    await FirebaseFirestore.instance
        .collection('promotion_image')
        .doc(docCountry)
        .collection('promo_img')
        .doc(docPromo)
        .delete();
  }

  promoActiveDeactive(bool a, String docCountry, String docPromo) async {
    if (a == true) {
      await FirebaseFirestore.instance
          .collection('promotion_image')
          .doc(docCountry)
          .collection('promo_img')
          .doc(docPromo)
          .update({'isActive': false});
    } else {
      await FirebaseFirestore.instance
          .collection('promotion_image')
          .doc(docCountry)
          .collection('promo_img')
          .doc(docPromo)
          .update({'isActive': true});
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Promotions'),
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
                        Loader.show(context);
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('promotion_image')
                              .doc(countryList[index])
                              .collection('promo_img')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              Loader.hide();
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              Loader.hide();

                              return Container(
                                // height: MediaQuery.of(context).size.height-10,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: snapshot.data!.docs.map((document) {
                                    return Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Container(
                                        // height: ((MediaQuery.of(context).size.width-40) * 1.5)/3 +100,
                                        // height: 130,
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
                                                  color: Colors.black12,
                                                  blurRadius: 10.0,
                                                  spreadRadius: 0.3,
                                                  offset: Offset(0, 3)),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(10.0)),

                                        child: Column(
                                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15, 15, 15, 0),
                                              child: Container(
                                                child: FittedBox(
                                                  child: Image.network(
                                                    document['img'],
                                                    fit: BoxFit.fill,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            40,
                                                    height:
                                                        ((MediaQuery.of(context)
                                                                        .size
                                                                        .width -
                                                                    40) *
                                                                1.5) /
                                                            3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Expired on: ',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14),
                                                      ),
                                                      Text(
                                                        document[
                                                            'promotionExpiryDate'],
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.purple,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
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
                                                                countryList[
                                                                    index],
                                                                document.id);
                                                            setState(() {});
                                                          },
                                                          // style: ElevatedButton.styleFrom(
                                                          //     primary: Colors.red,
                                                          //
                                                          // ),
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .red),
                                                              shape: MaterialStateProperty.all<
                                                                      RoundedRectangleBorder>(
                                                                  RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)))),
                                                          child:
                                                              Text('Remove')),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            promoActiveDeactive(
                                                                document[
                                                                    'isActive'],
                                                                countryList[
                                                                    index],
                                                                document.id);
                                                            setState(() {});
                                                          },
                                                          style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all<
                                                                      Color>(
                                                                  document['isActive']
                                                                      ? Colors
                                                                          .lightGreen
                                                                      : Colors
                                                                          .grey),
                                                              shape: MaterialStateProperty.all<
                                                                      RoundedRectangleBorder>(
                                                                  RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)))),
                                                          child: document['isActive']
                                                              ? Text('Deactivated')
                                                              : Text('Activated'))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }
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
