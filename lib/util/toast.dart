import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "../widgets/dialog_loading.dart";

class ToastMsg {
  static show(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  static cancel(){
    Fluttertoast.cancel();
  }
   /*
     网络加载提示
   * context 上下文
   * msg 提示语
   * */
  static loading(context,msg){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: msg,
          );
        });
  }
  /*
     隐藏loading
   * context 上下文
   * */
  static hideLoading(context){
    Navigator.of(context).pop();
  }

}