#!/bin/bash

echo "Preventing Photos.app from opening."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES
