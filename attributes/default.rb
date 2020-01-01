# Infra Agent - Symantec Netbackup Client - Windows Server 2012 only
default['infra_agent']['symantec_netbackup']['win2012'] = {
    'os_version' => '6.3.9600',
    'version_old' => 'v1.0.0',
    'version_new' => 'v2.0.0',
    'source' => 'win_symantec-netbackup',
    'path' => 'c:\\tmp\\',
}

# Infra Agent - Symantec Netbackup Client - Windows Server 2016 only
default['infra_agent']['symantec_netbackup']['win2016'] = {
    'os_version' => '10.0.14393',
    'version_old' => 'v1.0.0',
    'version_new' => 'v2.0.0',
    'source' => 'win_symantec-netbackup',
    'path' => 'c:\\tmp\\',
}
