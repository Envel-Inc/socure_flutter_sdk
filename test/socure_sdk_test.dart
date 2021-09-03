import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socure_sdk/socure_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('socure_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

/*  test('getPlatformVersion', () async {
    expect(await SocureSdk.platformVersion, '42');
  });*/
}
