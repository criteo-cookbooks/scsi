automatic_attrs['bus']['scsi'] = ::SCSI.devices(node) unless Chef::Config['bus_scsi_disabled']
