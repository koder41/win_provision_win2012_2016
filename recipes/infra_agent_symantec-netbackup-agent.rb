#
# Cookbook:: win_provision_win2012_2016
# Recipe:: infra_agent_symantec-netbackup-agent
#
# Copyright:: 2020, The Authors, All Rights Reserved.

exit! if registry_key_exists?('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentControlSet\Uninstall\Symantec NetBackup Client') || registry_key_exists?('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentControlSet\Uninstall\VERITAS NetBackup Client') 

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

if node['platform_version'] == '6.3.9600'
    build_reg = registry_get_values('HKEY_LOCAL_MACHINE\software\project\goldimage')
elsif node['platform_version'] == '10.0.14393'
    build_reg = registry_get_values('HKEY_LOCAL_MACHINE\software\project\goldimage', :i386)
end

environment = build_reg.select { |key| key.to_s.match(/server_environment/) }[0][:data]
chefserver = build_reg.select { |key| key.to_s.match(/chefserver/) }[0][:data]

CASE node['platform_version']
WHEN '6.3.9600'
    nbu_agent_source = "#{chefserver}#{node['infra_agent']['symantec-netbackup']['win2012']['source']}_#{node['infra_agent']['symantec-netbackup']['win2012']['version_old']}"
    nbu_agent_destination = node['infra_agent']['symantec-netbackup']['win2012']['path']
    nbu_agent_file = "#{nbu_agent_destination}\\#{node['infra_agent']['symantec-netbackup']['win2012']['source']}_#{node['infra_agent']['symantec-netbackup']['win2012']['version_old']}"

WHEN '10.0.14393'
        if environment == 'TEST'
            nbu_agent_source = "#{chefserver}#{node['infra_agent']['symantec-netbackup']['win2016']['source']}_#{node['infra_agent']['symantec-netbackup']['win2016']['version_old']}"
            nbu_agent_destination = node['infra_agent']['symantec-netbackup']['win2016']['path']
            nbu_agent_file = "#{nbu_agent_destination}\\#{node['infra_agent']['symantec-netbackup']['win2016']['source']}_#{node['infra_agent']['symantec-netbackup']['win2016']['version_old']}"
        else
            nbu_agent_source = "#{chefserver}#{node['infra_agent']['symantec-netbackup']['win2016']['source']}_#{node['infra_agent']['symantec-netbackup']['win2016']['version_new']}"
            nbu_agent_destination = node['infra_agent']['symantec-netbackup']['win2016']['path']
            nbu_agent_file = "#{nbu_agent_destination}\\#{node['infra_agent']['symantec-netbackup']['win2016']['source']}_#{node['infra_agent']['symantec-netbackup']['win2016']['version_new']}"
        end
ELSE
    puts 'non windows'
    exit!
END

remote_file "Downloading #{nbu_agent_source}.zip" do
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
    notifies :run, "batch[Installing symantec-netbackup-#{environment}.cmd]", :immediately
end

batch "Installing symantec-netbackup-#{environment}.cmd" do
    cwd nbu_agent_file
    code <<-EOH 
        symantec-netbackup-#{environment}.cmd
    EOH
    action :nothing
end
