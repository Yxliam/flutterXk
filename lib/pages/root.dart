import "package:flutter/material.dart";
import "package:redux/redux.dart";
import 'package:flutter_redux/flutter_redux.dart';
import "../state.dart";
import "./home.dart";
import "./me.dart";
import "./create.dart";



class Root extends StatefulWidget {
  Root({this.index});
  int index;
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root>  {

  int _curIndex;
  List<Widget> _tabPage;
  @override
  void initState() {
    super.initState();
    //初始化默认tab index
    if(widget.index !=null){
      setState(() {
        _curIndex = widget.index;
      });
    }else{
      _curIndex = 0;
    }

    _curIndex = 0;

    //初始化tab列表
    _tabPage = <Widget>[
      Home(),
      Home(),
      Me()
    ];

  }
  @override
  Widget build(BuildContext context) {

    return StoreConnector<AppState,Store<AppState>>(
      converter: (store) => store,
      builder: (context,store){
        return new Scaffold(
          //添加IndexedStack 为了解决页面切换的问题
          body:IndexedStack(
            index: _curIndex,
            children: _tabPage,
          ),
          floatingActionButton: Container(
            margin:EdgeInsets.only(top:20),
            child: FloatingActionButton(
              backgroundColor: Color.fromRGBO(95, 101, 175, 1),
              onPressed: () {
              //检测是否登录了，未登录跳转到登录
              if(!store.state.auth.isLogin){
                Navigator.pushNamed(context, '/login');
                return;
              }else{
                Navigator.push(context,new MaterialPageRoute(builder: (context){
                  return new Create();
                }));
              }

            },child: Icon(IconData(0xe61e,fontFamily: 'Yicon'),size:25),),
          ),
           floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
           bottomNavigationBar: BottomNavigationBar(
               onTap: (int index){
                 setState(() {
                   _curIndex = index;
                 });
               },
               currentIndex:_curIndex,
               items:[
                 BottomNavigationBarItem(
                     icon: Icon(Icons.home),
                     title: Text('广场')
                 ),
                 BottomNavigationBarItem(
                     icon: Icon(Icons.home),
                     title: Text('')
                 ),
                 BottomNavigationBarItem(
                     icon: Icon(Icons.people),
                     title: Text('我的')
                 )
               ] ),
        );
      },
    );
  }
}
