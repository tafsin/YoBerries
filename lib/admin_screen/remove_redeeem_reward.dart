import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Remove_Redeem_Reward extends StatefulWidget {
  final List<dynamic> countryList;

  const Remove_Redeem_Reward(this.countryList);

  //const Remove_Redeem_Reward({Key? key}) : super(key: key);

  @override
  State<Remove_Redeem_Reward> createState() => _Remove_Redeem_RewardState();
}

class _Remove_Redeem_RewardState extends State<Remove_Redeem_Reward>
    with TickerProviderStateMixin {
  late Future futureCountry;
  String? countryValue;
  String country = '';
  List<Tab> _tabs = [];
  int a = 0;
  late TabController _tabController;

  @override
  void initState() {
    _tabs = getTabs(widget.countryList.length);
    _tabController = getTabController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
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
    var val = widget.countryList[widgetNumber];
    return Tab(
      text: "$val",
    );
  }

  removeReward(String country, String docId) async {
    print("reward Id $docId");
    print(country);
    await FirebaseFirestore.instance
        .collection('reward_redeem')
        .doc(country)
        .collection('point_redeem')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Remove Redeem'),
        bottom: TabBar(
          onTap: (index) {
            a = index;
          },
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      body: FutureBuilder(builder: (context, stream) {
        return Container(
          child: TabBarView(
            controller: _tabController,
            children: List<Widget>.generate(widget.countryList.length, (index) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reward_redeem')
                    .doc(widget.countryList[index])
                    .collection('point_redeem')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  // Loader.show(context);
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    //return Container();
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 8),
                      child: FutureBuilder(builder: (context, stream) {
                        return ListView(
                          shrinkWrap: true,
                          children: List.generate(
                            snapshot.data!.docs.length,
                            (index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  margin: EdgeInsets.only(top: 5),

                                  //height: 0,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade200,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10.0,
                                          spreadRadius: 1,
                                          offset: Offset(0, 12)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, right: 2),
                                        child: Container(
                                          margin: EdgeInsets.only(left: 5),
                                          height: 40,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            children: [
                                              Text('Win'),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    (snapshot.data!.docs[index]
                                                            ['amount'])
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.purple),
                                                  ),
                                                  widget.countryList[a] ==
                                                          'Bangladesh'
                                                      ? Text(' BDT')
                                                      : Text(' USD')
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.stars,
                                            color: Colors.lightGreen,
                                            size: 40,
                                          ),
                                          Text(
                                            (snapshot.data!.docs[index]
                                                    ['point'])
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 25),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          width: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.red),
                                            onPressed: () async {
                                              await removeReward(
                                                  widget.countryList[a],
                                                  snapshot
                                                      .data!.docs[index].id);
                                              setState(() {});
                                            },
                                            child: Text('Remove')),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    );
                  }
                },
              );
            }),
          ),
        );
      }),
    );
  }
}
