define ffnord::mesh(
  $mesh_name,        # Name of your community, e.g.: Freifunk Gotham City
  $mesh_code,        # Code of your community, e.g.: ffgc
  $mesh_as,          # AS of your community
  $mesh_mac,         # mac address mesh device: 52:54:00:bd:e6:d4
  $mesh_ipv4,        # ipv4 address in cidr notation, e.g. 10.35.0.1/19
  $mesh_ipv6,        # ipv6 address in cidr notation, e.g. fd35:f308:a922::ff00/64
  $mesh_peerings,    # path to the local peerings description yaml file

  $fastd_secret,     # fastd secret
  $fastd_port,       # fastd port

  $dhcp_ranges = [], # dhcp pool
  $dns_servers = [], # other dns servers in your network
) {

  # TODO We should handle parameters in a param class pattern.
  # TODO Handle all git repos and other external sources in
  #      a configuration class, so we can redefine sources.
  # TODO Update README

  include ffnord::ntp

  # Determine ipv{4,5} network prefixes and ivp4 netmask
  $mesh_ipv4_prefix   = inline_template("<%= IPAddr.new(@mesh_ipv4) %>")
  $mesh_ipv4_prefixlen = inline_template("<%= @mesh_ipv4.split('/')[1] %>")
  $mesh_ipv4_netmask   = inline_template("<%= IPAddr.new('255.255.255.255').mask(@mesh_ipv4_prefixlen)%>")
  $mesh_ipv4_address   = inline_template("<%= @mesh_ipv4.split('/')[0] %>")

  $mesh_ipv6_prefix    = inline_template("<%= IPAddr.new(@mesh_ipv6) %>")
  $mesh_ipv6_prefixlen = inline_template("<%= @mesh_ipv6.split('/')[1] %>")
  $mesh_ipv6_address   = inline_template("<%= @mesh_ipv6.split('/')[0] %>")


  ffnord::bridge { "bridge_${mesh_code}":
    mesh_name            => $mesh_name,
    mesh_code            => $mesh_code,
    mesh_ipv6_address    => $mesh_ipv6_address,
    mesh_ipv6_prefix     => $mesh_ipv6_prefix,
    mesh_ipv6_prefixlen  => $mesh_ipv6_prefixlen,
    mesh_ipv4_address    => $mesh_ipv4_address,
    mesh_ipv4_netmask    => $mesh_ipv4_netmask,
    mesh_ipv4_prefix     => $mesh_ipv4_prefix,
    mesh_ipv4_prefixlen  => $mesh_ipv4_prefixlen
  } ->
  Class['ffnord::ntp'] ->
  ffnord::dhcpd { "br-${mesh_code}":
    mesh_code    => $mesh_code,
    ipv4_address => $mesh_ipv4_address,
    ipv4_network => $mesh_ipv4_prefix,
    ipv4_netmask => $mesh_ipv4_netmask,
    ranges       => $dhcp_ranges,
    dns_servers  => $dns_servers;
  } ->
  ffnord::fastd { "fastd_${mesh_code}":
    mesh_name => $mesh_name,
    mesh_code => $mesh_code,
    mesh_mac  => $mesh_mac,
    fastd_secret => $fastd_secret,
    fastd_port   => $fastd_port,
    fastd_peers_git => 'git://freifunk.in-kiel.de/fastd-peer-keys.git';
  } ->
  ffnord::radvd { "br-${mesh_code}":
    mesh_ipv6_address    => $mesh_ipv6_address,
    mesh_ipv6_prefix     => $mesh_ipv6_prefix,
    mesh_ipv6_prefixlen  => $mesh_ipv6_prefixlen;
  } ->
  ffnord::bird6::mesh { "bird6-${mesh_code}":
    mesh_code => $mesh_code,
    mesh_ipv4_address => $mesh_ipv4_address,
    mesh_ipv6_address => $mesh_ipv6_address,
    mesh_peerings => $mesh_peerings,
    site_ipv6_prefix => $mesh_ipv6_prefix,
    icvpn_as => $mesh_as;
  } -> 
  ffnord::named::mesh { "${mesh_code}":
    mesh_ipv4_address => $mesh_ipv4_address,
    mesh_ipv4_prefix  => $mesh_ipv4_prefix,
    mesh_ipv4_prefixlen => $mesh_ipv4_prefixlen,
    mesh_ipv6_address => $mesh_ipv6_address,
    mesh_ipv6_prefix  => $mesh_ipv6_prefix,
    mesh_ipv6_prefixlen => $mesh_ipv6_prefixlen;
  }
  # ffnord::bird{4}
  # ffnord::opkg::mirror
  # ffnord::firmware mirror
}
