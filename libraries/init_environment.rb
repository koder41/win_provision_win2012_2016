#
# Chef Documentation
# https://docs.chef.io/libraries.html
#

module WinProvisionResource
  module InitEnvironment
    def dcenter_location(hostname)
      dcenter = hostname.match(/\d+/).to_s
      if dcenter.to_i <= 9
        return 'site_a'
      elsif dcenter.to_i >= 11 && dcenter.to_i <= 19
        return 'site_b'
      else
        return 'site_c'
      end
    end

    def svr_environment(hostname)
      hostname.include?('sql') ? 'true' : 'false'
    end
  end
end

Chef::Recipe.include(WinProvisionResource::InitEnvironment)
Chef::Resource.include(WinProvisionResource::InitEnvironment)
