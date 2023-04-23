#!/bin/sh

#  ci_post_clone.sh
#  htd
#
#  Created by Aleksey Landyrev on 23.04.2023.
#  Copyright © 2023 Alexey Landyrev. All rights reserved.

# Install CocoaPods using Homebrew.
brew install cocoapods

# Install dependencies you manage with CocoaPods.
pod install

