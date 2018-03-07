module SCSI
  module Linux
    begin
      require 'ffi'

      class Udev
        module C
          extend FFI::Library

          ffi_lib ['udev', 'libudev.so.1']

          attach_function :udev_ref, %i[pointer], :pointer
          attach_function :udev_unref, %i[pointer], :pointer
          attach_function :udev_new, [], :pointer
          attach_function :udev_list_entry_get_next, %i[pointer], :pointer
          attach_function :udev_list_entry_get_name, %i[pointer], :string
          attach_function :udev_list_entry_get_value, %i[pointer], :string
          attach_function :udev_device_ref, %i[pointer], :pointer
          attach_function :udev_device_unref, %i[pointer], :pointer
          attach_function :udev_device_get_udev, %i[pointer], :pointer
          attach_function :udev_device_new_from_syspath, %i[pointer string], :pointer
          attach_function :udev_device_get_sysname, %i[pointer], :string
          attach_function :udev_device_get_properties_list_entry, %i[pointer], :pointer
          attach_function :udev_device_get_property_value, %i[pointer string], :string
          attach_function :udev_device_get_sysattr_value, %i[pointer string], :string
          attach_function :udev_enumerate_ref, %i[pointer], :pointer
          attach_function :udev_enumerate_unref, %i[pointer], :pointer
          attach_function :udev_enumerate_new, %i[pointer], :pointer
          attach_function :udev_enumerate_add_match_subsystem, %i[pointer string], :int
          attach_function :udev_enumerate_add_match_property, %i[pointer string string], :int
          attach_function :udev_enumerate_add_match_parent, %i[pointer pointer], :int
          attach_function :udev_enumerate_scan_devices, %i[pointer], :int
          attach_function :udev_enumerate_get_list_entry, %i[pointer], :pointer
        end

        class UdevException < StandardError
        end

        class Enumerate
          include Enumerable

          def initialize(udev)
            @udev = udev
            @enum = Udev::C.udev_enumerate_new(@udev)
            raise UdevException, 'udev_enumerate_new failed' if @enum.null?

            ::ObjectSpace.define_finalizer(self, self.class.release(@enum))
          end

          def initialize_copy(copy)
            Udev::C.udev_enumerate_ref(@enum)
          end

          def self.release(enum)
            proc { Udev::C.udev_enumerate_unref(enum) }
          end

          def match_subsystem(name)
            ret = Udev::C.udev_enumerate_add_match_subsystem(@enum, name)
            raise UdevException, 'udev_enumerate_add_match_subsystem failed' if ret.negative?
            self
          end

          def match_property(name, value)
            ret = Udev::C.udev_enumerate_add_match_property(@enum, name, value)
            raise UdevException, 'udev_enumerate_add_match_property failed' if ret.negative?
            self
          end

          def match_parent(dev)
            ret = Udev::C.udev_enumerate_add_match_parent(@enum, dev.instance_variable_get('@dev'))
            raise UdevException, 'udev_enumerate_add_match_parent failed' if ret.negative?
            self
          end

          def each
            return to_enum(:each) unless block_given?

            ret = Udev::C.udev_enumerate_scan_devices(@enum)
            raise UdevException, 'udev_enumerate_scan_devices failed' if ret.negative?

            list = Udev::C.udev_enumerate_get_list_entry(@enum)
            # rubocop:disable Performance/HashEachMethods
            Udev::List.new(list).each { |k, _| yield Device.new(@udev, k) }
            # rubocop:enable Performance/HashEachMethods
          end
        end

        class Device
          def initialize(udev, path)
            @udev = udev
            @dev  = Udev::C.udev_device_new_from_syspath(@udev, path)
            raise UdevException, 'udev_device_new_from_syspath failed' if @dev.null?

            ::ObjectSpace.define_finalizer(self, self.class.release(@dev))
          end

          def initialize_copy(copy)
            Udev::C.udev_device_ref(@dev)
          end

          def self.release(dev)
            proc { Udev::C.udev_device_unref(dev) }
          end

          def sysname
            ret = Udev::C.udev_device_get_sysname(@dev)
            raise UdevException, 'udev_device_get_sysname failed' if ret.nil?
            ret
          end

          def properties
            Udev::Map.new { |k| Udev::C.udev_device_get_property_value(@dev, k) }
          end

          def attributes
            Udev::Map.new { |k| Udev::C.udev_device_get_sysattr_value(@dev, k) }
          end
        end

        class Map
          def initialize(&block)
            @block = block
          end

          def [](key)
            @block.call(key)
          end
        end

        class List
          include Enumerable

          def initialize(list)
            @list = list
          end

          def each
            return to_enum(:each) unless block_given?

            entry = @list
            until entry.null?
              k = Udev::C.udev_list_entry_get_name(entry)
              v = Udev::C.udev_list_entry_get_value(entry)
              yield k, v
              entry = Udev::C.udev_list_entry_get_next(entry)
            end
          end
        end

        def initialize
          @udev = Udev::C.udev_new
          raise UdevException, 'udev_new failed' if @udev.null?

          ::ObjectSpace.define_finalizer(self, self.class.release(@udev))
        end

        def initialize_copy(copy)
          Udev::C.udev_ref(@udev)
        end

        def self.release(udev)
          proc { Udev::C.udev_unref(udev) }
        end

        def enumerate
          Udev::Enumerate.new(@udev)
        end
      end

      def self.sectors_to_bytes(nsector)
        # /sys/block/*/size returns the number of 512 bytes sectors (Linux's sector_t)
        nsector.to_i * 512 unless nsector.nil?
      end

      def self.scsi_devices
        udev = Udev.new
        enum = udev.enumerate.match_subsystem('scsi').match_property('DEVTYPE', 'scsi_device')

        enum.reduce(::Mash.new) do |result, dev|
          blkdev = udev.enumerate.match_parent(dev).match_subsystem('block').first
          next result if blkdev.nil?

          sysname = dev.sysname
          host, channel, target, lun = sysname.split(':')

          result.merge!(sysname => ::Mash.new(
            host:    host.to_i,
            channel: channel.to_i,
            target:  target.to_i,
            lun:     lun.to_i,
            model:   blkdev.properties['ID_MODEL'],
            fwrev:   blkdev.properties['ID_REVISION'],
            serial:  blkdev.properties['ID_SERIAL_SHORT'],
            size:    sectors_to_bytes(blkdev.attributes['size']),
            wwn:     blkdev.properties['ID_WWN_WITH_EXTENSION'],
          ),)
        end
      end
    rescue LoadError
      # rubocop:disable Lint/DuplicateMethods
      def self.scsi_devices
        ::Chef::Log.warn 'failed to load libudev'
        ::Mash.new
      end
      # rubocop:enable Lint/DuplicateMethods
    end
  end
end
