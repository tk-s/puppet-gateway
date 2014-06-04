class ffnord::vpn ( 
  $gw_vpn_interface  = "tun-anonvpn", # Interface name for the anonymous vpn
  $gw_control_ip     = "8.8.8.8",     # Control ip addr 
  $gw_bandwidth      = 54,            # How much bandwith we should have up/down per mesh interface
) {
  class { 'ffnord::vpn::check_gateway':
            gw_vpn_interface  => $gw_vpn_interface,
            gw_control_ip     => $gw_control_ip,
            gw_bandwidth      => $gw_bandwidth
        }
}

class ffnord::vpn::check_gateway (
  $gw_vpn_interface,
  $gw_control_ip,
  $gw_bandwidth,
) {
  
  include ffnord::resources::ffnord

  file {
    '/usr/local/bin/check-gateway':
      ensure => file,
      mode => "0755",
      source => 'puppet:///modules/ffnord/usr/local/bin/check-gateway';
  }
  Class[ffnord::resources::ffnord] ->
  file_line { 
    "ffnord::config::gw_interface":
      path => '/etc/ffnord',
      line => "GW_VPN_INTERFACE=${gw_vpn_interface}";
    "ffnord::config::gw_control":
      path => '/etc/ffnord',
      line => "GW_CONTROL_IP=${gw_control_ip}";
    "ffnord::config::gw_bandwidth":
      path => '/etc/ffnord',
      line => "GW_BANDWIDTH=${gw_bandwidth}";
  } 
  cron {
   'check-gateway':
     command => '/usr/local/bin/check-gateway',
     user    => root,
     minute  => '*';
  }
}

class ffnord::vpn::provider::mullvad () {
  # TODO
}

class ffnord::vpn::provider::hideio () {
  # TODO
}
