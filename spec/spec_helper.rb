require 'json'
require 'chefspec'
require 'chefspec/berkshelf'

# Helper to get input/output test vectors
SPEC_DATA_DIR = ::File.join(__dir__, 'data')
def example_data(name)
  input  = ::File.join(SPEC_DATA_DIR, "#{name}.in")
  output = ::File.join(SPEC_DATA_DIR, "#{name}.out")
  [::YAML.load_file(input), ::YAML.load_file(output)]
end

::RSpec.configure do |config|
  ::Chef::Log.level(config.log_level = :fatal)
  config.before do
    ::Chef::Config[:bus_scsi_disabled] = false
  end
end
