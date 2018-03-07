require 'spec_helper'
require_relative '../../../libraries/windows.rb'

describe ::SCSI::Windows do
  describe 'the method .scsi_devices' do
    subject { -> { described_class.scsi_devices } }

    it 'returns the SCSI device tree' do
      input, output = example_data('scsi-devices-windows')

      wmi = double('wmi')
      expect(wmi).to receive(:instances_of).with('Win32_DiskDrive').and_return input
      expect(::WmiLite::Wmi).to receive(:new).and_return wmi

      expect(subject.call).to eq output
    end
  end
end
