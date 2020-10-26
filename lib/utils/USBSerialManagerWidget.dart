import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:notifier/notifier.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';


import '../ApplicationData.dart';

enum CONNECTION_STATUS { IDLE, CONNECTED, DISCONNECTED, ERROR }

extension CONNECTION_STATUS_EX on CONNECTION_STATUS {
  String get inString => describeEnum(this);
}

CONNECTION_STATUS connectionStatusFromString(String s) {
  return CONNECTION_STATUS.values.firstWhere((v) => v.inString == s);
}

const int MAX_RETRIES = 25;

class USBSerialManagerWidget extends StatefulWidget {
  final String title;

  USBSerialManagerWidget({Key key, this.title}) : super(key: key);

  _USBSerialManagerWidgetState createState() =>
      new _USBSerialManagerWidgetState();
}

class _USBSerialManagerWidgetState extends State<USBSerialManagerWidget> {
  CONNECTION_STATUS _status = CONNECTION_STATUS.IDLE;
  UsbPort _port;
  List<UsbDevice> _devices = [];
  UsbDevice _selectedDevice;
  Transaction<String> _transaction;
  StreamSubscription<String> _subscription;
  StreamController<String> _streamController = StreamController<String>.broadcast();  
  bool _usbReady = false;

  _USBSerialManagerWidgetState() {
    print('USBSerialManager Constructor');
    this._port = null;
    this._selectedDevice = null;
  }

  void initState() {
    asyncInitState();
    super.initState();
  }

  void asyncInitState() {
    print('_USBSerialManagerWidgetState.asyncInitState()');
    checkDevices();
  }

  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void checkDevices() async {
    print('_USBSerialManagerWidgetState.checkDevices()');
    UsbSerial.usbEventStream.listen((UsbEvent event) async {
      print('Into usbEventStream Listener ');
      await _getDevices();
    });
    await _getDevices();
      print('Attempt to connect to ${_devices[0].productName}');
      setState(() {
        _usbReady = true;
      });
  }

  Future<void> connect() async {
    _status = CONNECTION_STATUS.DISCONNECTED;
    _usbReady = false;
    if (_selectedDevice != null) 
      if(await _connectTo(_selectedDevice)) {
        _status = CONNECTION_STATUS.CONNECTED;
      }
  }

  Future<bool> _connectTo(device) async {

    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port.close();
      _port = null;
    }

    if (device == null) {
      _status = CONNECTION_STATUS.DISCONNECTED;
      return true;
    }

    _port = await device.create();
    if (!await _port.open()) {
      _status = CONNECTION_STATUS.ERROR;
      return false;
    }

    await _port.setDTR(false);
    await _port.setRTS(false);
    await _port.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port.inputStream, Uint8List.fromList([13, 10]));

    _subscription = _transaction.stream.listen((String line) {
      print('########## $line');
      _streamController.sink.add(line);
    });
    setState(() {
      _status = CONNECTION_STATUS.CONNECTED;
      _usbReady = true;
    });
    return true;
  }

  Future<void >_getDevices() async {
    _devices = await UsbSerial.listDevices();
  }

  void executeCommand(String cmd) {
    if ((_port != null) && (_status == CONNECTION_STATUS.CONNECTED))
      _port.write(Uint8List.fromList('$cmd\r\n'.codeUnits));
  }

  void disconnect() {
    _connectTo(null);
    setState(() {
      _status = CONNECTION_STATUS.DISCONNECTED;
    });
  }

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

  Widget build(BuildContext context) {
    print('USBSerialManagerWidget.build()');
    final double columnMediaWidth = MediaQuery.of(context).size.width / 12;
    final double columnMediaHeight = MediaQuery.of(context).size.height / 20;
    if (!_usbReady)
      return _buildProgressIndicator();
    else {
      ApplicationData.of(context).setEventsStream(_streamController.stream);
      NotifierProvider.of(context).notify('usb-serial-ready', _status);
      return Container (
        alignment: Alignment.center, 
        decoration:  new BoxDecoration(border: Border.all(color: Colors.grey[500]), color:Colors.transparent),
        child: SizedBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotifierProvider.of(context).register('usb-serial-command', (data) {
                if(data.data!=null) {
                  ApplicationData.of(context).clearTerminalInputData();
                  executeCommand(data.data.toString());   
                }
                return Visibility(child: Container(width: 0.0, height: 0.0), visible: false); 
            }),
            Container(
              width: columnMediaWidth * 5.0,
              height: columnMediaHeight * 0.75,
              margin: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
              padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                border: Border.all(
                    color: Colors.grey[500],
                    style: BorderStyle.solid,
                    width: 0.80),
              ),
              child: new DropdownButton<UsbDevice> (
                hint: Text(' Select Device', style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center,),
                dropdownColor: Colors.black45,
        isExpanded: true,
        underline: Container(width: 0.0, height: 0.0),
        value: _selectedDevice,
        icon: Icon(Icons.arrow_drop_down),
        iconSize:24,
        elevation: 12,
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),        
        onChanged: (UsbDevice newValue) {
          setState(() {
            _selectedDevice = newValue;
          });
        },
        items: _devices.toList().map((device) {
          return DropdownMenuItem(
            child: new Text(device.productName),
            value: device,
          );
        }).toList(),
        isDense: false,
      ),
    ),
    Spacer(),
    GestureDetector(
        child: Container(
        alignment: Alignment.centerRight,
        width: columnMediaWidth * 2.0,
        height: columnMediaHeight * 0.75,
        margin: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: (_status==CONNECTION_STATUS.CONNECTED) ?  AssetImage('assets/connected-slim.png') : AssetImage('assets/disconnected-slim.png'),
            scale: 0.5,
            fit: BoxFit.scaleDown,
          ),
          ),
        ),
        onTap: () {
            setState(() {
              if(_selectedDevice!=null) {
                if(_status==CONNECTION_STATUS.CONNECTED) 
                  disconnect(); 
                else 
                  connect();
              }
            });
        },
      ),
       ],
        ),
      ),);
    }
  }
}
