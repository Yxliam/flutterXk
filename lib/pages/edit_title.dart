import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import "package:redux/redux.dart";
import 'package:flutter_redux/flutter_redux.dart';
import "../state.dart";

class EditTitle extends StatefulWidget {
  EditTitle({this.editText});
  String editText;
  @override
  _EditTitleState createState() => _EditTitleState();
}

class _EditTitleState extends State<EditTitle> {
  TextEditingController _edItControll = TextEditingController();

  void showToast(msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  @override
  void initState() {
    super.initState();
    _edItControll.text = widget.editText;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store<AppState>>(
    converter: (store) => store,
    builder: (context, store) {
      return Scaffold(
        appBar: AppBar(
          title: Text('编辑标题'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color.fromRGBO(95, 101, 175, 1),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pop(context,widget.editText);
              },
              child: Container(
                margin:EdgeInsets.only(right:20,top:15),
                child: Text('确定',style:TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
        body:Container(
          padding:EdgeInsets.all(10),
          child: TextField(
            controller: _edItControll,
            inputFormatters: [LengthLimitingTextInputFormatter(40)],//限制字数
              autofocus:true,
            maxLines: 6,
            onChanged: (text){
              if(text.length > 40){
                showToast('标题字数不能超过40字');
                return;
              }
              setState(() {
                widget.editText = text;
              });
            },
            style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                border:InputBorder.none,
                hintText: '不超过40字',
              ),
          ),
        )
      );
    });
  }
}
