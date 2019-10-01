# == Class solr::install
#
# This class is called from solr for install.
#
class solr::install {
  include 'archive'

  archive { "/opt/staging/solr-${solr::version}.tgz":
    source       => "${solr::mirror}/${solr::version}/solr-${solr::version}.tgz",
    extract      => true,
    extract_path => '/opt/staging',
    creates      => "/opt/staging/solr-${solr::version}",
    cleanup      => false,
  }

  user { $solr::solr_user:
    ensure     => present,
    managehome => true,
    system     => true,
    before     => Exec['run solr install script'],
  }

  if $::solr::upgrade {
    $upgrade_flag = '-f'
  }
  else {
    $upgrade_flag = ''
  }

  exec { 'run solr install script':
    command => "/opt/staging/solr-${solr::version}/bin/install_solr_service.sh /opt/staging/solr-${solr::version}.tgz -i ${solr::extract_dir} -d ${solr::var_dir} -u ${solr::solr_user} -s ${solr::service_name} -p ${solr::solr_port} -n ${upgrade_flag}",
    cwd     => "/opt/staging/solr-${solr::version}",
    creates => "${solr::extract_dir}/solr-${solr::version}",
    require => Archive["/opt/staging/solr-${solr::version}.tgz"],
  }
  file { $solr::var_dir:
    ensure  => directory,
    owner   => $solr::solr_user,
    group   => $solr::solr_user,
    recurse => true,
    require => Exec['run solr install script'],
  }
  file { $solr::log_dir:
    ensure  => directory,
    owner   => $solr::solr_user,
    group   => $solr::solr_user,
    require => Exec['run solr install script'],
  }
}
