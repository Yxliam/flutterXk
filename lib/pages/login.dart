import "package:flutter/material.dart";
import "package:redux/redux.dart";
import "../util/toast.dart";
import 'package:flutter_redux/flutter_redux.dart';
import "../state.dart";
import 'package:flutter/services.dart';
import "../api/http.dart";
import "../util/utils.dart";
import "../model/login_model.dart";
//import 'package:shared_preferences/shared_preferences.dart';
import "dart:convert";
import "../util/cach.dart";

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _userName;
  String _userPassword;

   _onSubmit(context,store) {
    final form = _formKey.currentState;
    form.save();
    if (_userName.isEmpty) {
      ToastMsg.show('手机号不能为空');
      return;
    }
    if(!Utils.isChinaPhoneLegal(_userName)){
      ToastMsg.show('手机号错误');
      return;
    }
    if (_userPassword.isEmpty) {
      ToastMsg.show('密码不能为空');
      return;
    }
    var formData = {
        'userName':_userName,
      'password':_userPassword
    };
    //异步提交
    loginHttp(context,store,formData);

  }
   loginHttp(context,store,formData) async{
    ToastMsg.loading(context,'登录中...');
    try{
      var result = await HttpUtil().post('login',data:formData);
      var data = LoginModel.fromJson(result);
      ToastMsg.hideLoading(context);
      if(data.errno == 0){
        ToastMsg.show('登录成功');
        // 通过 store.dispatch 函数，可以发出 action（跟 Redux 是一样的），而 Action 是在
        // AppState 中定义的枚举 Actions.login
        store.dispatch(new LoginSuccessAction(account: json.encode(data.data)));
        Cachs.set('userInfo', data.data);
        Navigator.pushNamed(context, '/home');
      }else{
        ToastMsg.show(data.errmsg);
      }
    }catch(e){
      ToastMsg.hideLoading(context);
    };



   }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (context, store) {
          return Scaffold(
              backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
              appBar: AppBar(
                  title: Text('登录'),
                  centerTitle: true,
                  backgroundColor: Color.fromRGBO(95, 101, 175, 1),
                  actions: [
                    Container(
                        margin: EdgeInsets.only(top: 15, right: 15),
                        child:
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text('注册', style: TextStyle(fontSize: 18)),
                        )
                    )
                  ]
              ),
              body: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        height: 100.0,
                        margin: EdgeInsets.only(top: 10.0),
                        child: Image.asset(
                            'images/logo.png',
                            fit: BoxFit.contain),
                      ),
                      Container(
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.all(
                                Radius.circular(5.0))),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              cursorColor: Colors.grey,
                              //键盘展示为号码
                              keyboardType: TextInputType.phone,
                              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],//只允许输入数字
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10.0),
                                  hintText: '手机号',
                                  border: InputBorder.none),
                              onSaved: (value) {
                                _userName = value;
                              },
                            ),
                            Divider(height: 1.0,),
                            TextFormField(
                              cursorColor: Colors.grey,
                                obscureText: true,//密码框不显示
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10.0),
                                  hintText: '密码',
                                  border: InputBorder.none),
                              onSaved: (value) {
                                _userPassword = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10.0, right: 10, top: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Expanded(
                                child: Builder(
                                  builder: (context) =>
                                      RaisedButton(
                                        child: Text('登录',
                                          style: TextStyle(fontSize: 18),),
                                        color: Color.fromRGBO(95, 101, 175, 1),
                                        textColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                        ),
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        onPressed: (){
                                          _onSubmit(context,store);
                                        },
                                      ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ))
          );
        }
    );
  }
  }
