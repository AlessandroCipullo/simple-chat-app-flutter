import 'package:chat_app/services/auth_methods.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.chatId,
      required this.yourId,
      required this.contactId,
      required this.contactUsername});
  final String chatId;
  final String yourId;
  final String contactId;
  final String contactUsername;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final textController = TextEditingController();
  final scrollController = ScrollController();
  //final focusNode = FocusNode();
  final authMethods = AuthMethods.getInstance();

  void scrollDown() async {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.contactUsername),
          backgroundColor: Colors.black,
        ),
        body: StreamBuilder(
          stream: authMethods.retrieveChatMessages(widget.chatId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              scrollDown();
            });

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                        controller: scrollController,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Align(
                                    alignment: snapshot.data!.docs[index]
                                                .get('idFrom')
                                                .toString() ==
                                            widget.contactId
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8),
                                        decoration: BoxDecoration(
                                            color: snapshot.data!.docs[index]
                                                        .get('idFrom')
                                                        .toString() ==
                                                    widget.contactId
                                                ? Colors.grey.shade300
                                                : Colors.amber,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(8))),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        child: Text(
                                          snapshot.data!.docs[index]
                                              .get('content')
                                              .toString(),
                                        ))));
                          },
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: snapshot.data!.docs.length,
                          physics: const NeverScrollableScrollPhysics(),
                        ))),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      //autofocus: true,
                      //focusNode: focusNode,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      controller: textController,
                      minLines: 1,
                      maxLines: 5,

                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Invia un messaggio',
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(22))),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(22)))),
                    )),
                    IconButton(
                        onPressed: () async {
                          String msg = textController.text;
                          textController.clear();
                          if (msg.trim().isNotEmpty) {
                            await authMethods.sendMessage(msg, widget.yourId,
                                widget.contactId, widget.chatId);
                          }
                        },
                        icon: const Icon(Icons.send))
                  ],
                ),
              ],
            );
          },
        ));
  }
}
