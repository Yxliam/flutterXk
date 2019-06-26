import "package:flutter/material.dart";
import "../util/toast.dart";
import "dart:convert";
import "../api/http.dart";
import "../model/login_model.dart";
import "../util/app_navigator.dart";
import "./me.dart";
import "./root.dart";


class StepsLook extends StatefulWidget {
  @override
  _StepsLookState createState() => _StepsLookState();
}

class _StepsLookState extends State<StepsLook> {
  var radio;

  @override
  void initState() {
    super.initState();
    radio = '1';
  }

  @override
  Widget build(BuildContext context) {
    /* 接收参数 */
    var resultData = ModalRoute.of(context).settings.arguments;


    saveHandle() async{
      var newResult = json.decode(json.encode(resultData));
      newResult['public'] = radio;
      print( newResult );
      ToastMsg.loading(context,'保存中..');
      try{
        var result = await HttpUtil().post('saveWord',data:json.encode(newResult));
        var data = LoginModel.fromJson(result);
        ToastMsg.hideLoading(context);
        if(data.errno == 0){
          ToastMsg.show('保存成功');
          AppNavigator.pushAndRemoveUntil(context,Root(index:2));

        }else{
          ToastMsg.show(data.errmsg);
        }
      }catch(e){
        ToastMsg.hideLoading(context);
      };

    }

    return Scaffold(
        appBar: AppBar(
          title: Text('设置'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color.fromRGBO(95, 101, 175, 1),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                saveHandle();
              },
              child: Container(
                margin: EdgeInsets.only(right: 20, top: 15),
                child: Text('完成', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 20, left: 20, bottom: 5),
                  child: Text('谁可以看到',
                      style: TextStyle(
                          color: Color.fromRGBO(79, 79, 79, 1), fontSize: 16)),
                ),
                RadiosBox(),
              ],
            ),
          ],
        ));
  }



  Widget RadiosBox() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(height: 1),
        Container(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text('公开', style: TextStyle(fontSize: 16)),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          '允许分享给所有人',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(105, 105, 105, 1)),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.bottomRight,
                    child: new Radio(
                      groupValue: '1',
                      value: radio.toString(),
                      onChanged: (String val) {
                        // val 与 value 的类型对应
                        setState(() {
                          radio = 1;
                        });
                      },
                    ),
                  )),
                ],
              ),
              Divider(height: 1),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text('私密', style: TextStyle(fontSize: 16)),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          '仅自己可见,不可分享',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(105, 105, 105, 1)),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.bottomRight,
                    child: new Radio(
                      groupValue: '2',
                      value: radio.toString(),
                      onChanged: (String val) {
                        // val 与 value 的类型对应
                        setState(() {
                          radio = 2;
                        });
                      },
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}
