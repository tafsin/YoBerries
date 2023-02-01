import 'package:cloud_firestore/cloud_firestore.dart';

String dateTimeFormatter(Timestamp data) {
  DateTime dateTime = data.toDate();
  String a = "";

  a = "${dateTime.hour.toString().padLeft(2, "0")}:${dateTime.minute.toString().padLeft(2, "0")} ${dateTime.day.toString().padLeft(2, "0")}/${dateTime.month.toString().padLeft(2, "0")}/${dateTime.year.toString().substring(2, 4).padLeft(2, "0")}";

  return a;
}
