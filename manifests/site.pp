## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'master.puppetlabs.vm',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# Randomize enforcement order to help understand relationships
ini_setting { 'random ordering':
  ensure  => present,
  path    => "${settings::confdir}/puppet.conf",
  section => 'agent',
  setting => 'ordering',
  value   => 'title-hash',
}

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node 'tkalligo.puppetlabs.vm'{
  notify { "New notify message for new node definition.\n ${::hostname}":}
  $message = hiera('message')
  notify { "$message" : }
}

node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
  notify { "Greetings from West Chester Training Room A - I am ${::hostname}": }
  
  file { "motd":
    noop => true,
    path => "/etc/motd",
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => "Lab 7.1 to modify the MOTD from GitHub\n",
  }
  
  #Exec resource
  exec { "motd" :
    command => "cowsay 'Welcome to ${::fqdn}!' > /etc/motd",
    creates => "/etc/motd",
    path => "/usr/local/bin",
  }
  
  #Include Users Class
  include users
  
  #Include Skelton - lab 9.3
  include skeleton
  
  $message = hiera('message')
  notify { "$message" : }
  
}
