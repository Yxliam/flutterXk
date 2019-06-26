enum Actions{
  login,
  logout,
  LoginSuccess,
  LogoutSuccess
}

/// 这个类用来管理登录状态
class AuthState{
  bool isLogin;     //是否登录
  var account;   //用户信息
  AuthState({this.isLogin:false,this.account});

  @override
  String toString() {
    return "{account:$account,isLogin:$isLogin}";
  }
}




/// 定义所有action的基类
class Action{
  final Actions type;
  Action({this.type});
}

/// 定义Login成功action
class LoginSuccessAction extends Action{

  final String account;

  LoginSuccessAction({
    this.account
  }):super( type:Actions.LoginSuccess );
}


/// App 状态
///
/// 状态中所有数据都应该是只读的，所以，全部以 get 的方式提供对外访问，不提供 set 方法
class AppState {
  AuthState auth;     //登录

  AppState({this.auth});

//    // 持久化时，从 JSON 中初始化新的状态
//  static AppState fromJson(dynamic json) => json != null ? AppState(auth:) : AppState('');
//
//  // 更新状态之后，转成 JSON，然后持久化至持久化引擎中
//  dynamic toJson() => {'authorizationToken': _authorizationToken};

  @override
  String toString() {
    return "{auth:$auth}";
  }


//  /// J.W.T
//  var _authorizationToken;
//
//  // 获取当前的认证 Token
//  get authorizationToken => _authorizationToken;
//
//  // 获取当前是否处于已认证状态
//  get authed => _authorizationToken.length > 0;
//
//  // 持久化时，从 JSON 中初始化新的状态
//  static AppState fromJson(dynamic json) => json != null ? AppState(json['authorizationToken']) : AppState('');
//
//  // 更新状态之后，转成 JSON，然后持久化至持久化引擎中
//  dynamic toJson() => {'authorizationToken': _authorizationToken};
//
//  AppState(this._authorizationToken);
}

/// Reducer
//AppState reducer(AppState state, action) {
//  switch(action) {
//    case Actions.login:
//      return AppState('ss');
//    case Actions.logout:
//      return AppState('');
//    default:
//      return state;
//  }
//}

AppState mainReducer(AppState state, dynamic action){

  print("state charge :$action ");

  if(action is LoginSuccessAction){
    state.auth.isLogin = true;
    state.auth.account = action.account;
  }

  if(Actions.LogoutSuccess == action){
    state.auth.isLogin = false;
    state.auth.account = null;
  }

  print("state changed:$state");

  return state;
}