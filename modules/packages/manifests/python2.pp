# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::python2 {

    # brew install davehouse/homebrew-moz/python@2
    package { 'davehouse/homebrew-moz/python@2': #https://raw.githubusercontent.com/Homebrew/homebrew-core/3a877e3525d93cfeb076fc57579bdd589defc585/Formula/python@2.rb':
        ensure   => present,
        provider => brew,
        install_options => [ '--link' ],
    }
}
