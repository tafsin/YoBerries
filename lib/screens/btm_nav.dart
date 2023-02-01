import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yo_berry_2/screens/reward_point_screen.dart';
import 'package:yo_berry_2/screens/user_qr_payment_new.dart';
import 'package:yo_berry_2/screens/vouchers.dart';
import 'package:yo_berry_2/screens/welcome_page.dart';

import 'oder_now.dart';

class Btm_Nav extends StatefulWidget {
  // const Btm_Nav({Key? key}) : super(key: key);
  final String? country;
  final String? uid;
  final String? userName;
  final String? imgUrl;

  const Btm_Nav(this.country, this.uid, this.userName, this.imgUrl);

  @override
  State<Btm_Nav> createState() => _Btm_NavState();
}

class _Btm_NavState extends State<Btm_Nav> {
  late final pages;

  //String country ='';
  void initState() {
    super.initState();

    pages = [
      Welcome_Page(widget.country, widget.uid, widget.userName, widget.imgUrl),
      Order_Now(widget.country),
      Rewards_point_screen(widget.country),
      Vouchers(widget.country),
    ];
  }

  // getUserDetails() async {
  //   final user =
  //   await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get();
  //   try {
  //     if (user != null) {
  //       setState(() {
  //
  //         country = user['country'];
  //       });
  //       print('country $country');
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            indicatorColor: Colors.purple,
            labelTextStyle: MaterialStateProperty.all(TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey))),
        child: NavigationBar(
          elevation: 10,
          backgroundColor: Colors.white,
          height: 60,
          onDestinationSelected: (index) => setState(() {
            this.index = index;
          }),
          selectedIndex: index,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: Colors.grey,
              ),
              label: 'Home',
              selectedIcon: Icon(
                Icons.home,
                color: Colors.white,
              ),
            ),
            NavigationDestination(
              icon: Icon(
                Icons.speaker_phone_outlined,
                color: Colors.grey,
              ),
              label: 'Order',
              selectedIcon: Icon(
                Icons.speaker_phone_outlined,
                color: Colors.white,
              ),
            ),
            NavigationDestination(
              icon: Icon(
                Icons.card_giftcard,
                color: Colors.grey,
              ),
              label: 'Reward',
              selectedIcon: Icon(
                Icons.card_giftcard,
                color: Colors.white,
              ),
            ),
            NavigationDestination(
              icon: Icon(
                Icons.confirmation_num,
                color: Colors.grey,
              ),
              label: 'Vouchers',
              selectedIcon: Icon(
                Icons.confirmation_num,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
