require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'pyradise'
 DataMapper.setup(:default, :adapter => 'sqlite3', :database => HOME + "pytest.sqlite3")
 DataMapper.auto_migrate!

Spec::Runner.configure do |config|

end
