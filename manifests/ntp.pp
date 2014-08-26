class ffnord::ntp () {
  package { 
    'ntp':
      ensure => installed,
  } 
  ->
  file { 
    '/etc/ntp.conf':
      ensure => file,
      mode => "0644",
      owner => "root",
      group => "root",
      content => template('ffnord/etc/ntp.conf.erb');
  } 
  ->
  service { 
    'ntp':
      enable => true,
      hasrestart => true,
      ensure => running;
  }
  ->
  ffnord::firewall::service { 'ntpd':
    ports => ['123'],
    protos => ['udp'],
    chains => ['mesh']
  }
}
