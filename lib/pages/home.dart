import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import "package:redux/redux.dart";
import 'package:flutter_redux/flutter_redux.dart';
import "../state.dart";
import "../api/http.dart";
import "../model/login_model.dart";
import "../util/toast.dart";
import "../util/app_navigator.dart";
import "dart:convert";
import "./detail.dart";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RefreshController refreshController;
  int page = 1;
  var recommendList = [];

  onRefresh() {
    getList(1);
    setState(() {
      refreshController.refreshCompleted();
    });
  }

  onLoading() {
    loadMore();
  }

  getList(page) async{
    var result = await HttpUtil().get('allWordList',data:{'page':page});
    var data = LoginModel.fromJson(result);
    if(data.errno == 0){
       setState(() {
         recommendList = data.data['data'];
       });
       if(data.data['totalPages'] == data.data['currentPage']){
         refreshController.loadNoData();
       }else{
         setState(() {
           page++;
         });
       }
    }else{
      ToastMsg.show(data.errmsg);
    }
  }

  loadMore() async{
    print('load');
    var result = await HttpUtil().get('allWordList',data:{'page':page});
    var data = LoginModel.fromJson(result);
    if(data.errno == 0){
      if(data.data['data'].length != 0){
        setState(() {
          recommendList.addAll(data.data['data']);
           page ++;
          refreshController.loadComplete();
        });
      }else{
        refreshController.loadNoData();
      }
    }else{
      ToastMsg.show(data.errmsg);
    }
  }



  @override
  void initState() {
    super.initState();
    getList(page);

    refreshController = RefreshController();

  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    return StoreConnector<AppState,Store<AppState>>(
        converter: (store) => store,
        builder: (context,store){
          return Scaffold(
              backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
              appBar: AppBar(
                title: Text('广场'),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color.fromRGBO(95, 101, 175, 1),
              ),

              body: SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                header: WaterDropHeader(),
                footer: ClassicFooter(loadingText: '加载中...', idleText: "载入更多",noDataText:'已经加载完了'),
                onRefresh: onRefresh,
                onLoading: onLoading,
                child: ListView(
                  children: <Widget>[
                    _rocmmendWrap(),
                  ],
                ),
              ));
        });
  }

  Widget _rocmmendWrap() {
    return Container(
       padding:EdgeInsets.all(10),
      child: _recommdList(),
    );
  }

  Widget _recommdList() {
    if (recommendList.length != 0) {
      List<Widget> listWidget = recommendList.map((val) {
        return _item(val);
      }).toList();
      return Wrap(spacing: 10.0, runSpacing: 10.0, children: listWidget);
    } else {
      return
       Container(
         margin:EdgeInsets.only(top:200),
         child:  Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             Image.asset('images/none.png',width: 150,height:120,fit: BoxFit.contain,),
           ],
         ),
       );
    }
  }

  Widget isShowImg(item){
      if(item['cover'] != null){
        return FadeInImage.assetNetwork(
            placeholder: 'images/load.png',
            image: "${item['cover']}",
            width: ScreenUtil().setWidth(200),
            fit: BoxFit.cover,
            height: ScreenUtil().setHeight(200));
      }else{
        return Image.asset('images/logo.png', width: ScreenUtil().setWidth(200),height: ScreenUtil().setHeight(200),fit:BoxFit.contain);
      }
  }

  Widget _item(item) {
    return InkWell(
      onTap: () {},
      child: GestureDetector(
          onTap: () {
           AppNavigator.push(context, Detail(item['userId'],item['id']));
          },
          child: Container(
            decoration:
                BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
              new BoxShadow(
                color: const Color(0x000000),
                blurRadius: 3.0,
                spreadRadius: 10.0,
                offset: Offset(10.0, 10.0),
              ),
            ]),
            padding: EdgeInsets.only(bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: ScreenUtil().setWidth(345),
                  height: ScreenUtil().setHeight(300),
                  child: isShowImg(item),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                    width: ScreenUtil().setWidth(345),
                  child: Text("${item['title']}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                      )),
                ),
                Container(
                  width: ScreenUtil().setWidth(345),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        margin: EdgeInsets.only(right: 10),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              IconData(0xe630, fontFamily: 'YIcon'),
                              size: 14,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 2),
                              child: Text("${item['read']}",
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left:20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin:EdgeInsets.only(bottom:2),
                              child:   Icon(
                                  IconData(0xe60c,
                                      fontFamily: 'YIcon'),
                                  size: 12),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 2),
                              child: Text("${item['like']}",
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
