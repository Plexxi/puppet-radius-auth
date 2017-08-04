# == Class: radius-auth
#
# Puppet module to manage RADIUS PAM configuration.
#
# === Parameters
#
# Document parameters here.
#
# [pam_enable]
#   If enabled (pam_enable => true) enables the RADIUS PAM module.
#   *Optional* (defaults to true)
# [server,secret,timeout]
#   (Address,secret,timeout) of RADIUS servers.  Multiple entries may be set.
#   **Required if pam_enable is true**
#
# === Examples
#
#  class { 'radius-auth':
#    pam_enable => true,
#    server => [ { addr => '1.2.3.4',
#                  secret => 'secret',
#                  timeout => 2
#                },
#                { addr => '5.6.7.8',
#                  port => 11,
#                  secret => 'secret2'
#                } ]
#  }
#
# === Authors
#
# Matthew Morgan <matt.morgan@plexxi.com>
#
# === Copyright
#
# Copyright 2017 Matthew Morgan, Plexxi, Inc
#
class radius-auth( 
  $pam_enable = true,
  $server     = [],
) {
  if $pam_enable {
     file { '/etc/pam_radius_auth.conf':
       ensure  => file,
       owner   => 0,
       group   => 0,
       mode    => '0600',
       content => template('radius-auth/pam_radius_auth.conf.erb'),
     }
     exec { 'radius_pam_auth_update':
       environment => ["DEBIAN_FRONTEND=editor",
                       "PLEXXI_AUTH_UPDATE=radius",
                       "PLEXXI_AUTH_ENABLE=1",
                       "EDITOR=/opt/plexxi/bin/px-auth-update"],
       command => '/usr/sbin/pam-auth-update',
     }
  } else {
     exec { 'radius_pam_auth_update':
       environment => ["DEBIAN_FRONTEND=editor",
                       "PLEXXI_AUTH_UPDATE=radius",
                       "PLEXXI_AUTH_ENABLE=0",
                       "EDITOR=/opt/plexxi/bin/px-auth-update"],
       command => '/usr/sbin/pam-auth-update',
     }
  }
}
