import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopping_app_flutter/data/categories.dart';
import 'package:shopping_app_flutter/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class NewItem extends StatefulWidget {

  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {

  final _formKey = GlobalKey<FormState>();
  var _enteredName= '';
  var _enteredQuantity= 1;
  var _selectedCategory =  categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    // esse validate vai acessar todos os widgets com campo de formulario e executar suas funcoes validadoras
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https('flutter-prep-5798f-default-rtdb.firebaseio.com','shopping-list.json');
      final response = await http.post(
          url,
          headers:  {
        'Content-Type':'application/json'
      }, body: json.encode({
        'name':_enteredName,
        'quantity':_enteredQuantity,
        'category':_selectedCategory.title
          }
        )
      );

      final Map< String, dynamic > resData = json.decode(response.body);

      if(!context.mounted){
        return;
      }

     Navigator.of(context).pop(
       GroceryItem(
           id: resData['name'],
           name: _enteredName,
           quantity: _enteredQuantity,
           category: _selectedCategory

      )
     );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const  Text('Add a new item') ,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              maxLength: 50,
              decoration: InputDecoration(
                label: Text('Name'),
              ),
              validator: (value){
                if (value == null ||
                    value.isEmpty ||
                    value.trim().length <= 1 ||
                    value.trim().length>50){
                  return 'Must be between 1 and 50 characters.';
                }
                return null;

              },
              onSaved: (value){
                _enteredName = value!;
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      label: Text('Quantity'),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _enteredQuantity.toString(),
                    validator: (value){
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0){
                        return 'Must be a valid, positive number';
                      }
                      return null;

                    },
                    onSaved: (value){
                      _enteredQuantity = int.parse(value!);
                    },

                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField(
                    value:_selectedCategory ,
                      items: [
                        //como categorie é um map(json) eu uso a prop entries para acessar os valores da chave
                        for(final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                  
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6,),
                                Text(category.value.title),
                              ],
                            ),

                          ),
                      ],
                      onChanged: (value){
                      setState(() {
                        _selectedCategory =value!;
                      });


                      }
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSending
                      ? null
                      : (){
                    _formKey.currentState!.reset();
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed:_isSending
                      ? null
                      : _saveItem ,

                  child: _isSending
                      ? const SizedBox(
                    height: 16,
                      width: 16,
                    child: CircularProgressIndicator(),
                  )
                  : const Text('Add item'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
