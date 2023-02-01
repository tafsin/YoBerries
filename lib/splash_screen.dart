import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yo_berry_2/admin_screen/admin_dashboard.dart';
import 'package:yo_berry_2/screens/btm_nav.dart';
import 'package:yo_berry_2/screens/home_screen.dart';
import 'package:yo_berry_2/screens/login_screen.dart';
import 'package:yo_berry_2/store_screens/store_dashboard.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({Key? key}) : super(key: key);

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  late Widget currentPage;

  bool isActive = false;
  final _auth = FirebaseAuth.instance;
  String? country = '';
  String? userName = '';
  String? imgUrl = '';
  String? role ='';
  String? email='';
  String ? uid ='';

  @override
  void initState() {
    print('splash');

    getUserLocal();
    super.initState();
    //getUser();
  }
  //
  // getUser() {
  //   print('get user');
  //   FirebaseAuth.instance.userChanges().listen((User? user) async {
  //     Loader.show(context);
  //     if (user == null) {
  //
  //       Loader.hide();
  //       print('user null true');
  //       // await FirebaseMessaging.instance.unsubscribeFromTopic("Bangladesh");
  //       // await FirebaseMessaging.instance.unsubscribeFromTopic('USA');
  //
  //
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => Home_Screen()));
  //
  //     }
  //     else if (user != null) {
  //       print('get user not null');
  //       Loader.hide();
  //
  //       await loadUser();
  //       await navigate();
  //     }
  //   });
  // }
  getUserLocal()async{
    print('called');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState((){
      country = sharedPreferences.getString('country');
      role = sharedPreferences.getString('role');
      userName = sharedPreferences.getString('userName');
      imgUrl = sharedPreferences.getString('imgUrl');
      email = sharedPreferences.getString('email');
      uid = sharedPreferences.getString('uid');
      
      
    });
    if(email != null){
      if(role == 'admin'){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Admin_DashBoard()));

      }
      else if(role == 'customer'){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Btm_Nav(country, uid, userName, imgUrl)));

      }
      else if(role == 'store'){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Store_Dashboard()));

      }

    }
    else{
      print('else');
      Navigator.push(context, MaterialPageRoute(builder: (context)=>Home_Screen()));

    }


  }

  String userId = '';

  //bool isActive = false;
  // loadUser() async {
  //   print("loadUser3333");
  //
  //   var currentUser = await FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     print(currentUser.uid);
  //     userId = await currentUser.uid;
  //
  //     var roleType = await roleStream();
  //     print('splash login $roleType');
  //
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .get()
  //         .then((value) {
  //       if (value['role'] == 'customer') {
  //         Loader.show(context);
  //         print('if');
  //         setState(() {
  //           country = value['country'];
  //           imgUrl = value['imageUrl'];
  //           userName = value['userName'];
  //           currentPage = Btm_Nav(
  //             country,
  //             userId,
  //             userName,
  //             imgUrl,
  //           );
  //         });
  //         //Navigator.push(context, MaterialPageRoute(builder: (context)=> Admin_Page()));
  //         Loader.hide();
  //       } else if (value['role'] == 'admin') {
  //         Loader.show(context);
  //         print('else');
  //         setState(() {
  //           currentPage = Admin_DashBoard();
  //         });
  //         //Navigator.push(context, MaterialPageRoute(builder: (context)=> Employee_Dashboard()));
  //         Loader.hide();
  //       } else if (value['role'] == 'store') {
  //         Loader.show(context);
  //         print('else');
  //         setState(() {
  //           currentPage = Store_Dashboard();
  //         });
  //         //Navigator.push(context, MaterialPageRoute(builder: (context)=> Supervisor_Screen()));
  //         Loader.hide();
  //       }
  //     });
  //   } else {
  //     print('user Nai');
  //   }
  // }

  Future<String> roleStream() async {
    var rType = '';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((value) {
        rType = value['role'];
      });
    } catch (e) {
      print(e);
    }
    return rType;
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  navigate() {
    //print('nav');

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => currentPage));
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}