# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class roles_profiles::profiles::test_logger {

    $worker_type  = 'gecko-t-osx-1014-staging'
    $worker_group = regsubst($facts['networking']['fqdn'], '.*\.releng\.(.+)\.mozilla\..*', '\1')

    case $::operatingsystem {
        'Darwin': {

            class { 'puppet::atboot':
                telegraf_user     => lookup('telegraf.user'),
                telegraf_password => lookup('telegraf.password'),
                puppet_branch     => 'staging',
                # Note the camelCase key names
                meta_data         => {
                    workerType    => $worker_type,
                    workerGroup   => $worker_group,
                    provisionerId => 'releng-hardware',
                    workerId      => $facts['networking']['hostname'],
                },
            }

            class { 'roles_profiles::profiles::logging':
                worker_type => $worker_type,
            }
        }
        default: {
            fail("${::operatingsystem} not supported")
        }
    }
}
