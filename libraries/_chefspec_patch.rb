if defined?(ChefSpec)
  require 'chef/config'

  if ::Chef::Config[:bus_scsi_disabled].nil?
    ::Chef::Log.warn 'Disabling bus-scsi for ChefSpec'
    ::Chef::Config[:bus_scsi_enabled] = true
  end
end
