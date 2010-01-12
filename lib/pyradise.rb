require 'open-uri'
require 'sequel'

HOME = ENV['HOME'] + "/.pyradise"
unless File.exists? HOME
  FileUtils.mkdir_p HOME
  locale = `locale | grep LANG`.scan(/LANG=(.*)\./)[0][0].downcase rescue "en_us"
  conf = open(HOME + "/conf.yml", "wb")
  conf.write(":rate: 1.8  # dollar conversion rate\n")
  conf.write(":tax:  1.3  # transport tax\n")
  conf.write(":lang: %s  # program language\n" % locale )
  conf.close
end

module Pyradise

  DB = Sequel.connect("sqlite://#{HOME}/py.sqlite3")
  Defaults = {:rate => 1, :tax => 1.3, :order => :price, :lang => :en_us}
  Options  = Defaults.merge(YAML.load(File.new(HOME + "/conf.yml")))

  def self.start
    # require 'pyradise/stat'
    unless DB.table_exists? :products
      require 'pyradise/migrate'
      CreatePyradise.apply DB, :up
    end

    require 'pyradise/product'
    require 'pyradise/i18n'
    require 'pyradise/cli'
  end

end

Pyradise.start
