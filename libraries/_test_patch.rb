if defined?(ChefSpec) && ENV['MOCK_BUS_SCSI_INFO'] != 'NO'
  require_relative 'default'

  module SCSIPatch
    def devices(_node)
      ::Mash.new
    end
  end
  ::Chef::Log.warn 'Patching SCSI module for ChefSpec'
  ::SCSI.singleton_class.prepend(SCSIPatch)
end
