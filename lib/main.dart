import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'app_initialiser.dart';
import 'dependency_injection.dart';
import 'socket_service.dart';

Injector injector;

void main() async {
  // It is *VERY* important that we only create a single socket connection
  // so we are using a service, and dependency injection.
  // You might think you can put it in the state of a widget but for some
  // reason the socket connection will be rebuilt randomly creating
  // hundreds of concurrent connections
  DependencyInjection().initialise(Injector.getInjector());
  injector = Injector.getInjector();
  await AppInitialiser().initialise(injector);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socket IO Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) {
    socketService = injector.get<SocketService>();
    socketService.createSocketConnection();
  }
  final String title;
  SocketService socketService;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('com.example.flutter_socket_io_example/battery');
  int _counter = 0;

  void _incrementCounter() {
    widget.socketService.emit('message', 'You have pushed this button $_counter');
    setState(() {
      _counter++;
    });
  }

  void _callNativeCode() async {
    // https://flutter.dev/docs/development/platform-integration/platform-channels

    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      widget.socketService.emit('message', 'Battery level is $result');
    } on PlatformException catch (e) {
      widget.socketService.emit('message', 'Battery level failed with ${e.message}');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: Tooltip(
        message: 'Long press for battery level',
        child: InkWell(
          onLongPress: _callNativeCode,
          child: FloatingActionButton(
            onPressed: _incrementCounter,
            child: Icon(Icons.add),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
