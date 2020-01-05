#
# Cookbook:: win_provision_win2012_2016
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

extend WinProvisionResource::InitEnvironment

include_recipe 'win_provision_win2012_2016::infra_agent_symantec-netbackup-agent'
