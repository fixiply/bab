import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {
  final String message;

  ErrorContainer(
    this.message,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.redAccent,
              ),
              child: Icon(Icons.error_outline, size: 35, color: Colors.white)
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SelectableText(message, style: TextStyle(fontSize: 18, color: Colors.black38))
          )
        ],
      ),
    );
  }
}
