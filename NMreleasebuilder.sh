cd ~/Documents/Development/Projects/Flutter/nearbymenus/
flutter clean
flutter pub get
cp ~/Documents/Development/Projects/NewLauncherIcons/LauncherIconManager.png assets/LauncherIcon.png
flutter pub run flutter_launcher_icons
flutter build appbundle --release -t lib/main_manager.dart
mkdir build/releaseBundles
mv build/app/outputs/bundle/managerRelease/app-manager-release.aab build/releaseBundles
cp ~/Documents/Development/Projects/NewLauncherIcons/LauncherIconStaff.png assets/LauncherIcon.png
flutter pub run flutter_launcher_icons
flutter build appbundle --release -t lib/main_staff.dart
mv build/app/outputs/bundle/staffRelease/app-staff-release.aab build/releaseBundles
cp ~/Documents/Development/Projects/NewLauncherIcons/LauncherIconPatron.png assets/LauncherIcon.png
flutter pub run flutter_launcher_icons
flutter build appbundle --release -t lib/main_patron.dart
mv build/app/outputs/bundle/patronRelease/app-patron-release.aab build/releaseBundles

