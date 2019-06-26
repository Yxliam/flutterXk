const serviceUrl = 'http://192.168.14.125:8360/xk/';

const apiRoute = {
  'login':serviceUrl + 'login', // 登录
  'register':serviceUrl + 'register', // 注册
  'editName':serviceUrl +'editNickName',//更新名称
  'editSign':serviceUrl +'editSign',//更新个性签名
  'editPassword':serviceUrl +'editPassword',//更新密码
  'allWordList':serviceUrl +'allWordList',//查询所有的作品
  'meWordList':serviceUrl +'meWordList',//查询我的作品
  'uploadCover':serviceUrl +'uploadCover',//上传封面
  'saveWord':serviceUrl +'saveWord',//保存作品
  'getDetail':serviceUrl +'getDetail',//获取详情
  'readHandle':serviceUrl +'readHandle',//阅读数
  'delWork':serviceUrl +'delWork',//删除作品
  'likeHandle':serviceUrl +'likeHandle',//喜欢
  'uploadFace':serviceUrl +'uploadFace',//头像

};