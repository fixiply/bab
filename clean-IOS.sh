#!/bin/bash

echo "flutter clean ..."
/users/tlinxe/Documents/Development/SDK/flutter/bin/flutter clean
echo "Deleting .flutter-plugins ..."
rm -rf .flutter-plugins
echo "Deleting .packages ..."
rm -rf .packages
echo "Deleting .symlinks ..."
rm -rf ios/.symlinks/
echo "Deleting ios/Pods ..."
rm -rf ios/Pods
echo "Deleting ios/Podfile* ..."
rm ios/Podfile.lock
echo "Deleting pubspec.lock ..."
rm pubspec.lock
/users/tlinxe/Documents/Development/SDK/flutter/bin/flutter packages get
echo "Done."