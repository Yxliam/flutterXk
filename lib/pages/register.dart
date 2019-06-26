import "package:flutter/material.dart";
import "../util/toast.dart";
import 'dart:async';
import 'package:flutter/services.dart';
import "../api/http.dart";
import "../util/utils.dart";
import "../model/login_model.dart";

class Rigister extends StatefulWidget {
  @override
  _RigisterState createState() => _RigisterState();
}

class _RigisterState extends State<Rigister> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _userName;
  String _userPassword;
  String _userPasswordConfig;
  String _code;
  Timer _timer;
  int _countdownTime = 0;

  void timeCount (){
    if(_countdownTime == 0){
      setState(() {
        _countdownTime = 60;
      });
      //开始倒计时
      startCountdownTimer();
    }
  }

  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);

    var callback = (timer) => {
    setState(() {
      if (_countdownTime < 1) {
        _timer.cancel();
      } else {
        _countdownTime = _countdownTime - 1;
      }
    })
  };

    _timer = Timer.periodic(oneSec, callback);
  }



  void _onSubmit(context){
    final form = _formKey.currentState;
    form.save();
    if(_userName.isEmpty){
      ToastMsg.show('手机号不能为空');
      return;
    }
    if(!Utils.isChinaPhoneLegal(_userName)){
      ToastMsg.show('手机号错误');
      return;
    }
    if(_userPassword.isEmpty){
      ToastMsg.show('密码不能为空');
      return;
    }
    if(_userPassword.length < 6){
      ToastMsg.show('密码不能小于6位');
      return;
    }

    if(_userPasswordConfig != _userPassword){
      ToastMsg.show('密码不一致');
      return;
    }

    var formData = {
      'userName':_userName,
      'password':_userPassword
    };
    //异步提交
    _registerPost(context,formData);

  }

  _registerPost(context,formData) async{
    ToastMsg.loading(context,'注册中');
    var result = await HttpUtil().post('register',data:formData);
    var data = LoginModel.fromJson(result);
    ToastMsg.hideLoading(context);
    if(data.errno == 0){
      ToastMsg.show('注册成功,请登录');
      Navigator.pushNamed(context, '/login');
    }else{
      ToastMsg.show(data.errmsg);
    }
  }

  @override
  void dispose() {
    super.dispose();
    //清除定时器
    if (_timer != null) {
      _timer.cancel();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
        appBar: AppBar(
          title: Text('注册'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(95, 101, 175, 1),
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
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        cursorColor: Colors.grey,
                        maxLines: 1,
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
                      Divider(
                        height: 1.0,
                      ),
//                      Row(
//                        children: <Widget>[
//                          Container(
//                            width: 220,
//                            child: TextFormField(
//                              cursorColor: Colors.grey,
//                              //键盘展示为数字
//                              keyboardType: TextInputType.number,
//                              decoration: InputDecoration(
//                                  contentPadding: EdgeInsets.all(10.0),
//                                  hintText: '短信验证码',
//                                  border: InputBorder.none),
//                              onSaved: (value) {
//                                _code = value;
//                              },
//                            ),
//                          ),
//                          Expanded(
//                            child: RaisedButton(
//                              onPressed: timeCount,
//                              child: Text(
//                                _countdownTime > 0 ? '$_countdownTime'+'s后重新获取' : '获取验证码'
//                              ,style: TextStyle(color: Colors.black54),),
//                            ),
//                          ),
//                        ],
//                      ),
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
                      Divider(
                        height: 1.0,
                      ),

                      TextFormField(
                        cursorColor: Colors.grey,
                        obscureText: true,//密码框不显示
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            hintText: '重复密码',
                            border: InputBorder.none),
                        onSaved: (value) {
                          _userPasswordConfig = value;
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
                            builder: (context) => RaisedButton(
                                  child: Text(
                                    '注册',
                                    style: TextStyle(fontSize: 18),
                                  ),
                              color: Color.fromRGBO(95, 101, 175, 1),
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  onPressed: (){
                                    _onSubmit(context);
                                  },
                                ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
