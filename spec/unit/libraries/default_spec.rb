require 'spec_helper.rb'
require_relative '../../../libraries/default.rb'

describe ::SCSI do
  describe 'the method .devices' do
    let(:node) { ::Chef::Node.new }
    subject { -> { described_class.devices(node) } }

    context 'on a Linux node' do
      before do
        node.automatic['os'] = 'linux'
        require_relative '../../../libraries/linux.rb'
      end

      it 'calls ::SCSI::Linux.scsi_devices and returns its result' do
        result = double(:result)
        expect(::SCSI::Linux).to receive(:scsi_devices).and_return result
        expect(subject.call).to be result
      end
    end

    context 'on a Windows node' do
      before do
        node.automatic['os'] = 'windows'
        require_relative '../../../libraries/windows.rb'
      end

      it 'calls ::SCSI::Windows.scsi_devices and returns its result' do
        result = double(:result)
        expect(::SCSI::Windows).to receive(:scsi_devices).and_return result
        expect(subject.call).to be result
      end
    end

    context 'on a non supported OS' do
      before { node.automatic['os'] = 'mac_os_x' }

      it 'returns an empty mash' do
        expect(subject.call).to be_a(::Mash).and be_empty
      end
    end
  end
end
