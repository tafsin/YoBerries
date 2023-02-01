import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class Rewards_point_screen extends StatefulWidget {
  //const Rewards_point_screen({Key? key}) : super(key: key);
  final String? country;

  const Rewards_point_screen(this.country);

  @override
  State<Rewards_point_screen> createState() => _Rewards_point_screenState();
}

class _Rewards_point_screenState extends State<Rewards_point_screen> {
  String uid = '';
  int reward_point = 0;
  int balance = 0;

  // String country ='';
  void initState() {
    super.initState();
    currentUser();
    //getRewardPoint();
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Sorry"),
      content: Text("You do not have sufficient points"),
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

  redeemAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Success"),
      content: Text("Yo have redeem your reward points successfully"),
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

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // userEmail = currentUser.email;
      uid = currentUser.uid;
      print(currentUser.email);
    }
  }

  getRewardPoint() async {
    print('getReward');
    print('uid $uid');
    Loader.show(context);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      Loader.hide();
      print(value['reward_point']);
      reward_point = value['reward_point'];
      balance = value['balance'];

      print(reward_point);
      print(balance);
    });
  }

  redeemRewards(
      int redeemPoint, int redeemAmount, int balance, int reward_point) async {
    print('redeem');
    reward_point = reward_point - redeemPoint;
    balance = balance + redeemAmount;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'reward_point': reward_point,
      'balance': balance,
    });
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple,
        title: Center(child: Text('Your Reward Points')),
      ),
      body: FutureBuilder(
          future: getRewardPoint(),
          builder: (context, stream) {
            if (stream.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Earn ',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.purple,
                                fontStyle: FontStyle.italic),
                          ),
                          Text(
                            '1 ',
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.lightGreen,
                                fontWeight: FontWeight.bold),
                          ),
                          Text('point on every ',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.purple,
                                  fontStyle: FontStyle.italic)),
                          Text('100 ',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.bold)),
                          Text('BDT purchase',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.purple,
                                  fontStyle: FontStyle.italic))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 200,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                spreadRadius: 1,
                                offset: Offset(0, 12)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text('Balance Points',
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 40,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: Colors.lightGreen,
                                    size: 50,
                                  ),
                                  Text(
                                    reward_point.toString(),
                                    style: TextStyle(
                                        color: Colors.purple, fontSize: 30),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reward_redeem')
                            .doc(widget.country)
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
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: GridView(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.0,
                                    crossAxisSpacing: 25,
                                    mainAxisSpacing: 20,
                                    mainAxisExtent: 115,
                                  ),
                                  children: List.generate(
                                    snapshot.data!.docs.length,
                                    (index) {
                                      return Container(
                                        height: 250,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.purple,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 10.0,
                                                spreadRadius: 1,
                                                offset: Offset(0, 3)),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 2, right: 2),
                                              child: Container(
                                                height: 35,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft: Radius
                                                                .circular(10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10))),
                                                child: Column(
                                                  children: [
                                                    Text('Win'),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          (snapshot.data!.docs[
                                                                      index]
                                                                  ['amount'])
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .purple),
                                                        ),
                                                        Text(' BDT')
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
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
                                                  size: 20,
                                                ),
                                                Text(
                                                  (snapshot.data!.docs[index]
                                                          ['point'])
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: 6,
                                              ),
                                            ),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.green,
                                                  onPrimary: Colors.white,
                                                  shadowColor:
                                                      Colors.greenAccent,
                                                  elevation: 3,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              32.0)),
                                                  minimumSize: Size(20, 25),
                                                ),
                                                onPressed: () async {
                                                  int redeemPoint1 = snapshot
                                                      .data!
                                                      .docs[index]['point'];
                                                  if (reward_point >=
                                                      redeemPoint1) {
                                                    await redeemRewards(
                                                        snapshot.data!
                                                                .docs[index]
                                                            ['point'],
                                                        snapshot.data!
                                                                .docs[index]
                                                            ['amount'],
                                                        balance,
                                                        reward_point);
                                                    redeemAlertDialog(context);
                                                  } else {
                                                    showAlertDialog(context);
                                                  }
                                                },
                                                child: Text('Redeem'))
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  ],
                ),
              );
            }
          }),
    );
  }
}
