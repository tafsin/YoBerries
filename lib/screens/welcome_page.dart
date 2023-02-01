import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yo_berry_2/promotion_dash.dart';
import 'package:yo_berry_2/screens/customer_recent_order.dart';
import 'package:yo_berry_2/screens/favourite_order.dart';
import 'package:yo_berry_2/screens/favourite_order_new.dart';
import 'package:yo_berry_2/screens/login_screen.dart';
import 'package:yo_berry_2/screens/oder_now.dart';
import 'package:yo_berry_2/screens/reward_point_screen.dart';
import 'package:yo_berry_2/screens/settings.dart';
import 'package:yo_berry_2/screens/user_qr_payment.dart';
import 'package:yo_berry_2/screens/user_qr_payment_new.dart';
import 'package:yo_berry_2/screens/vouchers.dart';
import 'package:http/http.dart' as http;

import '../local_notifi.dart';

class Welcome_Page extends StatefulWidget {
  final String? cntry;
  final String? uid;

  final String? uName;
  final String? imgUrl;

  const Welcome_Page(this.cntry, this.uid, this.uName, this.imgUrl);

  @override
  _Welcome_PageState createState() => _Welcome_PageState();
}

class _Welcome_PageState extends State<Welcome_Page> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // String? userName = '';
  // String country ='';
  int _selectedIndex = 0;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late FirebaseMessaging _fcm;
  String userImg = '';

  late final pages;
  int index = 0;
  late DateTime todayF;

  late DateTime today;
  String imgUrl = '';
  bool imgBool = false;
  late Future myFuture;

  getDate() {
    today = DateTime.now();
    todayF = today.subtract(Duration(days: 1));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getValue();

    getDate();
    LocalNotificationService.initialize(context);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print(message.data);
        print(message.notification!.title);
        print(message.notification!.body);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Ok it dose not work");
        print(message.data);
        print(message.notification!.title);
        print(message.notification!.body);

        LocalNotificationService.display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        print(message.data);
        print(message.notification!.title);
        print(message.notification!.body);

        final routeName = message.data['route'];
        print(routeName);
        Navigator.of(context).pushNamed(routeName);
      }
    });
  }

  //
  // getUserDetails() async {
  //    print('user details');
  //    Loader.show(context);
  //
  //        await FirebaseFirestore.instance.collection('users').doc(widget.uid).get().then((value){
  //          Loader.hide();
  //
  //            userName = value['userName'];
  //            country = value['country'];
  //            imgUrl = value['imageUrl'];
  //
  //
  //        });
  //        // setState((){});
  //        print('name $userName');
  //
  //

  // }
  Future getValue()async{
    print('getValue');
    Loader.show(context);
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var uImg= sharedPreferences.getString('imgUrl');

      userImg = uImg!;

      Loader.hide();
  }
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut().then((value) async {
      await FirebaseMessaging.instance.unsubscribeFromTopic(widget.cntry!);
    }).then((value){
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => Login_Page()), (route) => false);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Center(
            child: Text(
             "Home",
        )),
        leading: Builder(
          builder: (context)=>IconButton(
            icon: FaIcon(FontAwesomeIcons.barsStaggered),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Favourite_order_new(widget.cntry)));
            },
          )
        ],
      ),

      //backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: FutureBuilder(
        builder: (context,stream) {
          future: getValue();
          return Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          userImg == ''
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.grey,
                                    child: CircleAvatar(
                                      radius: 65,
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          AssetImage('assets/images/pp_1.jpeg'),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.grey,
                                    child: CircleAvatar(
                                      radius: 65,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: userImg == null
                                          ? null
                                          : NetworkImage('${userImg}'),
                                    ),
                                  ),
                                ),
                          Text(
                            '${widget.uName}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          )
                        ],
                      ),
                    )),
                ListTile(
                  title: Text(
                    'Recent Orders',
                    style: TextStyle(color: Colors.black54, fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Customer_Recent_Orders()));
                  },
                ),

                ListTile(
                  title: Text(
                    'Settings',
                    style: TextStyle(color: Colors.black54, fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Customer_Settings())).then((value){
                              setState((){});
                    }
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    'Log Out',
                    style: TextStyle(color: Colors.black54, fontSize: 20),
                  ),
                  onTap: () {
                    _signOut();
                  },
                ),
              ],
            ),
          );
        }
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            ListTile(
              title: Text(
                'No New Notifications',
                style: TextStyle(color: Colors.black54, fontSize: 20),
              ),
              onTap: () async {
                // print('tapped');
                // String sms = 'hello';
                //  String  number = "01766424191";
                //   var response = await http.post(Uri.parse("http://sms.felnadma.com/api/v1/send?api_key=44516430986385661643098638&contacts=$number&senderid=8801847431161&msg=$sms"));
                //   print('res ${response.statusCode}');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Promotion_dash()));
              },
            ),
            ListTile(
              title: Text(
                'btn',
                style: TextStyle(color: Colors.black54, fontSize: 20),
              ),
              onTap: () async {
                await FirebaseMessaging.instance.subscribeToTopic("all");
              },
            ),
          ],
        ),
      ),
      body:
       SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi, ${widget.uName}',style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.purple,fontSize: 16,fontWeight: FontWeight.bold)),),
                        SizedBox(
                          height: 5,
                        ),
                        Text('Welcome to YoBerries',style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.purple,fontSize: 22,fontWeight: FontWeight.bold)),)
                      ],
                    ),
                  ),
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('promotion_image')
                      .doc(widget.cntry)
                      .collection('promo_img')
                      .where('isActive', isEqualTo: true)
                      .where('expiryDate', isGreaterThanOrEqualTo: todayF)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      print(snapshot.data!.size);
                      snapshot.data!.docs.forEach((element) {
                        print(element.id);
                      });
                      return Column(
                        children: snapshot.data!.docs.map((document) {
                          return Padding(
                            padding: EdgeInsets.all(15),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Order_Now(widget.cntry)));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3.0,
                                        spreadRadius: 0.3,
                                        offset: Offset(0, 5)),
                                  ],
                                ),
                                child: FittedBox(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      document['img'],
                                      fit: BoxFit.fill,
                                      width: 640,
                                      height: 320,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 70,
                )
              ],
            ),
          ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => User_QR_Payment_New(widget.cntry)));
        },
        backgroundColor: Colors.purple,
        label: Text('Scan In Store'),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            title: Text('App version 1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
