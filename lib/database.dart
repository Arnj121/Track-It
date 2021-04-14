import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class DatabaseHelper{
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  String table='items';
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE $table (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                spent INTEGER NOT NULL
              )''');
    await db.execute('''CREATE TABLE history (
                id INTEGER PRIMARY KEY,
                parentId INTEGER NOT NULL,
                name TEXT NOT NULL,
                changed INTEGER NOT NULL,
                spent INTEGER NOT NULL,
                date TEXT NOT NULL
              )''');
  }

  Future<int> insert(Map<String,dynamic> items) async {
    Database db = await database;
    // print(items);
    // print(45);
    int id = await db.insert(table, items);
    return id;
  }

  Future<void> delete(Map<String,dynamic> items)async{
    Database db = await database;
    await db.delete(table,where: 'id = ?',whereArgs: [items['id']]);
  }

  Future<int> resetToday() async{
    Database db = await database;
    int today = DateTime.now().day;
    List<Map<String,dynamic>> his = await db.query('history',
        columns: ['id','parentId','name','changed','spent','date']);
    dynamic resetVal = {};
    his.forEach((element) async{
      int d = DateTime.parse(element['date']).day;
      if(d==today){
        if(resetVal.containsKey(element['parentId'])){
          resetVal[element['parentId']]['changed']+=element['changed'];
        }else{
          resetVal[element['parentId']]={'id':element['parentId'],'changed':element['changed']};
        }
        await db.delete('history',where: 'id =?',whereArgs: [element['id']]);
      }
    });
    resetVal = resetVal.values;
    resetVal.forEach((element) async{
      dynamic spent = await db.query(table,columns:['spent'],where: 'id= ?',whereArgs: [element['id']]);
      await db.update(table, {'spent':spent[0]['spent']-element['changed']},where: 'id = ?',whereArgs: [element['id']]);
    });
    // print(await this.query());
    return 1;
    // print(await this.queryHistory(0));

  }

  Future<void> update(Map<String,dynamic> items) async{
    Database db = await database;
    // print(items);
    // print(60);
    await db.update(table,items,where: 'id = ?',whereArgs: [items['id']]);
  }

  Future<List<Map<String,dynamic>>> query() async {
    Database db = await database;
    List<Map> maps = await db.query(table,
        columns: ['id', 'name', 'spent']);
    // print(maps);
    // print(66);
    if(maps.length>0){
      return maps;
    }
    return [];
  }

  Future<List<Map<String,dynamic>>> queryHistory(int id) async{
    Database db = await database;
    if(id==0){
      List<Map> maps = await db.query('history',
          columns: ['id', 'parentId', 'name', 'changed', 'spent', 'date']);
      // print(maps);
      // print(83);
      if (maps.length > 0) {
        return maps;
      }
      return [];
    }
    else {
      List<Map> maps = await db.query('history',
          columns: ['id', 'parentId', 'name', 'changed', 'spent', 'date'],
          where: 'parentId =?',
          whereArgs: [id]);
      // print(maps);
      // print(95);
      if (maps.length > 0) {
        return maps;
      }
      return [];
    }
  }

  Future<int> insertHistory(Map<String,dynamic> items)async {
    Database db = await database;
    // print(items);
    // print(87);
    int id = await db.insert('history', items);
    return id;
  }
  Future<void> deleteHistory()async{
    Database db = await database;
    await db.delete('history',where: '1=1');
    await db.delete(table,where: '1=1');
    // await db.update(table, {'spent':0},where: '1=1');
    // print(await this.query());
  }

}
