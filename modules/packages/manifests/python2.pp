# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::python2 {

    package { "python2":
        source   => 'https://raw.githubusercontent.com/Homebrew/homebrew-core/3a877e3525d93cfeb076fc57579bdd589defc585/Formula/python@2.rb',
        ensure   => present,
        provider => brew,
    }

    exec { "pip2":
        command     => "/usr/local/bin/pip install --upgrade pip setuptools",
        refreshonly => true,
        subscribe   => Package['python2'],
    }
}
