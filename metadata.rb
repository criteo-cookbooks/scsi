name             'bus-scsi'
maintainer       'SRE Core Infra team'
maintainer_email 'sre-core-infra@criteo.com'
license          'Apache-2.0'
description      'Pseudo-ohai for SCSI disks'
long_description 'Pseudo-ohai for SCSI disks'
version          '0.1.1'

supports         'centos',  '>= 6.0'
supports         'redhat',  '>= 6.0'
supports         'windows', '>= 6.3'

chef_version     '>= 12.7'                                             if respond_to? :chef_version
issues_url       'https://github.com/criteo-cookbooks/bus-scsi/issues' if respond_to?(:issues_url)
source_url       'https://github.com/criteo-cookbooks/bus-scsi.git'    if respond_to?(:source_url)
