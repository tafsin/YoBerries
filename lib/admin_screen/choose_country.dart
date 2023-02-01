import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yo_berry_2/admin_screen/add_to_country_menu.dart';

import 'add_to_store_menu.dart';

class Choose_Country extends StatefulWidget {
  const Choose_Country({Key? key}) : super(key: key);

  @override
  State<Choose_Country> createState() => _Choose_CountryState();
}

class _Choose_CountryState extends State<Choose_Country> {
  List<dynamic> countryList = [];

  getCountries() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('countryArray')
        .get()
        .then((value) {
      countryList = value['countryArray'];
    });
    print('country list $countryList');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Choose a country first'),
      ),
      body: FutureBuilder(
          future: getCountries(),
          builder: (context, stream) {
            return Container(
              child: ListView.builder(
                  itemCount: countryList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Add_To_Country_Menu(
                                          countryList[index])));
                            },
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(countryList[index],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        DottedLine()
                      ],
                    );
                  }),
            );
          }),
    );
  }
}
