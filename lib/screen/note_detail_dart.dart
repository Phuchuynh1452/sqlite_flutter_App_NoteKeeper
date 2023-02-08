import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqlite/models/note.dart';
import 'package:sqlite/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note ,this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note,this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {

  static var _priorities = ['Hight','Low'];

  DatabaseHelper helper = DatabaseHelper();


  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);
  @override
  Widget build(BuildContext context) {

    // TextStyle? textStyle = Theme.of(context).textTheme.titleSmall;
    TextStyle textStyle = TextStyle(color: Colors.black);

    titleController.text = note.title;
    descriptionController.text = note.description;

    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        return Future(() => false);
      },

      child: Scaffold(
        appBar: AppBar(
        title: Text(appBarTitle),
        leading:
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              moveToLastScreen();
            },
          ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15, left: 10, right: 10),
        child: ListView(
          children: <Widget>[

            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem){
                  return DropdownMenuItem<String> (
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),

                style: textStyle,
                value: getPriorityAsString(note.priority),

                onChanged: (valueSelectedByUser){
                  setState(() {
                    debugPrint('User selected $valueSelectedByUser');
                    updatePriorityAsInt(valueSelectedByUser);
                  });

                },
              ),
            ),

            //Second Element
            Padding(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: TextField(
                controller: titleController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in Title Text Field');
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),

            //Third Element
            Padding(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: TextField(
                controller: descriptionController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in Description Text Field');
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),

            //Four Element
            Padding(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          setState(() {
                            debugPrint("Save button clicked");
                            _save();
                          });
                        },
                        child: Text(
                            'Save'
                        ),
                      ),
                  ),

                  Container(width: 5.0,),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () {
                        setState(() {
                          debugPrint("Delete button clicked");
                          _delete();
                        });
                      },
                      child: Text(
                          'Delete'
                      ),
                    ),
                  )
                ],
              )
            )

          ],
        ),
      ),
    ));
  }

  void moveToLastScreen(){
    Navigator.pop(context, true);
  }

  //Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value){
    switch (value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Covert int priority to String priority and display it to user Dropdown
  String getPriorityAsString(int value){
    String priority;
    switch (value){
      case 1:
        priority = _priorities[0]; //High
        break;
      case 2:
        priority = _priorities[1]; //Low
        break;
    }
    return priority;
  }

  //Update the title of Note Object
  void updateTitle(){
    note.title = titleController.text;
  }

  //Update the description of Note Object
  void updateDescription(){
    note.description = descriptionController.text;
  }

  //Save data to database
  void _save() async{
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if(note.id != null){ //Case 1 update operation
      result = await helper.updateNote(note);
    }else{ //Case 2 insert operation
      result = await helper.insertNote(note);
    }

    if(result != 0){ //Succes
      _showAlterDialog('Status','Note Saved Successfully');
    }else{ //Failure
      _showAlterDialog('Status','Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    //Case 1: If user is Trying to delete the NEW NOTE i.e. he has come to
    //the detail page be pressing the FAB of NoteList page.
    if(note.id == null){
      _showAlterDialog('Status', 'No note was deleted');
    }
    //Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlterDialog('Status', 'Note deleted succesfully');
    }else{
      _showAlterDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlterDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}