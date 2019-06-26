import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../state.dart';
import '../splash_screen.dart';
import './login.dart';
import './register.dart';
import './setting.dart';
import './my_setting.dart';
import './root.dart';
import './steps_look.dart';
import './detail.dart';

class MyApp extends StatelessWidget {
  // app store
  final Store<AppState> store;

  MyApp(this.store);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: new MaterialApp(
        title: '好课',
        debugShowCheckedModeBanner: false, //去掉模拟器右上角debug横幅
        theme: ThemeData(
          //#8188E1
        primarySwatch: Colors.indigo,
        ),
        routes: {
          '/home':(context)=>Root(),
          "/login":(context)=>Login(),
          "/register":(context)=>Rigister(),
          "/setting":(context)=>Setting(),
          "/my_setting":(context)=>MySetting(),
          "/step":(context)=>StepsLook(),
        },
        // home 为 root 页
        home: SplashScreen(),
      ),
    );
  }
}
