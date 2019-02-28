require 'json'
require 'chefspec'
require 'chefspec/berkshelf'

# Disable ::SCSI.devices mock
ENV['MOCK_BUS_SCSI_INFO'] = 'NO'

# Helper to get input/output test vectors
SPEC_DATA_DIR = ::File.join(__dir__, 'data')
def example_data(name)
  input  = ::File.join(SPEC_DATA_DIR, "#{name}.in")
  output = ::File.join(SPEC_DATA_DIR, "#{name}.out")
  [::YAML.load_file(input), ::YAML.load_file(output)]
end

::RSpec.configure do |config|
  ::Chef::Log.level(config.log_level = :fatal)
end
