# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class roles_profiles::profiles::homebrew (
    Boolean $update = false,
) {

    require packages::xcode_cmd_line_tools
    require packages::coreutils
    require roles_profiles::profiles::cltbld_user

    $formula_hash = '3a877e3525d93cfeb076fc57579bdd589defc585'

    class { 'homebrew':
        user      => 'cltbld',
        group     => 'staff',
        multiuser => true,
        require   => Class['packages::xcode_cmd_line_tools'],
    }
    -> file { '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/.git/refs/heads/master':
        ensure  => file,
        content => "${formula_hash}\n",
        owner   => 'root',
        mode    => '0644',
    }

    file { '/etc/environment': ensure => present }
    -> file_line { 'homebrew-disable-updates':
        path  => '/etc/environment',
            line  => $update ? { false => 'HOMEBREW_NO_AUTO_UPDATE=1', default => '' },
            match => '^HOMEBREW_NO_AUTO_UPDATE',
    }

}
