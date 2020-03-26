import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera_permissions/camera_permissions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                CameraPermissions().openAppSettings().then((bool hasOpened) =>
                    debugPrint('App Settings opened: ' + hasOpened.toString()));
              },
            )
          ],
        ),
        body: Center(
          child: ListView(
            children: createWidgetList(),
          ),
        ),
      ),
    );
  }

  List<Widget> createWidgetList() {
    final List<Widget> widgets = CameraPermissionLevel.values
        .map<Widget>((CameraPermissionLevel level) => PermissionWidget(level))
        .toList();

    if (Platform.isAndroid) {
      widgets.add(StreamingStatusWidget());
    }

    return widgets;
  }
}

class StreamingStatusWidget extends StatelessWidget {
  final Stream<ServiceStatus> statusStream =
      CameraPermissions().serviceStatus;

  @override
  Widget build(BuildContext context) => ListTile(
        title: const Text('ServiceStatus'),
        subtitle: StreamBuilder<ServiceStatus>(
          stream: statusStream,
          initialData: ServiceStatus.unknown,
          builder: (_, AsyncSnapshot<ServiceStatus> snapshot) =>
              Text('${snapshot.data}'),
        ),
      );
}

class PermissionWidget extends StatefulWidget {
  const PermissionWidget(this._permissionLevel);

  final CameraPermissionLevel _permissionLevel;

  @override
  _PermissionState createState() => _PermissionState(_permissionLevel);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permissionLevel);

  final CameraPermissionLevel _permissionLevel;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() {
    final Future<PermissionStatus> statusFuture =
        CameraPermissions().checkPermissionStatus();

    statusFuture.then((PermissionStatus status) {
      setState(() {
        _permissionStatus = status;
      });
    });
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_permissionLevel.toString()),
      subtitle: Text(
        _permissionStatus.toString(),
        style: TextStyle(color: getPermissionColor()),
      ),
      trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            checkServiceStatus(context, _permissionLevel);
          }),
      onTap: () {
        requestPermission(_permissionLevel);
      },
    );
  }

  void checkServiceStatus(
      BuildContext context, CameraPermissionLevel permissionLevel) {
    CameraPermissions()
        .checkServiceStatus()
        .then((ServiceStatus serviceStatus) {
      final SnackBar snackBar =
          SnackBar(content: Text(serviceStatus.toString()));

      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  Future<void> requestPermission(
      CameraPermissionLevel permissionLevel) async {
    final PermissionStatus permissionRequestResult = await CameraPermissions()
        .requestPermissions(permissionLevel: permissionLevel);

    setState(() {
      print(permissionRequestResult);
      _permissionStatus = permissionRequestResult;
      print(_permissionStatus);
    });
  }
}
