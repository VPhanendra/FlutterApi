import 'dart:convert';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter_api/Screens/add_page.dart';
import 'package:http/http.dart' as http;

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({Key? key}) : super(key: key);

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initSate() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo App"),
      ),
      body: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id =item['_id']as String;
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}'),),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton (
                    onSelected: (value){
                      if(value =='edit'){
                        //open edit page
                        navigateToEditPage(item);
                      }else if(value =='delete'){
                        //delete and remove the item
                        deleteById(id);
                      }
                    },
                    itemBuilder: (context){
                      return[
                        PopupMenuItem(child: Text("Edit"),value: 'edit',),
                        PopupMenuItem(child: Text("Delete"),value: 'delete',),
                      ];
                    },
                  ),
                );
              }
          ),
        ),

      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage
          // () {
          //   Navigator.push(context, MaterialPageRoute(
          //       builder: (context) => AddToDoPage()));
          // }
          ,
          label: Text("Add ToDo")),
    );
  }

  Future<void> navigateToAddPage () async{
    final route = MaterialPageRoute(
        builder: (context) => AddToDoPage()
    );
    await Navigator.push(context as BuildContext, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }
  Future<void> navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(
        builder: (context) => AddToDoPage(todo:item)
    );
    await Navigator.push(context as BuildContext, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async{
    //Delete the item
    final url ='https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if(response.statusCode==200){
      //Remove the item from list
      final filtered = items.where((element) => element['_id'] !=id).toList();
      setState(() {
        items= filtered;
      });
    }

  }

  Future<void> fetchTodo() async {
    setState(() {
      isLoading = true;
    });
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {

    }
    setState(() {
      isLoading = false;
    });
  }
}