import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:yo_berry_2/admin_screen/add_items_menu_store.dart';
import 'package:yo_berry_2/admin_screen/add_master_menu_new.dart';

import 'package:yo_berry_2/admin_screen/add_to_menu.dart';
import 'package:yo_berry_2/admin_screen/add_to_store_menu.dart';
import 'package:yo_berry_2/admin_screen/admin_redeem_point.dart';
import 'package:yo_berry_2/admin_screen/choose_country.dart';
import 'package:yo_berry_2/admin_screen/create_item_size.dart';
import 'package:yo_berry_2/admin_screen/create_items_catgory.dart';
import 'package:yo_berry_2/admin_screen/create_promo_code.dart';
import 'package:yo_berry_2/admin_screen/create_store.dart';
import 'package:yo_berry_2/admin_screen/notification_country.dart';
import 'package:yo_berry_2/admin_screen/promotion_image_country.dart';
import 'package:yo_berry_2/admin_screen/store_signUp.dart';
import 'package:yo_berry_2/admin_screen/view_promo_codes.dart';
import 'package:yo_berry_2/admin_screen/view_promotion_image.dart';
import 'package:yo_berry_2/admin_screen/view_sales.dart';
import 'package:yo_berry_2/admin_screen/view_sales_countries.dart';
import 'package:yo_berry_2/admin_screen/view_sales_report.dart';
import 'package:yo_berry_2/admin_screen/view_sales_report_country.dart';
import 'package:yo_berry_2/screens/login_screen.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'create_country.dart';

class Admin_DashBoard extends StatefulWidget {
  const Admin_DashBoard({Key? key}) : super(key: key);

  @override
  State<Admin_DashBoard> createState() => _Admin_DashBoardState();
}

class _Admin_DashBoardState extends State<Admin_DashBoard> {
  String? token;

  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) => Login_Page()), (route) => false);
  }

  @override
  void initState() {
    super.initState();
    requestPermission();

    loadFCM();

    listenFCM();
    getT();

    // FirebaseMessaging.instance.subscribeToTopic("Animal");
  }

  // checkPromoExpiry()async{
  //
  //
  // }
  getT() async {
    token = await FirebaseMessaging.instance.getToken();
    print('token $token');
  }

  sendNotification() async {
    var tokens = [];
    String token1 =
        'e96K90TIR2qKS7XxDuW11u:APA91bElofZT-8J9VoB9gf-PXADAh9CCKwRAmgZXg7qL2NX0sNeYGFxGEaujZ0Whmvp156vtY8WqGBYNlzn3BPKbUw7KI9aU8agOd11EyGVM0rTmPWDbU27sUlr2tDe_h66HSc9xxxOa';
    String token2 =
        'dg9fRVGxQmO0PNuw2VcFGr:APA91bHaG5Jfn07ljJnBkUIXXFrpwga726SZWeB6qMB8fFWgx7qGZHmj90BpP1fo6yLRh71l4TgrLwiSHP0suZjHFYaXXZKd6b3ntkGWt7_bNsvA9T4JOtpb7t9c7dFJbu4F0AVnN-xR';
    tokens.add(token1);
    tokens.add(token2);
    tokens.forEach((element) async {
      print('e $element');
      print(token);
      final endpoint = "https://fcm.googleapis.com/fcm/send";

      final header = {
        'Authorization':
            'key=AAAA3gbk_qA:APA91bEoU2IvOCI_fV8n938Q1fjITt6XKY4xYWkJoQcm7RfPIfmiCcrcl0GwSCM9iN2WRj5vJY3yCnzlqrv0ibZ8FP2MBW13qFQdmNdisOrvp-Du7Bkcjwqmj0tzzrDDUg8QS6HLtMlV',
        'Content-Type': 'application/json'
      };

      http.Response response = await http.post(Uri.parse(endpoint),
          headers: header,
          body: jsonEncode({
            "to": element, // topic name
            "notification": {
              "body": "YOUR NOTIFICATION BODY TEXT",
              "title": "YOUR NOTIFICATION TITLE TEXT",
              "sound": "default"
            }
          }));
      print(response.statusCode);
    });
  }

  sendTopicNotification() async {
    final endpoint = "https://fcm.googleapis.com/fcm/send";

    final header = {
      'Authorization':
          'key=AAAA3gbk_qA:APA91bEoU2IvOCI_fV8n938Q1fjITt6XKY4xYWkJoQcm7RfPIfmiCcrcl0GwSCM9iN2WRj5vJY3yCnzlqrv0ibZ8FP2MBW13qFQdmNdisOrvp-Du7Bkcjwqmj0tzzrDDUg8QS6HLtMlV',
      'Content-Type': 'application/json'
    };

    http.Response response = await http.post(Uri.parse(endpoint),
        headers: header,
        body: jsonEncode({
          "to": "/topics/all",
          "priority": "high",
          "notification": {
            "body": "promotion",
            "title": "YoBerries Promotion",
          }
        }));
    print(response.statusCode);
  }

  subcr() async {
    await FirebaseMessaging.instance.subscribeToTopic("all");
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Admin Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            ListTile(
              title: Text(
                'View Sales Report',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => View_Sales_Report_Country()));
              },
            ),
            ListTile(
              title: Text(
                'Send Notification',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Notification_Country()));
              },
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              title: Text(
                'Logout',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              onTap: () {
                _signOut();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Create_Store()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Create Store',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => View_Sales_Countries()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'View Sales',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Create_Items_Category()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Create \nItem Category',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Create_Item_Size()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Create Size',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Choose_Country()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Add To \nCountry Menu',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Add_To_Master_Menu_New()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Add Item to\nMaster Menu',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Create_Promo_Code()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Create\nPromo Code',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Admin_Redeem_Point()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Reward Redeem',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Create_Country()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Create\nCountry',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => View_Promo_Codes()));
                      },
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'View\nPromo Codes',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Promotion_Image_Country()));
                        },
                        child: Container(
                          height: 100,
                          width: 150,
                          margin: EdgeInsets.only(left: 8, right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              new BoxShadow(
                                color: Colors.grey,
                                blurRadius: 8.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Promotion ',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      View_Promotion_Image()));
                        },
                        child: Container(
                          height: 100,
                          width: 150,
                          margin: EdgeInsets.only(left: 8, right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              new BoxShadow(
                                color: Colors.grey,
                                blurRadius: 8.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'View Promotion',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //  ElevatedButton(onPressed: (){subcr();}, child: Text('sub')),
                // ElevatedButton(onPressed: (){sendNotification();}, child: Text('send')),
                // ElevatedButton(onPressed: () async {await sendTopicNotification();}, child: Text('send all'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
