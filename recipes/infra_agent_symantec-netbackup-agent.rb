#
# Cookbook:: win_provision_win2012_2016
# Recipe:: infra_agent_symantec-netbackup-agent
#
# Copyright:: 2020, The Authors, All Rights Reserved.

exit! if registry_key_exists?('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Symantec NetBackup Client') || registry_key_exists?('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VERITAS NetBackup Client')

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

dcenter = dcenter_location(node['hostname'])
svr_envi = svr_environment(node['hostname'])

if svr_envi == 'true'
  check = node['hostname'][8]
else
  check = node['hostname'][5]
end

case check
when 'u'
  envi = 'uat'
when 'p'
  if dcenter == 'site_a'
    envi = 'prod'
  else
    envi = 'dr'
  end
when 'r'
  envi = 'dr'
else
  envi = 'test'
end

if (File.foreach('c:\chef\client.rb').grep(/chef_server_url/)[0].split('/')[2]).match?(node['url_artifactory']['dev'])
  artifactory = node['url_artifactory']['dev']
else
  artifactory = node['url_artifactory'][envi]
end

url = "http://#{artifactory}/loibuweb/"

case node['platform_version']
when '6.3.9600'
  nbu_agent_source = url + node['infra_agent']['symantec-netbackup']['win2012']['source'] + '_' + node['infra_agent']['symantec-netbackup']['win2012']['version_old']
  nbu_agent_destination = node['infra_agent']['symantec-netbackup']['win2012']['path']
  nbu_agent_file = nbu_agent_destination + node['infra_agent']['symantec-netbackup']['win2012']['source'] + '_' + node['infra_agent']['symantec-netbackup']['win2012']['version_old']

when '10.0.14393'
  if environment == 'test'
    nbu_agent_source = url + node['infra_agent']['symantec-netbackup']['win2016']['source'] + '_' + node['infra_agent']['symantec-netbackup']['win2016']['version_old']
    nbu_agent_destination = node['infra_agent']['symantec-netbackup']['win2016']['path']
    nbu_agent_file = nbu_agent_destination + node['infra_agent']['symantec-netbackup']['win2016']['source'] + '_' + node['infra_agent']['symantec-netbackup']['win2016']['version_old']
  else
    nbu_agent_source = url + node['infra_agent']['symantec-netbackup']['win2016']['source'] + '_' + node['infra_agent']['symantec-netbackup']['win2016']['version_new']
    nbu_agent_destination = node['infra_agent']['symantec-netbackup']['win2016']['path']
    nbu_agent_file = nbu_agent_destination + node['infra_agent']['symantec-netbackup']['win2016']['source'] + '_' + node['infra_agent']['symantec-netbackup']['win2016']['version_new']
  end
else
  puts 'non windows'
  exit!
end

remote_file "Downloading file #{nbu_agent_source}.zip" do
  source "#{nbu_agent_source}.zip"
  path "#{nbu_agent_file}.zip"
  notifies :run, "powershell_script[Extracting #{nbu_agent_source}.zip]", :immediately
end

powershell_script "Extracting #{nbu_agent_source}.zip" do
  code <<-EOH
    [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
    [System.IO.Compression.ZipFile]::ExtractToDirectory("#{nbu_agent_file}.zip", "#{nbu_agent_destination}")
  EOH
  guard_interpreter :powershell_script
  action :nothing
  notifies :run, "batch[Installing silentclient-#{svrenvi}.cmd]", :immediately
end

batch "Installing silentclient-#{svrenvi}.cmd" do
  cwd nbu_agent_file
  code <<-EOH
    silentclient-#{svrenvi}.cmd
  EOH
  action :nothing
end
