import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stack Money')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {},
          label: Text('Login with Google'),
          icon: Icon(Icons.login, color: Theme.of(context).colorScheme.secondary,),
        ),
      ),
    );
  }
}
