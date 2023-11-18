import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/services/auth_methods.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authMethods = AuthMethods.getInstance();
  TextEditingController nickController = TextEditingController();
  TextEditingController descController = TextEditingController();

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
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: const Text('Your account'),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 35),
              child: Column(
                children: [
                  StreamBuilder(
                    stream: authMethods.getCurrentUserData(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      } else {
                        nickController.text = snapshot.data!.get('nickname');
                        descController.text = snapshot.data!.get('description');

                        return Column(children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: CachedNetworkImageProvider(
                                snapshot.data!.get('photoUrl')),
                            child: IconButton(
                                onPressed: () async {
                                  final image = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (image == null) {
                                    return;
                                  } else {
                                    File file = File(image.path);
                                    authMethods.updateProPic(file);
                                    // fare check prima
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(Utils.createSnackbar(
                                              'Profile picture succesfully updated!'));
                                    }
                                  }
                                },
                                icon: const Icon(Icons.edit)),
                          ),
                          const SizedBox(height: 35),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: nickController,
                                    maxLength: 20),
                              ),
                              IconButton(
                                  onPressed: () {
                                    authMethods
                                        .updateNickname(nickController.text);
                                    // fare check prima
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        Utils.createSnackbar(
                                            'Nickname succesfully updated!'));
                                  },
                                  icon: const Icon(Icons.edit))
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: descController,
                                    maxLength: 35),
                              ),
                              IconButton(
                                  onPressed: () {
                                    authMethods
                                        .updateDescription(descController.text);
                                    // fare check prima
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        Utils.createSnackbar(
                                            'Description succesfully updated!'));
                                  },
                                  icon: const Icon(Icons.edit))
                            ],
                          )
                        ]);
                      }
                    },
                  ),
                ],
              )),
        )),
      ),
    );
  }
}
