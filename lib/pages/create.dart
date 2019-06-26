import "package:flutter/material.dart";
import "package:redux/redux.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart'; //录音
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:io';
import "../state.dart";
import "./edit_title.dart";
import "../api/http.dart";
import "../model/login_model.dart";
import "../util/toast.dart";
import "../util/cach.dart";
import "package:dio/dio.dart";
import "../widgets/full_img.dart";
import 'package:photo_view/photo_view.dart';

class Create extends StatefulWidget {
  Create({this.wid});

  int wid;

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<Create> with TickerProviderStateMixin {
  String editText;
  bool isShowInput;
  bool showBottom;
  bool isVolice; //是否语音
  var _imgPath;
  var coverImg;
  int userId;
  var detailInfo;

  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;
  String _recorderTxt = '0';
  String _playerTxt = '0';
  String _voliceUrl;
  double _dbLevel;
  double slider_current_position = 0.0;
  double max_duration = 1.0;

  TextEditingController _edItControll = TextEditingController();

  //定义消息模板
  final List<Msg> _messages = <Msg>[];

  //最后提交的数据
  final List _postList = [];

  @override
  void initState() {
    super.initState();
    getUserId();
    editText = '点击设置标题';
    isShowInput = true;
    showBottom = false;
    isVolice = false;
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.1);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  getUserId() {
    Cachs.get('userInfo').then((res) {
      if (res != null) {
        setState(() {
          userId = res['id'];
        });
        if (widget.wid != null) {
          getDetail(widget.wid, userId);
        }
      }
    });
  }

  getDetail(id, userId) async {
    var result =
        await HttpUtil().get('getDetail', data: {'id': id, 'userId': userId});
    var data = LoginModel.fromJson(result);
    if (data.errno == 0) {
      if (data.data['content'].length > 0) {
        var list = data.data['content'];
        var len = data.data['content'].length;
        setState(() {
          editText = data.data['title'];
          coverImg = data.data['cover'];
        });
        for (var i = 0; i < len; i++) {
          if (list[i]['txt'] != '') {
            _subNew(list[i]['txt']);
          } else if (list[i]['img'] != null) {
            _subNew('', img: list[i]['img']);
          } else {
            _subNew('',
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

  void startRecorder() async {
    try {
      String path = await flutterSound.startRecorder(null);

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

        this.setState(() {
          this._recorderTxt = txt.substring(0, 8);
          _voliceUrl = path;
        });
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        setState(() {
          this._dbLevel = value;
        });
      });

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  void stopRecorder() async {
    try {
      String result = await flutterSound.stopRecorder();
      print(result);
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }

      this.setState(() {
        this._isRecording = false;
      });
      var file = await fileUpload(result);
      _subNew('',
          img: null,
          voice: this._recorderTxt,
          startPlayer: startPlayer,
          voliceUrl: file);
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void startPlayer(String vliceUrl) async {
    String path = await flutterSound.startPlayer(vliceUrl);
    await flutterSound.setVolume(1.0);

    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          slider_current_position = e.currentPosition;
          max_duration = e.duration;

          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
          this.setState(() {
            this._isPlaying = true;
            this._playerTxt = txt.substring(0, 8);
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

  //系统相册
  _openGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    var newFile = await imgUpload(image);
    _subNew('', img: newFile);
  }

  //封面上传
  _coverGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(new File(path), name,
          contentType: ContentType.parse("image/$suffix"))
    });
    var result = await HttpUtil().post('uploadCover', data: formData);
    var data = LoginModel.fromJson(result);
    if (data.errno == 0) {
      setState(() {
        coverImg = data.data['cover'];
      });
    } else {
      ToastMsg.show(data.errmsg);
    }
  }

  imgUpload(file) async {
    print('读取文件');
    print(file);
    String path = file.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(
        new File(path),
        name,
      )
    });
    var result = await HttpUtil().post('uploadCover', data: formData);
    var data = LoginModel.fromJson(result);
    if (data.errno == 0) {
      return data.data['cover'];
    } else {
      ToastMsg.show(data.errmsg);
    }
  }

  fileUpload(file) async {
    var newFile = file.substring(7, file.length);
    var name = newFile.substring(newFile.lastIndexOf("/") + 1, newFile.length);
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(
        new File(newFile),
        name,
      )
    });
    var result = await HttpUtil().post('uploadCover', data: formData);
    var data = LoginModel.fromJson(result);
    if (data.errno == 0) {
      return data.data['cover'];
    } else {
      ToastMsg.show(data.errmsg);
    }
  }

  /*拍照*/
  _takePhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      showBottom = false;
    });
    if (image == null) {
      return;
    }
    var newFile = await imgUpload(image);
    _subNew('', img: newFile);
  }

  void _submitMsg(String txt) {
    if (txt.isEmpty) {
      return;
    }
    _edItControll.clear();
    _subNew(txt);
  }

