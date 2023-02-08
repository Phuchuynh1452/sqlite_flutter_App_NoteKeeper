import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite/models/note.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPiority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {

    if( _databaseHelper == null ){
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get database async {
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPiority INTEGER, $colDate TEXT)');
  }

  //Fecth Operation: Get all note object from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPiority ASC');
    var result = await db.query(noteTable, orderBy: '$colPiority ASC');

    return result;
  }


  //Insert
  Future<int> insertNote(Note note) async{
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //Update

  Future<int> updateNote(Note note) async{
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  //Delete
  Future<int> deleteNote(int id) async{
    var db = await this.database;
    var result = await db.rawDelete('Delete from $noteTable Where $colId = $id');
    return result;
  }

  //get Number

  Future<int> getCount() async{
      Database db = await this.database;

      List<Map<String, dynamic>> x = await db.rawQuery('Select count(*) from $noteTable');
      int result = Sqflite.firstIntValue(x);
      return result;
  }

  //Get the 'Map List' [List<Map>] and convert it to 'Note List' [List<Note>]

  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    //For loop to create a 'Note List'  from a 'Map List'
    for(int i = 0; i<count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));

    }

    return noteList;
  }

}