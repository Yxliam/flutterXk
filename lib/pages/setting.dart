import 'package:flutter/material.dart';
import "package:redux/redux.dart";
import 'package:flutter_redux/flutter_redux.dart';
import "../state.dart";
import "dart:convert";
import "./about.dart";
import "../util/app_navigator.dart";

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (context, store) {
          var userState = store.state.auth.account;
          if(userState != null){
            userState = json.decode(store.state.auth.account);
          }
          return Scaffold(
            backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
            appBar: AppBar(
              title: Text('设置'),
              elevation: 0,
              centerTitle: true,
              backgroundColor: Color.fromRGBO(95, 101, 175, 1),
            ),
            body: Column(
              children: <Widget>[
                UserWidge(store,userState),
                blankWidget(),
                AboutWidge(),
              ],
            ),
          );
        });
  }

  Widget faceImg(store,userState){
    if(store.state.auth.isLogin){
      return FadeInImage.assetNetwork(
        placeholder: 'images/load.png',
        image: userState['head_portrait'],
        width: 60,
        height: 60,fit: BoxFit.cover);
    }else{
      return Icon(IconData(0xe62f,fontFamily: 'Yicon'),size: 50,);
    }
  }

  Widget UserWidge(store,userState) {

    return GestureDetector(
      onTap: () {
        if(store.state.auth.isLogin){
          Navigator.pushNamed(context, '/my_setting');
        }else{
          Navigator.pushNamed(context, '/login');
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
//        boxShadow: [
//          BoxShadow(
//              color: Color.fromRGBO(220, 220, 220, 1.0),
//              offset: Offset(0.0, 5.0),
//              blurRadius: 5.0)
//        ]
        decoration: BoxDecoration(color: Colors.white,),
        child: Row(
          children: <Widget>[
            ClipOval(
                child: Container(
              width: 60,
              height: 60,
                    child: faceImg(store,userState),
            )),
            IsLogin(store,userState),
            Container(
              child: Icon(
                IconData(0xe63f, fontFamily: 'Yicon'),
                size: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget IsLogin(store,userState){
    if(store.state.auth.isLogin){
      return  Expanded(
        child: Container(
          margin: EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(userState !=null ? userState['nickname']:'', style: TextStyle(fontSize: 16)),
              Text('已登录',
                  style: TextStyle(fontSize: 14, color: Colors.grey))
            ],
          ),
        )
      );
    }else{
      return Expanded(
        child: Container(
          margin:EdgeInsets.only(left:10),
          child:   Text('未登录',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        )
      );
    }
  }

  Widget blankWidget() {
    return Container(
      height: 20,
    );
  }

  Widget AboutWidge() {
    return GestureDetector(
      onTap: (){
        AppNavigator.push(context, About());
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white
//          border: new Border.all(
//            //添加边框
//            width: 1.0, //边框宽度
//            color: Colors.grey, //边框颜色
//          ),
            ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('关于学课'),
            ),
            Container(
              child: Icon(
                IconData(0xe63f, fontFamily: 'Yicon'),
                size: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
