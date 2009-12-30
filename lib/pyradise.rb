require 'open-uri'
require 'sequel'

module Pyradise

  HOME = ENV['HOME'] + "/.pyradise"
  DB = Sequel.connect("sqlite://#{HOME}/py.sqlite3")
  Defaults = {:rate => 1, :tax => 1.3, :order => :price, :lang => :en_us}
  Options  = Defaults.merge(YAML.load(File.new(HOME + "/conf.yml")))
  
  def locale
    `locale | grep LANG`.scan(/LANG=(.*)\./)[0][0].downcase rescue "en_us"
  end

  def self.start
    unless File.exists? HOME
      FileUtils.mkdir_p HOME
      conf = open(HOME + "/conf.yml", "wb")
      conf.write(":rate: 1.8  # dollar conversion rate\n")
      conf.write(":tax:  1.3  # transport tax\n")
      conf.write(":lang: #{locale}  # program language\n")
      conf.close
    end

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
