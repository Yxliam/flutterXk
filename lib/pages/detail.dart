import 'package:flutter/material.dart';
import "package:flutter/cupertino.dart";
import "package:redux/redux.dart";
import 'package:flutter_redux/flutter_redux.dart';
import "../widgets/popup_window.dart";
import "../res/resources.dart";
import "../state.dart";
import 'package:flutter_sound/flutter_sound.dart'; //录音
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import "./create.dart";
import 'package:fluwx/fluwx.dart' as fluwx;
import "dart:convert";
import "../api/http.dart";
import "../model/login_model.dart";
import "../util/cach.dart";
import "../util/toast.dart";
import "../widgets/full_img.dart";
import 'package:photo_view/photo_view.dart';
import "../util/cach.dart";

class Detail extends StatefulWidget {
  Detail(this.userId, this.id);

  int id;
  int userId;

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> with TickerProviderStateMixin {
  //定义消息模板
  final List<Msg> _messages = <Msg>[];
  GlobalKey _addKey = GlobalKey();
  String _url = "/detail";
  String _title = "学课分享";
  String _thumnail = "assets://images/tmp.jpg";
  fluwx.WeChatScene scene = fluwx.WeChatScene.SESSION;
  int workId;
  var detailInfo;
  bool isLiked = false;
  int userId;
  int likeNum;

  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;
  double slider_current_position = 0.0;
  double max_duration = 1.0;
  String _recorderTxt = '0';
  String _playerTxt = '0';
  bool _isPlaying = false;

  getUserId() {
    Cachs.get('userInfo').then((res) {
      if (res != null) {
        setState(() {
          userId = res['id'];
        });
      }
    });
  }

  @override
  void initState() {
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.1);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
    super.initState();
    setState(() {
      workId = widget.id;
    });
    getDetail(widget.id, widget.userId);
    readHandle();
    _initFluwx();
    getUserId();
  }

  @override
  void dispose() {
    if (flutterSound.isPlaying) flutterSound.stopPlayer();

    super.dispose();
  }

