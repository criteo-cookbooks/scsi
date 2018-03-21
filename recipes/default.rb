return if Chef::Config['bus_scsi_disabled']

# On CentOS/RHEL 6, libudev is not installed by default
package 'libudev' do
  only_if { node['platform_family'] == 'rhel' && node['platform_version'].to_i == 6 }
  notifies :run, 'ruby_block[Reload bus-scsi attrs]', :immediately
end

ruby_block 'Reload bus-scsi attrs' do
  block { node.automatic_attrs['bus']['scsi'] = ::SCSI.devices(node) }
  action :nothing
end
