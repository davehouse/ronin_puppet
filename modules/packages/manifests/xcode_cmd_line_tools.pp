# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::xcode_cmd_line_tools {

    packages::macos_package_from_s1 { 'Command_Line_Tools_for_Xcode_12_beta_5.dmg':  #'Command_Line_Tools_macOS_10.14_for_Xcode_10.1.dmg':
        private             => true,
        os_version_specific => true,
        type                => 'dmg',
    }
}
