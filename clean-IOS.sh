#!/bin/bash

echo "flutter clean ..."
/Users/tlinxe/Development/flutter/bin/flutter clean
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
/Users/tlinxe/Development/flutter/bin/flutter packages get
echo "Done."