import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_manager/pages/add_contact_page.dart';
import 'package:contact_manager/pages/edit_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final contactCollection = FirebaseFirestore.instance.collection("contacts");

  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();

  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Manager"),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _searchController.text.isEmpty
                    ? contactCollection.orderBy('name').snapshots()
                    : _buildSearchQuery(_searchController.text).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> documents = snapshot.data!.docs;
                    if (documents.isEmpty) {
                      return Center(
                        child: Text("No contact yet", style: Theme.of(context).textTheme.headline6),
                      );
                    }
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final contact = documents[index].data() as Map<String, dynamic>;
                        final contactId = documents[index].id;
                        final name = contact['name'];
                        final phone = contact['phone'];
                        final email = contact['email'];
                        final avatar = 'https://api.dicebear.com/7.x/initials/svg?seed=$name';

                        return ListTile(
                          leading: Hero(
                            tag: contactId,
                            child: SizedBox.square(
                              child: SvgPicture.network(
                                avatar,
                                height: 50,
                                width: 50,
                              ),
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text("$phone\n $email"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  FlutterPhoneDirectCaller.callNumber(phone);
                                },
                                icon: const Icon(IconlyBroken.call),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditContactPage(
                                        id: contactId,
                                        avatar: avatar,
                                        name: name,
                                        phone: phone,
                                        email: email,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(IconlyBroken.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  deleteContact(contactId);
                                },
                                icon: const Icon(IconlyBroken.delete),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error!"),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddContactPage()),
          );
        },
        label: const Text("ADD CONTACT"),
        icon: const Icon(IconlyBroken.add_user),
        backgroundColor: Colors.green,
      ),
    );
  }

  void deleteContact(String id) {
    FirebaseFirestore.instance.collection('contacts').doc(id).delete().then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact deleted.")),
        );
      }
    }).catchError((error) {
      print("Failed to delete contact: $error");
    });
  }


  //search by phone or name
  bool isNumeric(String str) {
    // Use tryParse to check if the string can be parsed as a number
    return (int.tryParse(str) != null || double.tryParse(str) != null);
  }

  Query _buildSearchQuery(String searchQuery) {


    if (searchQuery.isNotEmpty && isNumeric(searchQuery)) {

      var contactsQuery = FirebaseFirestore.instance
          .collection("contacts")
          .orderBy("phone");
      String searchEnd = searchQuery + "\uf8ff";
      contactsQuery = contactsQuery.where(
        "phone",
        isGreaterThanOrEqualTo: searchQuery,
        isLessThan: searchEnd,
      );
      return contactsQuery;
    }
    else{
      var contactsQuery = FirebaseFirestore.instance
          .collection("contacts")
          .orderBy("name");
      String searchEnd = searchQuery + "\uf8ff";
      contactsQuery = contactsQuery.where(
        "name",
        isGreaterThanOrEqualTo: searchQuery,
        isLessThan: searchEnd,
      );
      return contactsQuery;
    }


  }


}
