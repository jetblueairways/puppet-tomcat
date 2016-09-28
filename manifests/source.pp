# == Class: tomcat::source
#
# Installs tomcat using the compressed archive from your favorite tomcat
# mirror. Files from the archive will be installed in /opt/apache-tomcat/.
#
# This class must not be included directly. It is included when the source
# parameters on the tomcat module is set to true.
#
# Class variables:
# - *$log4j_conffile*: see tomcat
#
# Requires:
# - java to be previously installed
# JB REMOVED Requirement: - archive definition (from puppet camptocamp/puppet-archive module)
# JB MODIFIED - Patched to use puppet/archive rather than camptocamp/puppet-archive module
# - Package["curl"]
#
# Tested on:
# - RHEL 5,6
# - Debian Lenny/Squeeze
# - Ubuntu Lucid
#
class tomcat::source {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $version     = $tomcat::src_version
  $sources_src = $tomcat::sources_src

  if $version =~ /^6\./ {
    # install extra tomcat juli adapters, used to configure logging.
    class { '::tomcat::juli': }
  }

  # link logging libraries from java
  class {'::tomcat::logging': }

  $a_version = split($version, '[.]')
  $maj_version = $a_version[0]

  $baseurl = "${sources_src}/tomcat-${maj_version}/v${version}/bin"
  $tomcaturl = "${baseurl}/apache-tomcat-${version}.tar.gz"

#  archive{ "apache-tomcat-${version}":
#    url         => $tomcaturl,
#    digest_url  => "${tomcaturl}.md5",
#    digest_type => 'md5',
#    target      => '/opt',
#  }

# JB - Modified for compatability with puppet/archive module
  archive{ "apache-tomcat-${version}.tar.gz":
    path          => "/tmp/apache-tomcat-${version}.tar.gz",
    source        => $tomcaturl,
    checksum_url  => "${tomcaturl}.md5",
    checksum_type => 'md5',
    extract       => true,
    extract_path  => '/opt',
    creates       => "/opt/apache-tomcat-${version}",
    cleanup       => true,
  }


  file { '/opt/apache-tomcat':
    ensure  => link,
    target  => $::tomcat::home,
    require => Archive["apache-tomcat-${version}.tar.gz"],
    before  => Class['tomcat::logging'],
  }

  file { $::tomcat::home:
    ensure  => directory,
    require => Archive["apache-tomcat-${version}.tar.gz"],
  }

  # Workarounds
  case $version {
    '6.0.18': {
      # Fix https://issues.apache.org/bugzilla/show_bug.cgi?id=45585
      file {"${::tomcat::home}/bin/catalina.sh":
        ensure  => file,
        content => file(sprintf('%s/files/catalina.sh-6.0.18', get_module_path($module_name))),
        require => Archive["apache-tomcat-${tomcat::version}.tar.gz"],
        mode    => '0755',
      }
    }
    default: {}
  }
}