  void _subNew(String txt, {img, voice, startPlayer, voliceUrl}) {
    Msg msg = new Msg(
      txt: txt ??= '',
      img: img,
      volice: voice,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
      player: startPlayer,
      voliceUrl: voliceUrl,
    );

    var Obj = {
      'txt': txt,
      'img': img,
      'volice': voliceUrl,
    };
    _postList.add(Obj);
    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    if (flutterSound.isPlaying) flutterSound.stopPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (context, store) {
          return Scaffold(
              backgroundColor: Color.fromRGBO(232, 232, 232, 1),
              appBar: AppBar(
                title: Text('编辑'),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color.fromRGBO(95, 101, 175, 1),
                actions: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (editText == '点击设置标题') {
                        ToastMsg.show('请设置标题');
                        return;
                      }
                      var resultData = {
                        'title': editText,
                        'userId': userId,
                        'cover': coverImg,
                        'public': '1',
                        'list': _postList
                      };
                      //传参数 arguments
                      Navigator.pushNamed(context, '/step',
                          arguments: resultData);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 20, top: 15),
                      child: Text('下一步', style: TextStyle(fontSize: 18)),
                    ),
                  )
                ],
              ),
              body: SafeArea(
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        // 触摸收起键盘
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {
                          showBottom = false;
                        });
                      },
                      child: Column(
                        children: <Widget>[
                          TopBg(),
                          Expanded(
                              child: new ListView.builder(
                            itemBuilder: (_, int index) => _messages[index],
                            itemCount: _messages.length,
                            reverse: true,
                            padding: new EdgeInsets.all(6.0),
                          )),
                          new Divider(
                            height: 1.0,
                            color: Color.fromRGBO(156, 156, 156, 1),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(245, 245, 245, 1)),
                            height: 50,
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ChangeBottom(),
                                ChangeBottomIcon(),
                                GestureDetector(
                                  onTap: _openGallery,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      IconData(0xe637, fontFamily: 'Yicon'),
                                      size: 36,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showBottom = !showBottom;
                                    });
                                  },
                                  child: Icon(
                                    IconData(0xe61c, fontFamily: 'Yicon'),
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          showBotton(),
                        ],
                      ))));
        });
  }

  Widget showBotton() {
    if (showBottom) {
      return Container(
        height: 140,
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: _takePhoto,
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              border: new Border.all(
                                  width: 2.0,
                                  color: Color.fromRGBO(207, 207, 207, 1))),
                          child: Icon(IconData(0xe600, fontFamily: 'Yicon'),
                              size: 40),
                        ),
                      ),
                      Text(
                        '拍摄',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      );
    } else {
      return Divider(height: 0);
    }
  }

  Widget ChangeBottomIcon() {
    if (isShowInput) {
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            controller: _edItControll,
            onSubmitted: _submitMsg,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return Expanded(
          child: GestureDetector(
              onTapDown: (details) {
                setState(() {
                  isVolice = true;
                });
                this.startRecorder();
              },
              onTapUp: (details) {
                setState(() {
                  isVolice = false;
                });
                this.stopRecorder();
              },
              child: isVolice
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 5, right: 10),
                      padding: EdgeInsets.only(left: 20, right: 20),
                      height: 38,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromRGBO(207, 207, 207, 1)),
                      child: Text('按住 说话',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w400)))
                  : Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 5, right: 10),
                      padding: EdgeInsets.only(left: 20, right: 20),
                      height: 38,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromRGBO(255, 255, 255, 1)),
                      child: Text('按住 说话',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w400)))));
    }
  }

  Widget ChangeBottom() {
    if (isShowInput) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isShowInput = false;
          });
        },
        child: Icon(
          IconData(0xe618, fontFamily: 'Yicon'),
          size: 32,
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            isShowInput = true;
          });
        },
        child: Icon(
          IconData(0xe624, fontFamily: 'Yicon'),
          size: 32,
        ),
      );
    }
  }

  Widget TopBg() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 120,
      decoration: BoxDecoration(
//          border: Border(top:BorderSide(color:Colors.red)),
          image: new DecorationImage(
              image: AssetImage('images/bj.png'), fit: BoxFit.fill)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _coverGallery();
            },
            child: Container(
                margin: EdgeInsets.only(right: 10),
                color: Colors.white,
                child: coverImg != null
                    ? FadeInImage.assetNetwork(
                        placeholder: 'images/load.png',
                        image: coverImg,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'images/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      )),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                  return new EditTitle(
                      editText: editText == '点击设置标题' ? '' : editText);
                })).then((result) {
                  //从设置标题的页面接收过来的参数
                  //需要判断是否为null的情况
                  if (result != null && result.toString().isNotEmpty) {
                    setState(() {
                      editText = result;
                    });
                  }
                  if (result.toString().isEmpty) {
                    setState(() {
                      editText = '';
                    });
                  }
                });
              },
              child: Text(editText == '' ? '点击设置标题' : editText,
                  style: TextStyle(fontSize: 18, color: Colors.white)),
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
          child: Tooltip(
            message: '删除',
            preferBelow: false,
            child: Container(
                margin: EdgeInsets.only(left: 10),
                child: FadeInImage.assetNetwork(
                  placeholder: 'images/load.png',
                  image: img,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )),
          ));
    } else if (volice != null) {
      return Tooltip(
          message: '删除',
          preferBelow: false,
          child: Container(
            margin: EdgeInsets.only(left: 15),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                    padding:
                        EdgeInsets.only(left: 5, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    margin: const EdgeInsets.only(top: 5.0),
                    child: GestureDetector(
                      onTap: () {
                        startPlayer(voliceUrl);
                      },
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
          ));
    } else {
      return GestureDetector(
          onLongPress: () {
            print('长按');
          },
          child: Tooltip(
              message: '删除',
              preferBelow: false, //上面弹出
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
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
              )));
    }
  }
}
