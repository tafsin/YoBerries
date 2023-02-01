import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:yo_berry_2/screens/login_screen.dart';
import 'package:yo_berry_2/screens/signup_screen.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({Key? key}) : super(key: key);

  @override
  _Home_ScreenState createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  final sliderImages = [
    'assets/images/image0.jpg',
    'assets/images/image4.jpg',
    'assets/images/image5.jpg',
    'assets/images/image3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
                child: CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: false,
                      viewportFraction: 1,
                      aspectRatio: 5.0,
                      initialPage: 4,
                      height: (MediaQuery.of(context).size.height - 100),
                      //padding: EdgeInsets.only (left: MediaQuery.of(context).size.width / 10);
                    ),
                    itemCount: sliderImages.length,
                    itemBuilder: (context, index, realIndex) {
                      final sliderImage = sliderImages[index];
                      return buildImage(sliderImage, index);
                    })),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
              child: Text(
            'Login /Sign Up',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.purple,
            ),
          )),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login_Page()));
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 2, color: Colors.purple)),
                  child: Icon(
                    Icons.login,
                    color: Colors.purple,
                    size: 30,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUp_Page()));
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 2, color: Colors.purple)),
                  child: Icon(
                    Icons.app_registration_outlined,
                    color: Colors.purple,
                    size: 30,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget buildImage(String sliderImage, int index) => Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        width: MediaQuery.of(context).size.width,
        color: Colors.grey,
        child: Image.asset(
          sliderImage,
          fit: BoxFit.cover,
        ),
      );
}
