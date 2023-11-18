import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/services/auth_methods.dart';
import 'package:chat_app/screens/chat_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum OptionItem { logout, profile }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*late User? user;
  String name = "";
  String id = "";
  String photoUrl = "";*/
  final authMethods = AuthMethods.getInstance();

  @override
  void initState() {
    /*user = authMethods.getCurrentUser();
    name = user?.displayName ?? "Guest";
    id = user?.uid ?? "00000";
    photoUrl = user?.photoURL ?? '';*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/background.png'), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            title: const Text('Homepage'),
            actions: [
              PopupMenuButton<OptionItem>(
                  icon: const Icon(Icons.menu_sharp),
                  onSelected: (value) async {
                    if (value == OptionItem.logout) {
                      await authMethods.signOutUser();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    }
                    if (value == OptionItem.profile) {
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfilePage()));
                      }
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<OptionItem>>[
                        const PopupMenuItem(
                            value: OptionItem.logout, child: Text('Logout')),
                        const PopupMenuItem(
                            value: OptionItem.profile, child: Text('Profile'))
                      ]),
            ],
          ),
          body: Center(
            child: StreamBuilder(
              stream: authMethods.retrieveUsersList(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) =>
                        buildCardItem(context, snapshot.data!.docs[index]));
              },
            ),
          ),
        ));
  }

  Widget buildCardItem(
      BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> data) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: ListTile(
          shape: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(22))),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          tileColor: Colors.black,
          textColor: Colors.white,
          leading: CircleAvatar(
            backgroundImage:
                CachedNetworkImageProvider(data.get('photoUrl').toString()),
            radius: 30,
          ),
          title: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(data.get('nickname'))),
          subtitle: Text(
            data.get('description'),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      onTap: () {
        String contactId = data.get('id');
        String contactName = data.get('nickname');
        String yourId = authMethods.getUserId();
        String groupChatId = authMethods.generateChatId(yourId, contactId);

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                  chatId: groupChatId,
                  yourId: yourId,
                  contactId: contactId,
                  contactUsername: contactName),
            ));
      },
    );
  }
}
