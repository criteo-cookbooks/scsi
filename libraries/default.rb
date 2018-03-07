module SCSI
  def self.devices(node)
    case node['os']
    when 'windows'
      require_relative 'windows'
      Windows.scsi_devices
    when 'linux'
      require_relative 'linux'
      Linux.scsi_devices
    else
      ::Chef::Log.warn "#{node['os']} is not a supported operating system."
      ::Mash.new
    end
  end
end
