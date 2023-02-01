import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:yo_berry_2/admin_screen/view_sales.dart';

class View_Sales_Countries extends StatefulWidget {
  const View_Sales_Countries({Key? key}) : super(key: key);

  @override
  State<View_Sales_Countries> createState() => _View_Sales_CountriesState();
}

class _View_Sales_CountriesState extends State<View_Sales_Countries> {
  @override
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
                                      builder: (context) =>
                                          View_Sales(countryList[index])));
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
                                  // ElevatedButton(
                                  //     style: ElevatedButton.styleFrom(
                                  //         primary: Colors.purple
                                  //     ),
                                  //     onPressed: (){
                                  //
                                  //     }, child: Text('View Menu'))
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
