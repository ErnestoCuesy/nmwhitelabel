export BUILDS_DIR='build/1.ReleaseBundles'
cd ~/Documents/Development/Projects/Flutter/nearbymenus/
echo 'Cleaning project build'
flutter clean
echo 'Getting dependencies'
flutter pub get
#
echo 'Copying manager icon'
cp ~/Documents/Development/Projects/NewLauncherIcons/LauncherIconManager.png images/LauncherIcon.png
flutter pub run flutter_launcher_icons
echo 'Building manager app'
flutter build appbundle --release -t lib/main_manager.dart
mkdir $BUILDS_DIR
mv build/app/outputs/bundle/managerRelease/app-manager-release.aab $BUILDS_DIR
#
echo 'Copying staff icon'
cp ~/Documents/Development/Projects/NewLauncherIcons/LauncherIconStaff.png images/LauncherIcon.png
flutter pub run flutter_launcher_icons
echo 'Building staff app'
flutter build appbundle --release -t lib/main_staff.dart
mv build/app/outputs/bundle/staffRelease/app-staff-release.aab $BUILDS_DIR
#
echo 'Copying patron icon'
cp ~/Documents/Development/Projects/NewLauncherIcons/LauncherIconPatron.png images/LauncherIcon.png
flutter pub run flutter_launcher_icons
echo 'Building patron app'
flutter build appbundle --release -t lib/main_patron.dart
mv build/app/outputs/bundle/patronRelease/app-patron-release.aab $BUILDS_DIR
echo 'Releases build complete'
