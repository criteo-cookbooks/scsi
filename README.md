# bus-scsi

[![Cookbook Version][cookbook_version]][cookbook]
[![Build Status][build_status]][build_status]

Expose SCSI disk information via automatic attributes under the `bus.scsi`
namespace.

## Requirements

This cookbook requires Chef 12.7+.

### Platforms
* Linux with libudev-147+ (tested with CentOS 6)
* Windows (tested with Windows Server 2012R2 & 2016)

## Usage

You just need to load the cookbook to get access to the SCSI automatic
attributes.
* In a cookbook, add a dependency to `bus-scsi` in your cookbook's metadata.
* On a node, add the `bus-scsi::default` recipe to your run-list.

You can disable these attributes by turning the `bus_scsi_disabled` setting to
`true` in the Chef config.

## Attributes

The `bus.scsi` namespace is a hash with one entry per SCSI disk.
For each disk, the hash key is the "host:channel:target:lun" quadruplet and the
value is another hash with the following attributes exposed:

Attribute     | Description
--------------|------------------------------------------------------------------------
`host`        | SCSI adapter number
`channel`     | SCSI channel number
`target`      | SCSI id number
`lun`         | SCSI Logical unit number
`model`       | Vendor model string
`fwrev`       | Firmware revision identifier
`serial`      | Disk serial number
`size`        | Size of the disk in bytes
`wwn`         | World wide number identifier (only in Linux)
`devnode`     | Device entry in /dev (only in Linux)
`host_pci`    | PCI location of the host adapter this device depends on (only in Linux)

## Recipes

This cookbook has a single `bus-scsi::default` recipe which does nothing. It can
be used to load the cookbook from a run-list.

[build_status]:             https://api.travis-ci.org/criteo-cookbooks/bus-scsi.svg?branch=master
[cookbook_version]:         https://img.shields.io/cookbook/v/bus-scsi.svg
[cookbook]:                 https://supermarket.chef.io/cookbooks/bus-scsi
