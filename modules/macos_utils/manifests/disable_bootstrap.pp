# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class macos_utils::disable_bootstrap {

    case $::operatingsystem {
        'Darwin': {
            file {
                '/Library/LaunchDaemons/org.mozilla.bootstrap_mojave.plist':
                    ensure => absent;
            }
        }
        default: {
            fail("${module_name} does not support ${::operatingsystem}")
        }
    }

}
