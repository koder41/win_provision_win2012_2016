# Artifactory Servers
default['url_artifactory'] = {
  'dev' => 'uxappd1001',
  'test' => 'uxappt1001',
  'uat' => 'uxappu1001',
  'prod' => 'uxappp1001',
  'dr' => 'uxappr1001',
}

# Infra Agent - Symantec Netbackup Client - Windows Server 2012
default['infra_agent']['symantec-netbackup']['win2012'] = {
  'os_version' => '6.3.9600',
  'version_old' => 'v7.0.0',
  'version_new' => 'v8.0.0',
  'source' => 'win_symantec-netbackup',
  'path' => 'c:\\tmp\\',
}

# Infra Agent - Symantec Netbackup Client - Windows Server 2016
default['infra_agent']['symantec-netbackup']['win2016'] = {
  'os_version' => '10.0.14393',
  'version_old' => 'v7.0.0',
  'version_new' => 'v8.0.0',
  'source' => 'win_symantec-netbackup',
  'path' => 'c:\\tmp\\',
}
