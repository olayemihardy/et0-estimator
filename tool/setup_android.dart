// Run once after `flutter create`: dart run tool/setup_android.dart
// Adds permissions to AndroidManifest.xml and raises minSdk for geolocator.
import 'dart:io';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  var xml = manifest.readAsStringSync();
  const perms = [
    'android.permission.INTERNET',
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_COARSE_LOCATION',
  ];
  for (final p in perms) {
    if (!xml.contains(p)) {
      xml = xml.replaceFirst(
          '<application', '<uses-permission android:name="$p"/>\n    <application');
    }
  }
  manifest.writeAsStringSync(xml);

  for (final name in ['build.gradle.kts', 'build.gradle']) {
    final f = File('android/app/$name');
    if (!f.existsSync()) continue;
    final text = f.readAsStringSync().replaceAllMapped(
        RegExp(r'minSdk(Version)?(\s*=\s*|\s+)flutter\.minSdkVersion'),
        (m) => m[0]!.contains('Version') ? 'minSdkVersion 23' : 'minSdk = 23');
    f.writeAsStringSync(text);
  }
  stdout.writeln('Android manifest and minSdk updated.');
}
