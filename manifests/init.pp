class bind {
  package { bind9: 
    ensure => installed, 
  }

  service { bind9:
    ensure    => running,
    pattern => named,
    subscribe => Package[bind9]
  }

  file { "/etc/default/bind9":
    source => "puppet:///bind/default",
    require => Package[bind9],
    notify => Service[bind9]
  }

  concatenated_file { "/etc/bind/named.conf.local":
    dir => "/etc/bind/named.conf.d",
    require => Package[bind9],
    notify => Service[bind9]
  }

  file { "/etc/bind/named.conf":
    source => "puppet:///bind/named.conf",
    require => Package[bind9],
    notify => Service[bind9]
  }

  concatenated_file { "/etc/bind/named.conf.options":
    dir => "/etc/bind/named.conf.options.d",
    header => "/etc/bind/named.conf.options.header",
    footer => "/etc/bind/named.conf.options.footer",
    require => [Package[bind9], File["/etc/bind/named.conf.options.header"], File["/etc/bind/named.conf.options.footer"]],
    subscribe => [File["/etc/bind/named.conf.options.header"], File["/etc/bind/named.conf.options.footer"]],
    notify => Service[bind9]
  }

  file { "/etc/bind/named.conf.options.header":
    source => "puppet:///bind/named.conf.options.header",
    require => Package[bind9];

    "/etc/bind/named.conf.options.footer":
    source => "puppet:///bind/named.conf.options.footer",
    require => Package[bind9]
  }

  concatenated_file_source { "named.conf.options":
    source => "puppet:///files/bind/named.conf.options",
    dir => "/etc/bind/named.conf.options.d"
  }

  define zone($zone_name = '') {
    $real_zone_name = $zone_name ? {
      '' => $name,
      default => $zone_name
    }
    file { "/etc/bind/db.$name":
      source => "puppet:///files/bind/db.$name",
      owner => root,
      group => root,
      require => Package[bind9],
      notify => Service[bind9]
    }

    concatenated_file_part { "zone-$name":
      dir => "/etc/bind/named.conf.d",
      content => "zone \"$real_zone_name\" { type master; file \"/etc/bind/db.$name\"; };
"
    }
  }
}
