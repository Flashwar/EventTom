import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/shelf.dart';

void main() async {
  final cascade = Cascade().add((request) => Response.ok('Hello HTTPS!'));
  final handler = cascade.handler;

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    3000,
    securityContext: SecurityContext()
      ..useCertificateChain('certs/localhost.crt')
      ..usePrivateKey('certs/localhost.key'),
  );

  print(
      'HTTPS Server running on https://${server.address.host}:${server.port}');
}
