require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'pyradise'
DB = Sequel.connect("sqlite://#{HOME}/py_test.sqlite3")

unless DB.table_exists? :products
  require 'pyradise/migrate'
  CreatePyradise.apply DB, :up
end

Spec::Runner.configure do |config|

end

