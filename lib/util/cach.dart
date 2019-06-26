import 'package:shared_preferences/shared_preferences.dart';
import "dart:convert";


class Cachs{
   static set(name,value) async{
     final prefs = await SharedPreferences.getInstance();
     prefs.setString(name, json.encode(value)); //存取数据
   }

   static clear() async{
     final prefs = await SharedPreferences.getInstance();
     print('清除中');
     print( prefs );
     prefs.clear();//清空键值对
     print('清除结束');
   }

   static remove(key) async{
     final prefs = await SharedPreferences.getInstance();
     prefs.remove(key); //删除指定键
   }

   static get(name) async{
     final prefs = await SharedPreferences.getInstance();//获取 prefs
     var value = prefs.getString(name);//获取 key 为 name 的值
     if(value == null ){
       return null;
     }
     return json.decode(value);
   }
}