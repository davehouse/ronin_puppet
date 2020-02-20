# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::python2 {

    # use commit hash because python2 is now removed from homebrew-core
    #
    # Exec work-around because the puppet-homebrew module fails to list the package by name (uses arg (the url) as the package name, no override arg):
    # https://github.com/TheKevJames/puppet-homebrew/blob/master/lib/puppet/provider/package/homebrew.rb#L69
    exec { "python2":
        command     => '/usr/bin/sudo -u cltbld /usr/local/bin/brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/3a877e3525d93cfeb076fc57579bdd589defc585/Formula/python@2.rb',
        unless => [ '/usr/local/bin/brew list python@2' ],
    }
}
