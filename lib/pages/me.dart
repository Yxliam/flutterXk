import "package:flutter/material.dart";
import "package:redux/redux.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:async';
import 'dart:io';
import "../state.dart";
import "../util/cach.dart";
import "dart:convert";
import "../api/http.dart";
import "../util/app_navigator.dart";
import "../model/login_model.dart";
import "./detail.dart";
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import "package:dio/dio.dart";
import "../util/toast.dart";

class Me extends StatefulWidget {
  @override
  _MeState createState() => _MeState();
}

class _MeState extends State<Me> {
  RefreshController _refreshController;
  var userInfo;
  int userId;
  var recommendList = [];
  String faceImg;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    getUserId();

  }

  getList(id) async {
    var params = {'userId': id};
    var result = await HttpUtil().get('meWordList', data: params);
    var data = LoginModel.fromJson(result);
    if (data.errno == 0) {
      setState(() {
        recommendList = data.data['data'];
        _refreshController.refreshCompleted();
      });
    }
  }

  getUserId() {
    Cachs.get('userInfo').then((res) {
      if (res != null) {
        setState(() {
          userId = res['id'];
          faceImg = res['head_portrait'];
          userInfo = res;
        });
        getList(res['id']);
      }
    });
  }

  //系统相册
  _openGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    uploadFace(image);
  }

  uploadFace(image) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
    ToastMsg.loading(context, '上传中...');
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(
        new File(path),
        name,
      ),
      'userId': userId,
    });
    var result = await HttpUtil().post('uploadFace', data: formData);
    var data = LoginModel.fromJson(result);
    ToastMsg.hideLoading(context);
    if (data.errno == 0) {
      setState(() {
        faceImg = data.data['face'];
      });
      userInfo['head_portrait'] = data.data['face'];
      Cachs.set('userInfo', userInfo);
    } else {
      ToastMsg.show(data.errmsg);
    }
  }

  _onRefresh(){
    getList(userId);
  }

  @override
  void dispose() {
    super.dispose();
    _refreshController = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (context, store) {
          var userState = store.state.auth.account;
          if (userState != null) {
            userState = json.decode(store.state.auth.account);
          }
          return Scaffold(
              backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
              body: SmartRefresher(
                  header: WaterDropHeader(),
                  enablePullUp:false,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    slivers: <Widget>[
//                      SliverAppBar(
//                        pinned: true,
//                        expandedHeight: 60.0,
//                        elevation: 0,
//                        backgroundColor: Color.fromRGBO(95, 101, 175, 10),
//                        actions: <Widget>[
//                          Container(
//                            margin: EdgeInsets.only(right: 10),
//                            child: GestureDetector(
//                                onTap: () {
//                                  Navigator.pushNamed(context, '/setting');
//                                },
//                                child: Icon(
//                                  IconData(0xe60b, fontFamily: 'Yicon'),
//                                )),
//                          ),
//                        ],
//                        flexibleSpace: FlexibleSpaceBar(
//                          centerTitle: true,
//                          title: Text('我的', style: TextStyle(fontSize: 15.0)),
//                          background: Image.asset(
//                            'images/me-bg.png',
//                            fit: BoxFit.cover,
//                          ),
//                        ),
//                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Stack(
                            children: <Widget>[
                              Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      image: DecorationImage(
                                          image: AssetImage("images/bj.png"),
                                          fit: BoxFit.cover)),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: <Widget>[
                                            Face(store),
                                            Padding(
                                                padding:
                                                EdgeInsets.only(top: 10.0)),
                                            Text(
                                                userState != null
                                                    ? userState['nickname']
                                                    : '学课',
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    color: Colors.white)),
                                            LoginContain(store, userState),
                                          ],
                                        )
                                      ])),
                              Positioned(
                                right: 15.0,
                                top: statusBarHeight+10,
                                child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/setting');
                                },
                                child: Icon(
                                  IconData(0xe60b, fontFamily: 'Yicon'),color: Colors.white,
                                )),
                              ),
                            ],
                          ),
                        ]),
                      ),
                      isNone()
                    ],
                  )));
        });
  }

  Widget isShowImg(item) {
    if (item['cover'] != null) {
      return FadeInImage.assetNetwork(
          placeholder: 'images/load.png',
          image: "${item['cover']}",
          width: double.infinity,
          height: 150.0,
          fit: BoxFit.cover);
    } else {
      return Image.asset('images/logo.png',
          width: double.infinity, height: 150.0, fit: BoxFit.contain);
    }
  }

  Widget isNone() {
    if (recommendList.length == 0) {
      return SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 500.0,
            crossAxisSpacing: 0,
            mainAxisSpacing: 5.0,
            childAspectRatio: 0.8,
          ),
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'images/none.png',
                    width: 150,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  Container(
                    child:
                        Text('还没有作品,赶紧去发布吧!', style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
            );
          }, childCount: 1));
    } else {
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          crossAxisSpacing: 0,
          mainAxisSpacing: 5.0,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return GestureDetector(
                onTap: () {
                  AppNavigator.push(
                      context,
                      Detail(recommendList[index]['userId'],
                          recommendList[index]['id']));
                },
                child: Container(
//                          height: 300.0,
                  margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(color: Color(0x808080), blurRadius: 5.0)
                  ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      isShowImg(recommendList[index]),
//                  FadeInImage.assetNetwork( placeholder: 'images/load.png',  image: "${recommendList[index]['cover']}",fit: BoxFit.cover,width: double.infinity,height: 150.0),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("${recommendList[index]['title']}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                            )),
                      ),
                      Container(
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
                                    child: Text(
                                        "${recommendList[index]['read']}",
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(bottom: 2),
                                    child: Icon(
                                        IconData(0xe60c, fontFamily: 'YIcon'),
                                        size: 12),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 2),
                                    child: Text(
                                        "${recommendList[index]['like']}",
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
                ));
          },
          childCount: recommendList.length,
        ),
      );
    }
  }

  Widget Face(store) {
    if (store.state.auth.isLogin) {
      return ClipOval(
          child: GestureDetector(
              onTap: () {
                _openGallery();
              },
              child: Container(
                  width: 80,
                  height: 80,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'images/load.png',
                    image: faceImg,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ))));
    } else {
      return ClipOval(
          child: Container(
        width: 80,
        height: 80,
        child: Icon(
          IconData(0xe62f, fontFamily: 'Yicon'),
          size: 80,
          color: Colors.white,
        ),
      ));
    }
  }

  Widget LoginContain(store, userState) {
    if (store.state.auth.isLogin) {
      return Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Text(userState['signature'] ?? '精彩的人生,无需个性签名',
            style: TextStyle(color: Colors.white),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis),
      );
    } else {
      return OutlineButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        color: Colors.white,
        borderSide: BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child:
            Text('登录', style: TextStyle(color: Colors.white, fontSize: 14.0)),
      );
    }
  }
}
