import "package:flutter/material.dart";
import "../util/toast.dart";
import "../model/login_model.dart";
import "../api/http.dart";
import "../util/cach.dart";

class EditPassword extends StatefulWidget {
  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _oldPassword;
  String _userPassword;
  String _userPasswordConfig;
  int userId;


  getUserId(){
    Cachs.get('userInfo').then((res){
      setState(() {
        userId = res['id'];
      });
    });
  }


  void _onSubmit(context){
    final form = _formKey.currentState;
    form.save();
    if(_oldPassword.isEmpty){
      ToastMsg.show('原始密码不能为空');
      return;
    }
    if(_oldPassword.length < 6){
      ToastMsg.show('原始密码不能少于6位');
      return;
    }

    if(_userPassword.isEmpty){
      ToastMsg.show('新密码不能为空');
      return;
    }
    if(_userPassword.length < 6 ){
      ToastMsg.show('新密码不能小于6位');
      return;
    }

    if(_userPasswordConfig != _userPassword){
      ToastMsg.show('密码不一致');
      return;
    }

    var formData = {
      'userId':userId,
      'oldPassword':_oldPassword,
      'newPassword':_userPassword
    };
    //异步提交
    _registerPost(context,formData);

  }


  _registerPost(context,formData) async{
    ToastMsg.loading(context,'修改中');
    var result = await HttpUtil().post('editPassword',data:formData);
    var data = LoginModel.fromJson(result);
    ToastMsg.hideLoading(context);
    if(data.errno == 0){
      ToastMsg.show('修改成功,请重新登录');
      Navigator.pushNamed(context, '/login');
    }else{
      ToastMsg.show(data.errmsg);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
        appBar: AppBar(
          title: Text('修改密码'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(95, 101, 175, 1),
        ),
        body: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
//                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        cursorColor: Colors.grey,
                        maxLines: 1,
                        obscureText: true,//密码框不显示,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            hintText: '原始密码',
                            border: InputBorder.none),
                        onSaved: (value) {
                          _oldPassword = value;
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
                            hintText: '新密码',
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
                                '确定',
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
            )));;
  }
}
