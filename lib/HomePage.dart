import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';


import './utils/USBSerialManagerWidget.dart';
import './widget/USBTerminalWidget.dart';

//import './ApplicationData.dart';
class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key key, this.title})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(/*usbEvents*/);
}

class _HomePageState extends State<HomePage> {
  USBSerialManagerWidget _usbSerialManagerWidget;
  USBTerminalWidget _usbTerminalWidget;

  _HomePageState() : super();

  @override
  void initState() {
    asyncInitState();
    super.initState();
  }

  Future<void> asyncInitState() async {
    _usbSerialManagerWidget = new USBSerialManagerWidget();
    _usbTerminalWidget = null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _exit(BuildContext context) {
    // Leave it the Hard Way ;-)
    Navigator.of(context).dispose();
    exit(0);
  }

  /* Currently UNUSED 
  Widget _buildProgressIndicator() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          color: Colors.transparent,
          margin: EdgeInsets.fromLTRB(10, 0, 0, 25),
          child: Text(
            'Waiting for USB Interface...',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 22),
          ),
        ),
        CircularProgressIndicator(
          backgroundColor: Colors.transparent,
        ),
      ],
    ));
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        automaticallyImplyLeading: false,
        leading: Container(width: 0.0),
        actions: <Widget>[
          new IconButton(
            icon: new Image.asset('assets/exit-black24.png'),
            iconSize: 1,
            tooltip: 'Closes application',
            onPressed: () => _exit(context),
          ),
        ],
      ),
      body: Center(
        child: Container(
            decoration: new BoxDecoration(
                border: Border.all(color: Colors.grey[500]),
                color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _usbSerialManagerWidget,
                (_usbTerminalWidget == null)
                    ? _usbTerminalWidget = new USBTerminalWidget()
                    : _usbTerminalWidget,
              ],
            )),
      ),
    );
  }
}
