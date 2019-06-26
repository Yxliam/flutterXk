import 'package:flutter/material.dart';
import "../res/styles.dart";

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
        appBar: AppBar(
          title: Text('关于学课'),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color.fromRGBO(95, 101, 175, 1),
        ),
        bottomNavigationBar: BottomAppBar(
            elevation: 0,
            color: Color.fromRGBO(245, 245, 245, 1.0),
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text(
                '沙漏工作室',
                style: TextStyles.textBoldDark16,
                textAlign: TextAlign.center,
              ),
            )),
        body: Center(
          child: Container(
            width: 150.0,
            height: 100.0,
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 10.0),
            child: Image.asset('images/logo.png',
                alignment: Alignment.center, fit: BoxFit.contain),
          ),
        ));
  }
}
