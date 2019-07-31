# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class macos_mobileconfig_profiles::skipmojavewelcometour {

    mac_profiles_handler::manage { 'org.mozilla.SkipMojaveWelcomeTour':
        ensure      => 'present',
        file_source => 'puppet:///modules/macos_mobileconfig_profiles/SkipMojaveWelcomeTour.mobileconfig',
    }
}
