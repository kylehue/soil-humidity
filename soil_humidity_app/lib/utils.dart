import 'package:permission_handler/permission_handler.dart';

Future<bool> askBluetoothPermission() async {
  var perm1 = await Permission.bluetooth.status;
  var perm2 = await Permission.bluetoothConnect.status;
  if (perm1.isDenied) {
    perm1 = await Permission.bluetooth.request();
    if (perm1.isDenied) return false;
  }
  if (perm2.isDenied) {
    perm2 = await Permission.bluetoothConnect.request();
    if (perm2.isDenied) return false;
  }

  return perm1.isGranted && perm2.isGranted;
}
