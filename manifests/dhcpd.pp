define ffnord::dhcpd (
  $mesh_code,

  $ipv4_address,
  $ipv4_network,
  $ipv4_netmask,

  $ranges = [],
  $dns_servers = [],
  ) {

  include ffnord::dhcpd::base
  include ffnord::dhcpd::service

  if $ranges != [] {

    file { "/etc/dhcp/interface-${name}.conf":
      ensure => file,
      content => template("ffnord/etc/dhcp/interface.erb"),
      require => [Package['isc-dhcp-server']],
      notify => [Service['isc-dhcp-server']];
    } 

    file_line { "ffnord::dhcpd::${name}-rule":
      path => '/etc/dhcp/dhcpd.conf',
      line => "include \"/etc/dhcp/interface-${name}.conf\";",
      require => [File['/etc/dhcp/dhcpd.conf']],
      notify => [Service['isc-dhcp-server']];
    }
  }
}

class ffnord::dhcpd::base {

  ffnord::monitor::nrpe::check_command {
    "dhcpd":
      command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -w 1:1 -C dhcpd';
  }

  package { 
    'isc-dhcp-server': 
      ensure => installed;
  }

  file {
    "/etc/dhcp/dhcpd.conf":
      ensure => file,
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/ffnord/etc/dhcp/dhcpd.conf',
      require => [Package['isc-dhcp-server']],
      notify => [Service['isc-dhcp-server']];
  }
  
  ffnord::firewall::service { 'dhcpd':
    chains => ['mesh'],
    ports  => ['67','68'],
    protos => ['udp'];
  }
}

class ffnord::dhcpd::service {
  service { 
    'isc-dhcp-server': 
      ensure => running,
      hasrestart => true,
      enable => true;
  }
}
