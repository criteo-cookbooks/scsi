require 'wmi-lite'

module SCSI
  module Windows
    def self.scsi_devices
      wmi = ::WmiLite::Wmi.new('root\CIMV2')
      wmi.instances_of('Win32_DiskDrive').reduce(::Mash.new) do |result, disk|
        host    = disk['scsibus']
        channel = disk['scsiport']
        target  = disk['scsitargetid']
        lun     = disk['scsilogicalunit']

        key = "#{host}:#{channel}:#{target}:#{lun}"
        next result if host.nil?

        result.merge!(key => ::Mash.new(
          host:    disk['scsibus'],
          channel: disk['scsiport'],
          target:  disk['scsitargetid'],
          lun:     disk['scsilogicalunit'],
          model:   disk['model'].strip,
          fwrev:   disk['firmwarerevision'].strip,
          serial:  disk['serialnumber'].strip,
          size:    disk['size'].to_i,
        ),)
      end
    end
  end
end
