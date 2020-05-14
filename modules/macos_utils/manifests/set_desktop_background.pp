# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class macos_utils::set_desktop_background (
    Optional[String] $image = '/Library/Desktop\ Pictures/Solid\ Colors/Teal.png',
) {
    $bg_script = '/usr/local/bin/mac_desktop_image.py'

    file { 
        $bg_script:
            ensure  => present,
            content => file('macos_utils/mac_desktop_image.py'),
            mode    => '0755';

        '/Users/cltbld/Library/LaunchAgents/org.mozilla.desktop_image.plist':
            ensure  => present,
            content => template('macos_util/desktop_image.plist.erb'),
            mode    => '0755';
    }
}
