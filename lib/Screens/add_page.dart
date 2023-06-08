import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddToDoPage extends StatefulWidget {
  final Map? todo;

  const AddToDoPage({super.key,this.todo});

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
     bool isEdit= false;
     @override
  void initState() {
    super.initState();
    final todo =widget.todo;
    if(todo != null){
      isEdit =true;
      final title =todo['title'];
      final description =todo['description'];
      titleController.text =title;
      descriptionController.text=description;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit? "Edit Todo":"Add Todo"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: "Title"),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: "Description"),
            maxLines: 5,
            minLines: 2,
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(onPressed:isEdit?updateDeta: submitData, child:  Text(isEdit?"Update":"Submit"))
        ],
      ),
    );
  }
Future<void> updateDeta() async{
       final todo =widget.todo;
       if(todo==null){
         return;
       }
       final id = todo['_id'];
       //final isCompleted = todo['is_completed'];
  final title = titleController.text;
  final description = descriptionController.text;
  final body = {
    "title": title,
    "description": description,
    "is_completed": false
  };
  //Update the data to server
  final url = 'https://api.nstack.in/v1/todos/$id';
  final uri = Uri.parse(url);
  final response = await http.put(uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json'
      }
  );
       //Show success or fail message based on status
       if(response.statusCode ==200){
         ShowSuccessMessage("Updated");
       }else{
         ShowErrorMessage("Error");
       }
}
  Future<void> submitData() async {
    //Get the date from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    //Submit the data to server
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json'
      }
    );
    //Show success or fail message based on status
    if(response.statusCode ==201){
      titleController.text   ='';
      descriptionController.text ='';
      ShowSuccessMessage("Success");
    }else{
      ShowErrorMessage("Error");
    }
  }
  void ShowSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void ShowErrorMessage(String message){
    final snackBar = SnackBar(content: Text(message,
    style: TextStyle(color: Colors.white),
    ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
