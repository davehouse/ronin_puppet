# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class roles_profiles::profiles::homebrew (
    Boolean $update = false,
) {

    require packages::xcode_cmd_line_tools
    require packages::coreutils
    require roles_profiles::profiles::cltbld_user

    class { 'homebrew':
        user      => 'cltbld',
        group     => 'staff',
        multiuser => true,
        require   => Class['packages::xcode_cmd_line_tools'],
    }

    $update_value = $update ? { false => 1, default => 0 }
    file { '/etc/environment': ensure => present }
    -> file_line { 'homebrew-disable-updates':
        path  => '/etc/environment',
            line  => "HOMEBREW_NO_AUTO_UPDATE=${update_value}",
            match => '^HOMEBREW_NO_AUTO_UPDATE',
    }

}
