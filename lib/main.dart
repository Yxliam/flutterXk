import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import "dart:convert";
import "./util/cach.dart";

import 'pages/app.dart';
import 'state.dart';

void main() async {
  // 创建一个持久化器
//  final persistor = Persistor<AppState>(
//      storage: FlutterStorage(),
//      serializer: JsonSerializer<AppState>(AppState.fromJson),
//      debug: true
//  );

  // 从 persistor 中加载上一次存储的状态
//  final initialState = await persistor.load();

//  final store = Store<AppState>(
//      reducer,
//      initialState: initialState ?? AppState(''),
////      initialState:  AppState(''),
//      middleware: [persistor.createMiddleware()]
//  );

  loggingMiddleware(Store<AppState> store, action, NextDispatcher next) {
    print('${new DateTime.now()}: $action');
    next(action);
  }

  Store<AppState> store = new Store<AppState>(mainReducer,initialState: new AppState(
    auth: new AuthState(),
  ),middleware: [
    loggingMiddleware
  ]);

   Cachs.get('userInfo').then((res){
      if(res != null ){
        store.dispatch(new LoginSuccessAction(account: json.encode(res)));
      }
   });


  runApp(MyApp(store));
  if (Platform.isAndroid) {
// 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}