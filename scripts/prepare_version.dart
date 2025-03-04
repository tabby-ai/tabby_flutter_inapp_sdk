import 'dart:io';

void main() {
  final absolutePath = File('example/pubspec.yaml').absolute.path;
  final fileContent = File(absolutePath).readAsStringSync();

  final lines = fileContent.split('\n');
  final versionLine = lines.firstWhere((line) => line.contains('version'));

  final versionAsString = versionLine.split(':')[1].trim();

  final parts = versionAsString.split('+');
  final version = parts[0];
  final buildNumber = parts.length > 1 ? parts[1] : '';

  final envFileContent =
      'TABBY_APP_VERSION=$version\nTABBY_APP_BUILD_NUMBER=$buildNumber';

  final envFilePath = File('scripts/.env_version').absolute.path;
  File(envFilePath).writeAsStringSync(envFileContent);
}