  void startPlayer(String vliceUrl) async {
    String path = await flutterSound.startPlayer(vliceUrl);
    await flutterSound.setVolume(1.0);

    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          this.setState(() {
            this._isPlaying = true;
          });
        }
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void stopPlayer() async {
    try {
      String result = await flutterSound.stopPlayer();
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      this.setState(() {
        this._isPlaying = false;
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async {
    String result = await flutterSound.pausePlayer();
    print('pausePlayer: $result');
  }

  void resumePlayer() async {
    String result = await flutterSound.resumePlayer();
    print('resumePlayer: $result');
  }

  void seekToPlayer(int milliSecs) async {
    String result = await flutterSound.seekToPlayer(milliSecs);
    print('seekToPlayer: $result');
  }

  void getMsg(String txt, {img, voice, startPlayer, voliceUrl}) {
    Msg msg = new Msg(
      txt: txt ??= '',
      img: img,
      volice: voice,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
      player: startPlayer,
      voliceUrl: voliceUrl,
    );
    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
  }

  void _share() {
    var model = fluwx.WeChatShareWebPageModel(
        webPage: _url,
        title: _title,
        thumbnail: _thumnail,
        scene: scene,
        transaction: "hh");
    fluwx.share(model);
  }

  _initFluwx() async {
    await fluwx.register(
        appId: "wxd930ea5d5a258f4f",
        doOnAndroid: true,
        doOnIOS: true,
        enableMTA: false);
    var result = await fluwx.isWeChatInstalled();
    print("is installed $result");
  }

  readHandle() async {
    var result = await HttpUtil().get('readHandle', data: {'id': widget.id});
    var data = LoginModel.fromJson(result);
  }

  getDetail(id, userId) async {
    var result =
        await HttpUtil().get('getDetail', data: {'id': id, 'userId': userId});
    var data = LoginModel.fromJson(result);
    if (data.errno == 0) {
      setState(() {
        isLiked = data.data['isLike'];
        likeNum = data.data['like'];
      });
      if (data.data['content'].length > 0) {
        var list = data.data['content'];
        var len = data.data['content'].length;
        for (var i = 0; i < len; i++) {
          if (list[i]['txt'] != '') {
            getMsg(list[i]['txt']);
          } else if (list[i]['img'] != null) {
            getMsg('', img: list[i]['img']);
          } else {
            getMsg('',
                img: null,
                voice: '1',
                startPlayer: startPlayer,
                voliceUrl: list[i]['volice']);
          }
        }
      }

      setState(() {
        detailInfo = data.data;
      });
    } else {
      ToastMsg.show(data.errmsg);
    }
  }

  _delWorkHandle() async {
    var result = await HttpUtil().post('delWork', data: {'id': workId});
    var data = LoginModel.fromJson(result);
    if (data.errno == 0) {
      ToastMsg.show(data.errmsg);
      //指将制定的页面加入到路由中，然后将其他所有的页面全部pop
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      ToastMsg.show(data.errmsg);
    }
  }

  _likeHandle() async {
    var result = await HttpUtil()
        .get('likeHandle', data: {'id': workId, 'userId': userId});
    var data = LoginModel.fromJson(result);
    if (data.errno == 0) {
      setState(() {
        isLiked = true;
        likeNum = likeNum + 1;
      });
    } else {
      ToastMsg.show(data.errmsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (context, store) {
          return Scaffold(
            backgroundColor: Color.fromRGBO(232, 232, 232, 1),
            appBar: AppBar(
              title: Text("${detailInfo != null ? detailInfo['title'] : '标题'}"),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Color.fromRGBO(95, 101, 175, 1),
              actions: <Widget>[
                GestureDetector(
                  key: _addKey,
                  onTap: () {
                    //说明属于自己的
                    if(userId == detailInfo['userId']){
                      _showAddMenu();
                    }else{
                      showModalBottomSheet(context:context, builder: (context){
                          return new Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              InkWell(
                                onTap: (){
                                  Navigator.of(context).pop();
                                  _share();
                                },
                                child:Container(
                                  padding:EdgeInsets.fromLTRB(10,20,10,20),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        margin:EdgeInsets.only(right: 10),
                                        child: Icon(IconData(0xe628, fontFamily: 'Yicon'), size: 18),
                                      ),
                                      Text('微信分享',style: TextStyles.textDark16),
                                    ],
                                  ),
                                )
                              )
                            ],
                          );
                        });

                    }

                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 20, top: 15),
                    child: Text('操作', style: TextStyle(fontSize: 18)),
                  ),
                )
              ],
            ),
            //固定底部的
            bottomNavigationBar: BottomAppBar(child: BottomShip()),
            body: SafeArea(
              child: showDetail(),
            ),
          );
        });
  }

  Widget showDetail() {
    if (detailInfo != null) {
      return ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text("${detailInfo['title']}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Text(
                        "${detailInfo['create_time']}",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(131, 139, 139, 1)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Text(
                        "${detailInfo['nickname']}",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(131, 139, 139, 1)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Text(
                        '阅读',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(131, 139, 139, 1)),
                      ),
                    ),
                    Text("${detailInfo['read']}",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(131, 139, 139, 1)))
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (_, int index) => _messages[index],
                  itemCount: _messages.length,
                  reverse: true,
                  padding: new EdgeInsets.all(6.0),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  _showAddMenu() {
    final RenderBox button = _addKey.currentContext.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    var a = button.localToGlobal(
        Offset(button.size.width - 8.0, button.size.height - 12.0),
        ancestor: overlay);
    var b = button.localToGlobal(button.size.bottomLeft(Offset(0, -12.0)),
        ancestor: overlay);
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(a, b),
      Offset.zero & overlay.size,
    );
    showPopupWindow(
      context: context,
      fullWidth: false,
      isShowBg: true,
      position: position,
      elevation: 0.0,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Image.asset(
                'images/jt.png',
                width: 8.0,
                height: 4.0,
              ),
            ),
            Container(
              width: 120.0,
              height: 40.0,
              child: FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (context) {
                      return new Create(wid:workId);
                    }));
                  },
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0)),
                  ),
                  icon: Icon(IconData(0xe62e, fontFamily: 'Yicon'), size: 20),
                  label: Text("编辑", style: TextStyles.textDark14)),
            ),
            Container(width: 120.0, height: 0.6, color: Colours.line),
            Container(
              width: 120.0,
              height: 40.0,
              child: FlatButton.icon(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    return showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('提示'),
                            content: Text('你确定要删除这个作品吗?',
                                style: TextStyle(fontSize: 16)),
                            actions: <Widget>[
                              new CupertinoButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('取消')),
                              new CupertinoButton(
                                  onPressed: () {
                                    _delWorkHandle();
                                  },
                                  child: Text('确认')),
                            ],
                          );
                        });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0)),
                  ),
                  icon: Icon(IconData(0xe626, fontFamily: 'Yicon'), size: 20),
                  label: Text("删除", style: TextStyles.textDark14)),
            ),
            Container(width: 120.0, height: 0.6, color: Colours.line),
            Container(
              width: 120.0,
              height: 40.0,
              child: FlatButton.icon(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _share();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0)),
                  ),
                  icon: Icon(IconData(0xe628, fontFamily: 'Yicon'), size: 20),
                  label: Text("分享", style: TextStyles.textDark14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget likeIcon() {
    if (isLiked) {
      return Icon(IconData(0xe684, fontFamily: 'Yicon'),
          size: 20, color: Color.fromRGBO(95, 101, 175, 1));
    } else {
      return Icon(
        IconData(0xe683, fontFamily: 'Yicon'),
        size: 20,
      );
    }
  }

  Widget BottomShip() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(color: Color.fromRGBO(245, 245, 245, 1)),
      child: Row(
        children: <Widget>[
//          GestureDetector(
//            onTap: () {
//              print('点了喜欢');
//            },
//            child: Row(
//              children: <Widget>[
//                Container(
//                  child: Icon(
//                    IconData(0xe67c, fontFamily: 'Yicon'),
//                    size: 20,
//                  ),
//                ),
//                Container(
//                  margin: EdgeInsets.only(left: 5),
//                  child: Text(
//                    '评论 ${detailInfo}',
//                    style: TextStyle(fontSize: 14),
//                  ),
//                ),
//              ],
//            ),
//          ),
          Text(''),
          GestureDetector(
            onTap: () {
              if (isLiked) {
                ToastMsg.show('不能重复喜欢，谢谢支持');
              } else {
                if (userId == null) {
                  ToastMsg.show('啊哦，登录后才能操作!');
                } else {
                  _likeHandle();
                }
              }
            },
            child: Row(
              children: <Widget>[
                Container(
//                  margin: EdgeInsets.only(left: 20),
                  child: likeIcon(),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    '喜欢 ${detailInfo != null ? likeNum : 0}',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Msg extends StatelessWidget {
  Msg(
      {this.txt,
      this.img,
      this.volice,
      this.player,
      this.voliceUrl,
      this.animationController});

  final String txt;
  String img;
  String volice;
  var player;
  var voliceUrl;
  final AnimationController animationController;

  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.linearToEaseOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              child: new CircleAvatar(child: new Text('学课')),
            ),
            isPic(player, ctx),
          ],
        ),
      ),
    );
  }

  Widget isPic(startPlayer, context) {
    if (img != null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: FullScreenWrapper(
                          initialScale: PhotoViewComputedScale.contained,
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          maxScale: PhotoViewComputedScale.covered * 1,
                          imageProvider: NetworkImage(img),
                        ),
                      )));
        },
        child: Container(
            margin: EdgeInsets.only(left: 10),
            child: FadeInImage.assetNetwork(
              placeholder: 'images/load.png',
              image: img,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            )),
      );
    } else if (volice != null) {
      return Container(
        margin: EdgeInsets.only(left: 15),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new GestureDetector(
                onTap: () {
                  startPlayer(voliceUrl);
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 5, right: 10, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Text('', style: TextStyle(fontSize: 16)),
                      ),
                      Icon(
                        IconData(0xe63a, fontFamily: 'Yicon'),
                        size: 15,
                      ),
                      Positioned(
                          left: -18,
                          top: -1,
                          child: Icon(
                            IconData(0xe601, fontFamily: 'Yicon'),
                            size: 20,
                            color: Colors.white,
                          ))
                    ],
                  ),
                )),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(left: 15),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              margin: const EdgeInsets.only(top: 5.0),
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Text(txt, style: TextStyle(fontSize: 16)),
                  Positioned(
                      left: -22,
                      top: -1,
                      child: Icon(
                        IconData(0xe601, fontFamily: 'Yicon'),
                        size: 20,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
