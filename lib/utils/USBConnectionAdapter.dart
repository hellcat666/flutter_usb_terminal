import 'dart:async';

import 'USBSerialManagerWidget.dart';
class USBConnectionAdapter {
   CONNECTION_STATUS _status;
   CONNECTION_STATUS getStatus() { return _status; }
   StreamController<String> _eventsStream;
   StreamController<String> getEventsStream() {return _eventsStream; }

   USBConnectionAdapter(CONNECTION_STATUS status, StreamController<String> eventsStream) {
     _status = status;
     _eventsStream = eventsStream;
   }
 } 

