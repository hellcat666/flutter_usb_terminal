import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';

enum CONNECTION_STATUS { IDLE, CONNECTED, DISCONNECTED, ERROR }
extension CONNECTION_STATUS_EX on CONNECTION_STATUS { String get inString => describeEnum(this); }
CONNECTION_STATUS connectionStatusFromString(String s) { return CONNECTION_STATUS.values.firstWhere((v) => v.inString == s); }

const int MAX_RETRIES = 25;

class USBSerialManager {
  CONNECTION_STATUS status = CONNECTION_STATUS.IDLE;
  UsbPort _port;
  List<Widget> ports = [];
  List<Widget> _serialData = [];
  List<UsbDevice> devices = [];
  List<UsbDevice> _devices = [];
//  UsbDevice _device = null;
  int _deviceId;
  StreamSubscription<String> _subscription;
  Transaction<String> _transaction;
//  String _pkgName = 'flutter_esp8266_deauther';

  USBSerialManager() {
    print('USBSerialManager Constructor');
    _port = null;
    _deviceId = null;
    checkDevices();
  }

  void checkDevices()  async {      
    UsbSerial.usbEventStream.listen((UsbEvent event) async {
      print('Into usbEventStream Listener ');
      await _getDevices();
    });
    await _getDevices();
    if(devices.length==1) {
      print('Attempt to connect to ${devices[0].productName}');
      _connectTo(devices[0]);
    }
    else {
      print('NO Devices in List...');
    }
  }

  /*
  Future<void> _getDevices() async {
    _devices = await UsbSerial.listDevices();
    if(_devices.length>0) {
      print('${_devices.length} devices found.');
      selectDevice(0);
    }
  }

  void selectDevice(int idx) {
    if(_devices.length>0 && idx<_devices.length) {
      _device = _devices[idx];
      _deviceId = _device.deviceId;
      print('${_device.productName}');
    }
    else {
      _device = null;
      _currentDeviceId = null;
    }
  }

  Future<bool> _openPort() async {
    if(_device!=null) {
      _port = await _device.create();
      if(await _port.open())
        return true;
    }
    return false;    
  }

  void _closePort() {
    if(_port!=null) {
      _port.close();
      _port = null;  
    }
  }
  */
  Future<bool> connect() async {
    if(_devices.length>0)
      return await _connectTo(_devices[0]);
    return false;
  }

  Future<bool> _connectTo(device) async {
   _serialData.clear();

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
      _deviceId = null;
      status = CONNECTION_STATUS.DISCONNECTED;
      return true;
    }

    _port = await device.create();
    if (!await _port.open()) {
      status = CONNECTION_STATUS.ERROR;
      return false;
    }

    _deviceId = device.deviceId;
    await _port.setDTR(true);
    await _port.setRTS(true);
    await _port.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port.inputStream, Uint8List.fromList([13, 10]));

    _subscription = _transaction.stream.listen((String line) {
        print('$line');
        _serialData.add(Text(line));
        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
    });
//    print('$devices[0] CONNECTED - Now Sending scan -aps command');
//    String msg = 'scan -aps\r\n';
//    port.write(Uint8List.fromList(msg.codeUnits));
    status = CONNECTION_STATUS.CONNECTED;
    return true;
  }

  Future<void> _getDevices() async {
    ports = [];
    devices = await UsbSerial.listDevices();
    print(devices);

    devices.forEach((device) {
      print('set Port Entry: ${device.productName}');
      ports.add(ListTile(
          leading: Icon(Icons.usb),
          title: Text(device.productName),
          subtitle: Text((device.manufacturerName==null) ? 'Undefined' : device.manufacturerName),
          trailing: RaisedButton(
            child:
                Text(_deviceId == device.deviceId ? "Disconnect" : "Connect"),
            onPressed: () {
              _connectTo(_deviceId == device.deviceId ? null : device)
                  .then((res) {
                _getDevices();
              });
            },
          )));
    });
    print('Exit _getDevices()');
  }

  bool disconnect() {
    _connectTo(null);
    status = CONNECTION_STATUS.IDLE;    
    return true;
  }
  /*
  String getStatus() {
    return _status.inString;
  }

  bool isConnected() {
    return _status == CONNECTION_STATUS.CONNECTED;
  }

  Future<void> sendData(String data) {
    _port.write(data.codeUnits);  
  }
  */
}
