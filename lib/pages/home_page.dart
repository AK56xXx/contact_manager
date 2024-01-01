import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_manager/pages/add_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:iconly/iconly.dart';

class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  //get contact collection stream
  final contactCollection = FirebaseFirestore.instance.collection("contacts").snapshots();

  //delete contact
  void deleteContact(String id) async {
    FirebaseFirestore.instance.collection('contacts').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("Contact deleted.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Manager"),
      ),
      body: StreamBuilder(
        builder: (context,snapshot){
          if(snapshot.hasData){ //*************

          final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          if(documents.isEmpty){
            return Center(
              child: Text("No contact yet", style: Theme.of(context).textTheme.headline6)
            );
          }
          return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context,index){


                final contact = documents[index].data() as Map<String,dynamic>;
                final contactId = documents[index].id;
                final name = contact['name'];
                final phone = contact['phone'];
                final email = contact['email'];
               // final String avatar = 'https://avatars.dicebear.com/api/avataaars/$name.png';
                final avatar = 'https://api.dicebear.com/7.x/initials/svg?seed=$name';

                return ListTile(
                  title: Text(name),
                  subtitle: Text("$phone\n $email"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: (){
                        FlutterPhoneDirectCaller.callNumber(phone);
                        }, icon: const Icon(IconlyBroken.call)),
                      IconButton(onPressed: (){}, icon: const Icon(IconlyBroken.edit)),
                      IconButton(onPressed: (){deleteContact(contactId);}, icon: const Icon(IconlyBroken.delete))
                    ],
                  ),

                );
              }
          );

        } //***************
        else if(snapshot.hasError){
          return const Center(
            child: Text("Error!"),
          );
        }
        else {
          return const  Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
      },
        stream: contactCollection
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddContactPage() ));
        },
        label: Text("Add Contact"),
        icon: Icon(IconlyBroken.document),

      )
    );
  }
}
