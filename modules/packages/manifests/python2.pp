# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::python2 {

    # use commit hash because python2 is now removed from homebrew-core
    $package_name = 'python@2'
    $last_hash = '3a877e3525d93cfeb076fc57579bdd589defc585'
    $package_url = "https://raw.githubusercontent.com/Homebrew/homebrew-core/${last_hash}/Formula/${package_name}.rb"

    # Exec work-around puppet-homebrew module failure to list the package by name (it uses the url):
    # https://github.com/TheKevJames/puppet-homebrew/blob/master/lib/puppet/provider/package/homebrew.rb#L69
    exec { 'install_package':
        command     => "/usr/bin/sudo -u cltbld /usr/local/bin/brew install ${package_url}",
        refreshonly => true,
        unless      => "/usr/local/bin/brew list ${package_name}",
    }
}
