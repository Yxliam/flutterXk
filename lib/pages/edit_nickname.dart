import 'package:flutter/material.dart';
import "package:redux/redux.dart";
import 'package:flutter_redux/flutter_redux.dart';
import "../state.dart";
import "dart:convert";
import "../util/cach.dart";
import "../api/http.dart";
import "../model/login_model.dart";
import "../util/toast.dart";

class EditNickName extends StatefulWidget {
  EditNickName({Key key, @required this.nickName}) : super(key: key);
  final nickName;
  @override
  _EditNickNameState createState() => _EditNickNameState();
}

class _EditNickNameState extends State<EditNickName> {
  TextEditingController _nickController = TextEditingController();
  String nickEdit;
  int userId;
   @override
  void initState() {
    super.initState();
    //设置值
    _nickController.text = widget.nickName;
    getUserId();
  }
  getUserId(){
      Cachs.get('userInfo').then((res){
         setState(() {
           userId = res['id'];
         });
      });
  }

  changeHandle(res){
      if(res.toString().isEmpty) return;
     setState(() {
       nickEdit = res;
     });
  }

  submitHandle(store) async{
     var formData = {
       'nickname':nickEdit,
       'userId':userId
     };
    var result = await HttpUtil().post('editName',data:formData);
    var data = LoginModel.fromJson(result);
    if(data.errno == 0){
      ToastMsg.show(data.errmsg);
      // 通过 store.dispatch 函数，可以发出 action（跟 Redux 是一样的），而 Action 是在
      // AppState 中定义的枚举 Actions.login
      store.dispatch(new LoginSuccessAction(account: json.encode(data.data)));
      Cachs.set('userInfo', data.data);
      Navigator.of(context).pop();

    }else{
      ToastMsg.show(data.errmsg);
    }
  }



  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (context, store) {
          return Scaffold(
            backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
            appBar: AppBar(
                title: Text('昵称'),
                backgroundColor: Color.fromRGBO(95, 101, 175, 1),
                centerTitle: true,
                actions: [
                  Container(
                      margin: EdgeInsets.only(top: 15, right: 15),
                      child: GestureDetector(
                        onTap: (){
                          submitHandle(store);
                        },
                        child: Text('提交', style: TextStyle(fontSize: 18)),
                      ))
                ]),
            body: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.all(
                      Radius.circular(5.0))),
              child: TextField(
                controller: _nickController,
                cursorColor: Colors.grey,
                maxLength: 15,
                onChanged: changeHandle,
                decoration: InputDecoration(
                    counterText: "",//此处控制最大字符是否显示
                    contentPadding: EdgeInsets.all(10.0),
                    hintText: '昵称',
                    border: InputBorder.none),
              ),
            ),
          );
        });
  }
}
