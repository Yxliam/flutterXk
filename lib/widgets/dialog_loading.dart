import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/*
*  公用dialog
*  params txt
* */

class LoadingDialog extends Dialog {
  final String text;

  LoadingDialog({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Material(
      type: MaterialType.transparency,
      child: new Center(
        child: new SizedBox(
          width: 150.0,
          height: 150.0,
          child: new Container(
            padding:EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: Color(0xffffffff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                childWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget childWidget() {
    Widget childWidget = new Stack(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
          child: new Center(
            child: SpinKitFadingCircle(
              color: Color.fromRGBO(95, 101, 175, 1),
              size: 40.0,
            ),
          ),
        ),
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
          child: new Center(
            child: new Text(text,maxLines:1,overflow:TextOverflow.ellipsis,style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
    return childWidget;
  }

}
