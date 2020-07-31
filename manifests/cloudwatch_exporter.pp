# Class: prometheus::cloudwatch_exporter
#
# This module manages prometheus cloudwatch_exporter
#
# Parameters:
#  [*arch*]
#  Architecture (amd64 or i386)
#
#  [*bin_dir*]
#  Directory where binaries are located
#
#  [*config*]
#  YAML formatted config. See https://github.com/Technofy/cloudwatch_exporter#how-to-configure
#
#  [*config_file*]
#  Absolute path to configuration file (cloudwatch metric definitions)
#
#  [*download_extension*]
#  Extension for the release binary archive
#
#  [*download_url*]
#  Complete URL corresponding to the where the release binary archive can be downloaded
#
#  [*download_url_base*]
#  Base URL for the binary archive
#
#  [*extra_groups*]
#  Extra groups to add the binary user to
#
#  [*extra_options*]
#  Extra options added to the startup command
#
#  [*group*]
#  Group under which the binary is running
#
#  [*init_style*]
#  Service startup scripts style (e.g. rc, upstart or systemd)
#
#  [*install_method*]
#  Installation method: url or package (only url is supported currently)
#
#  [*manage_group*]
#  Whether to create a group for or rely on external code for that
#
#  [*manage_service*]
#  Should puppet manage the service? (default true)
#
#  [*manage_user*]
#  Whether to create user or rely on external code for that
#
#  [*os*]
#  Operating system (linux is the only one supported)
#
#  [*package_ensure*]
#  If package, then use this for package ensure default 'latest'
#
#  [*package_name*]
#  The binary package name - not available yet
#
#  [*restart_on_change*]
#  Should puppet restart the service on configuration change? (default true)
#
#  [*service_enable*]
#  Whether to enable the service from puppet (default true)
#
#  [*service_ensure*]
#  State ensured for the service (default 'running')
#
#  [*service_name*]
#  Name of the node exporter service (default 'blackbox_exporter')
#
#  [*user*]
#  User which runs the service
#
#  [*version*]
#  The binary release version
#
#  [*web_telemetry_path*]
#  Path under which to expose exporter's metrics
#
#  [*web_listen_address*]
#  Address on which to expose metrics and web interface
#
#  [*scrape_telemetry_path*]
#  Path under which to expose CloudWatch metrics
#
class prometheus::cloudwatch_exporter (
  Hash $config,
  String $arch                   = $prometheus::real_arch,
  String $bin_dir                = $prometheus::bin_dir,
  String $config_file            = '/etc/cloudwatch-exporter.yaml',
  String $config_mode            = $prometheus::config_mode,
  String $download_extension     = 'tar.gz',
  Optional[String] $download_url = undef,
  String $download_url_base      = 'https://github.com/prometheus/cloudwatch_exporter/releases',
  Array[String] $extra_groups,
  String $extra_options          = '',
  String $group                  = 'cloudwatch-exporter',
  String $init_style             = $prometheus::init_style,
  String $install_method         = $prometheus::install_method,
  Boolean $manage_group          = true,
  Boolean $manage_service        = true,
  Boolean $manage_user           = true,
  String $os                     = $prometheus::os,
  String $package_ensure         = 'latest',
  String $package_name           = 'cloudwatch_exporter',
  Boolean $restart_on_change     = true,
  Boolean $service_enable        = true,
  String $service_ensure         = 'running',
  String $service_name           = 'cloudwatch_exporter',
  String $user                   = 'cloudwatch-exporter',
  String $version                = '0.1.0',
  String $web_telemetry_path     = '/cloudwatch-metrics',
  String $web_listen_address     = 'localhost:9042',
  String $scrape_telemetry_path  = '/cloudwatch-scrape',
) inherits prometheus {

  $real_download_url = pick($download_url,"${download_url_base}/download/v${version}/${package_name}-${version}.${os}-${arch}.${download_extension}")
  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  $options = "-config.file=${config_file} -web.listen-address=${web_listen_address} -web.telemetry-path=${web_telemetry_path} -web.telemetry-scrape-path=${scrape_telemetry_path} ${extra_options}"

  file { $config_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => $config_mode,
    content => template('prometheus/cloudwatch_exporter.yaml.erb'),
    notify  => $notify_service,
  }

  prometheus::daemon { $service_name :
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os                 => $os,
    arch               => $arch,
    real_download_url  => $real_download_url,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    group              => $group,
    manage_group       => $manage_group,
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
  }
}
