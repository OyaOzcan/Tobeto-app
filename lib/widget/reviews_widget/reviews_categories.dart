import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tobeto_app/widget/reviews_widget/reviews_exam.dart';

final List<Map<String, dynamic>> reviewCategories = [
  {
    'title': 'Front End',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color':  Color(0xFFe950a4),
  },
  {
    'title': 'Full Stack',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color': Color(0xff13c3a4),
  },
  {
    'title': 'Back End',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color':  Color(0xFF5588e0),
  },
  {
    'title': 'Microsoft SQL Server',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color':  Color(0xFF9a33ff),
  },
  {
    'title': 'Masaüstü Programlama',
    'icon': Icons.list_outlined,
    'buttonText': 'Başla',
    'color': Colors.orange,
  },
];

void showReviewCategoryDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder(
        future: fetchReviewData(title),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No data available"));
          }
          var reviewData = snapshot.data!;
          return AlertDialog(
            title: Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "${reviewData['subtitle']}",
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Text(
                    "Sınav Süresi: ${reviewData['exam duration']}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "Soru Sayısı: ${reviewData['number of questions']}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "Soru Tipi: ${reviewData['question type']}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReviewsExam(
                                  examTitle: '$title',
                                )),
                      );
                    },
                    child: Text('Sınava Başla'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

Future<Map<String, dynamic>> fetchReviewData(String title) async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  List<dynamic> reviewCards = userDoc['reviews-card'] ?? [];
  Map<String, dynamic>? reviewData;
  for (String reviewId in reviewCards) {
    DocumentSnapshot reviewDoc = await FirebaseFirestore.instance
        .collection('reviews-card')
        .doc(reviewId)
        .get();
    if (reviewDoc.exists && reviewDoc['title'] == title) {
      reviewData = {
        'subtitle': reviewDoc['subtitle'], 
        'exam duration': reviewDoc['exam duration'],
        'number of questions': reviewDoc['number of questions'],
        'question type': reviewDoc['question type'],
      };
      break;
    }
  }

  return reviewData ??
      {
        'subtitle': 'N/A',
        'exam duration': 'N/A',
        'number of questions': 'N/A',
        'question type': 'N/A',
      };
}
