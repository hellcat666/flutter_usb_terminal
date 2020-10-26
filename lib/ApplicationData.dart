import 'dart:async';

import 'package:flutter/material.dart';


// ignore: must_be_immutable
class ApplicationData extends InheritedWidget {

final String data = '';

  Stream<String> _eventsStream;
  List<String> _terminalInputData = [];

  ApplicationData({Key key, Widget child}) : super(key:key, child:child);

  void setEventsStream(Stream<String> eventStream) {
    this._eventsStream = eventStream;
  }

  Stream<String> getEventsStream() {
    return _eventsStream;
  }

  List<String> getTerminalInputData() {
    return _terminalInputData;
  } 

  void clearTerminalInputData() {
    _terminalInputData.clear();
  }  

  @override
  bool updateShouldNotify(ApplicationData oldWidget) {
    _eventsStream = oldWidget._eventsStream;
    _terminalInputData = oldWidget._terminalInputData;
    return true;
  }

  static ApplicationData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType(aspect: ApplicationData);

}