import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:yo_berry_2/admin_screen/upload_promotion_image.dart';

class Promotion_Image_Country extends StatefulWidget {
  const Promotion_Image_Country({Key? key}) : super(key: key);

  @override
  State<Promotion_Image_Country> createState() =>
      _Promotion_Image_CountryState();
}

class _Promotion_Image_CountryState extends State<Promotion_Image_Country> {
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
        title: Text('Select Country'),
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
                                      builder: (context) =>
                                          Upload_Promotion_Image(
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
                        Divider(
                          color: Colors.grey[900],
                        )
                      ],
                    );
                  }),
            );
          }),
    );
  }
}
