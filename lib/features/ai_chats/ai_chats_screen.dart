import 'package:flutter/material.dart';

class AiChatsScreen extends StatefulWidget {
  const AiChatsScreen({super.key = const ValueKey(route)});

  static const route = '/ai_chats';

  @override
  State<AiChatsScreen> createState() => _AiChatsScreenState();
}

class _AiChatsScreenState extends State<AiChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(children: [Text('List of AI chats')]),
    );
  }
}
