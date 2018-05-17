# == Class: radius_auth
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
# [server]
#   array of structures {'addr','port','secret','timeout') of RADIUS servers.  Multiple entries may be set.
#   *Optional*
#
# === Examples
#
#  class { 'radius_auth':
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
# Copyright 2018 Matthew Morgan, Plexxi, Inc
#
class radius_auth( 
  Boolean $pam_enable = true,
  Array[Struct[{ addr => String,
                 port => Optional[Integer],
                 secret => String,
                 timeout => Optional[Integer]
                 }]] $server = [],
) {
      $server.each |$value| {
          if has_key($value, port) {
              if is_integer($value[port]) {
                  if ($value[port] < 1) or ($value[port] > 65535) {
                      fail('port must be an integer from 1 to 65535')
                  }
              }
              else {
                  fail('port must be an integer')
              }
          }
          if !has_key($value, addr) {
              fail('addr must be provided for each server')
          }
      }

      if $pam_enable {
         file { '/etc/pam_radius_auth.conf':
                ensure  => file,
                owner   => 0,
                group   => 0,
                mode    => '0600',
                content => template('radius_auth/pam_radius_auth.conf.erb'),
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
