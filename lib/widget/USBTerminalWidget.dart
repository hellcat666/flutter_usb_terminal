import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_usb/utils/USBSerialManagerWidget.dart';
import 'package:notifier/notifier_provider.dart';

import '../ApplicationData.dart';

class USBTerminalWidget extends StatefulWidget {
  USBTerminalWidget() : super();

  _USBTerminalWidgetState createState() => new _USBTerminalWidgetState();
}

class _USBTerminalWidgetState extends State<USBTerminalWidget> {
//  USBSerialManagerWidget _usbSerialManagerWidget;
  Stream<String> _usbEvents;
  StreamSubscription<String> _subEvents;
  List<String> _terminalInputData = [];

  TextEditingController _textController = TextEditingController();
  FocusScopeNode currentFocus;

  _USBTerminalWidgetState() : super();

  @override
  void initState() {
    super.initState();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
  }

void dispose() {
  _subEvents.cancel();
  super.dispose();
}

  void setUSBDataStream(BuildContext context) {
    _usbEvents = ApplicationData.of(context).getEventsStream();
    if (_usbEvents != null) {
      if (_subEvents == null) {
        _subEvents = _usbEvents.listen((event) {
          setState(() {
            _terminalInputData.add('$event');
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double columnMediaWidth = MediaQuery.of(context).size.width / 12;
    final double columnMediaHeight = MediaQuery.of(context).size.height / 20;
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NotifierProvider.of(context).register('usb-serial-ready', (data) {
            print('USB-SERIAL-READY');
            setUSBDataStream(context);
            return Visibility(
                child: Container(width: 0.0, height: 0.0), visible: false);
          }),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: columnMediaWidth * 9.0,
                height: columnMediaHeight * 1.25,
                margin: EdgeInsets.fromLTRB(5.0, 10.0, 2.5, 5.0),
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                alignment: Alignment.centerLeft,
                decoration: new BoxDecoration(
                    border: Border.all(color: Colors.grey[500]),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(2.0)),
                child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.done,
                      cursorColor: Colors.white,
                      enableInteractiveSelection: false,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red,
                              style: BorderStyle
                                  .solid), /*borderRadius: BorderRadius.all(Radius.circular(1.0) )*/
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                        ),
                        hoverColor: Colors.grey[300],
                        focusColor: Colors.black,
                        labelText: 'Enter Command',
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.grey),
                        enabled: true,
                        isDense: false,
                      ),
                    onTap: () {
                      setState(() {
                        currentFocus = FocusScope.of(context);
                        _textController.clear();
                      });
                    }),),
              Container(
                width: columnMediaWidth * 2.25,
                height: columnMediaHeight * 1.25,
                margin: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 2.5),
                padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
                child: RaisedButton(
                  color: Colors.blue[500],
                  child: Text('Send',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
                    NotifierProvider.of(context)
                        .notify('usb-serial-command', _textController.text);
                  },
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            decoration: new BoxDecoration(
                border: Border.all(color: Colors.grey[500]),
                color: Colors.transparent),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: columnMediaWidth * 10.0,
                  height: columnMediaHeight * 1.25,
                  margin: EdgeInsets.fromLTRB(5.0, 0.0, 2.5, 0.0),
                  padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 0.0),
                  alignment: Alignment.centerLeft,
                  child: Text('Output',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  width: columnMediaWidth * 1.0,
                  height: columnMediaHeight * 1.25,
                  margin: EdgeInsets.fromLTRB(5.0, 0.0, 2.5, 0.0),
                  padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
                  alignment: Alignment.centerRight,
                  child: RaisedButton(
                      color: Colors.black,
                      child: Text('X',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                      onPressed: () {
                        setState(() {
                          _terminalInputData.clear();
                        });
                      }),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: columnMediaWidth * 9.0,
              height: columnMediaHeight * 12.0,
              margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
              padding: EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 1.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                  border: Border.all(color: Colors.grey[500]),
                  color: Colors.transparent),
              child: ListView.builder(
                  itemCount: _terminalInputData.length,
                  itemBuilder: (context, index) {
                    final item = _terminalInputData[index];
                    return new Text('$item',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold));
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
