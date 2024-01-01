import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_manager/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class AddContactPage  extends StatefulWidget {
  const AddContactPage ({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPage();
}

class _AddContactPage extends State<AddContactPage> {
  final _formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  void addContact() async {
    if(_formkey.currentState!.validate()){

      try{
        await FirebaseFirestore.instance.collection("contacts").add({
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "email": emailController.text.trim()
        });
        if(mounted){
          Navigator.pop(context);
        }

      } on FirebaseException {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to add contact!"))
          );
        }
      }

    }else{
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all the fields!"))
      );
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ADD CONTACT"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Form(
              key: _formkey,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if(value!.isEmpty){
                        return "Please enter a name!";
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "Name",
                      contentPadding: inputPadding
                    ),
                  ),
                  const SizedBox(height: 20),


                  TextFormField(
                    keyboardType: TextInputType.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: phoneController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if(value!.isEmpty){
                        return "Please enter a phone number!";
                      }
                    },
                    decoration: const InputDecoration(
                        hintText: "Phone",
                        contentPadding: inputPadding
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if(value!.isEmpty){
                        return "Please enter an email address!";
                      }
                    },
                    decoration: const InputDecoration(
                        hintText: "Email",
                        contentPadding: inputPadding
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                        onPressed: addContact,
                        icon: Icon(IconlyBroken.add_user),
                        label: Text("ADD CONTACT")
                    ),
                  )
                ],
          ),
          )
        ],
      )
    );
  }
}
