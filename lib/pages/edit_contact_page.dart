import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_manager/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconly/iconly.dart';

class EditContactPage extends StatefulWidget {
  const EditContactPage({
    Key? key,
    required this.avatar,
    required this.name,
    required this.phone,
    required this.email,
    required this.id
}) : super (key : key);

  final String avatar;
  final String name;
  final String phone;
  final String email;
  final String id;



  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final _formkey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;

  // edit contact
void editContact() async {
  if(_formkey.currentState!.validate()){
    try{
      await FirebaseFirestore.instance.collection('contacts').doc(widget.id).update(
          {
            "name": nameController.text.trim(),
            "phone": phoneController.text.trim(),
            "email": emailController.text.trim()
          });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contact updated")));

    }on FirebaseException{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update failed")));
    }
  }

}

@override
  void initState() {
    nameController = TextEditingController(
      text: widget.name
    );
    phoneController = TextEditingController(
      text: widget.phone
    );
    emailController = TextEditingController(
      text: widget.email
    );
    super.initState();
  }


  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();

    super.dispose();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("EDIT CONTACT"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Form(
              key: _formkey,
              child: Column(
                children: [
                  Center(
                    child: Hero(
                      tag: widget.id,
                      child: SizedBox.square(
                      child: SvgPicture.network(widget.avatar,height: 150,width: 150),

                    ) ,
                  ),
                  ),
                  const SizedBox(height: 20),
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
                        onPressed: editContact,
                        icon: Icon(IconlyBroken.edit),
                        label: Text("EDIT CONTACT")
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
