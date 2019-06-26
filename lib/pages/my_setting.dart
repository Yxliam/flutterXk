import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "package:redux/redux.dart";
import 'package:flutter_redux/flutter_redux.dart';
import "../state.dart";
import "dart:convert";
import "../util/cach.dart";
import "./edit_nickname.dart";
import "./signature_edit.dart";
import "../util/app_navigator.dart";
import "./edit_password.dart";
class MySetting extends StatefulWidget {
  @override
  _MySettingState createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (context, store) {
          var userState = store.state.auth.account;
          if (userState != null) {
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
                  TopSetting(userState),
                  blankWidget(),
                  Item('修改密码','',(){
                    AppNavigator.push(context, EditPassword());
                  },false),
                  blankWidget(),
                  InkWell(
                    onTap: (){
                      return showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text('提示'),
                              content: Text('你确定要退出登录吗?',style:TextStyle(fontSize: 16)),
                              actions: <Widget>[
                                new CupertinoButton(onPressed: () {
                                  Navigator.of(context).pop();
                                }, child: Text('取消')),
                                new CupertinoButton(onPressed: () {
                                  //退出登录
                                   Cachs.clear();
                                  store.dispatch( Actions.LogoutSuccess);
                                   //指将制定的页面加入到路由中，然后将其他所有的页面全部pop
                                   Navigator.of(context).pushNamedAndRemoveUntil('/home',(Route<dynamic> route)=>false );
                                }, child: Text('确认')),
                              ],
                            );
                          }
                      );
                    },
                    child: Container(
                      width:double.infinity,
                      padding:EdgeInsets.all(10.0),
                      color:Colors.white,
                      child: Text('退出当前账号',style:TextStyle(fontSize: 16,color:Colors.red),textAlign: TextAlign.center,)
                    ),
                  ),
                ],
              ));
        });
  }

  Widget blankWidget() {
    return Container(
      height: 20,
    );
  }


  Widget TopSetting(userState){
    return Container(
      color:Colors.white,
      child: Column(
        children: <Widget>[
          Item('账号',userState !=null ?userState['mobile']:'',(){},true),
          Divider(height:1,indent: 10,),
          Item('昵称',userState !=null ?userState['nickname']:'',(){
            AppNavigator.push(context, new EditNickName(nickName:userState['nickname']));
          },false),
          Divider(height:1,indent: 10,),
          Item('个性签名',userState !=null?userState['signature']:'未填写',(){
            AppNavigator.push(context, new SignAture(signature:userState['signature']));
          },false),
        ],
      ),
    );
  }

  Widget Item(text,txt,cb,show){
    var showJt;
    if(show){
      showJt = Divider(height: 0);
    }else{
      showJt = Container(
        margin:EdgeInsets.only(left:10),
        child: Icon(
          IconData(0xe63f, fontFamily: 'Yicon'),
          size: 18,
          color: Colors.grey,
        ),
      );
    }
    return GestureDetector(
      onTap: cb,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color:Colors.white),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(text,style:TextStyle(fontSize: 16)),
            ),
            Container(
              child: Text(txt,style:TextStyle(fontSize: 16)),
            ),
            showJt,
          ],
        ),
      ),
    );
  }






}
