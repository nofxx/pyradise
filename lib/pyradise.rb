require 'rubygems'
require 'open-uri'
require 'do_sqlite3'
require 'dm-core'
require 'pyradise/product'
require 'pyradise/stat'

#TODO: def init
HOME = ENV['HOME'] + "/.pyradise/"
DataMapper.setup(:default, :adapter => 'sqlite3', :database => HOME + "py.sqlite3")
# DataMapper.auto_migrate!

module Pyradise

  DOLETA = 2.2
  TAX = 1.3

  class << self

    def run! comm, opts
      send(*comm)
    end

    def fetch
      create fetch_stores
    end

    def create txts
      products = []
      for txt in txts
        print "Parsing #{txt[:store]}..."
        c = Product.all.length
        Product.all(:store.like => txt[:store]).destroy
        parse(txt[:txt], txt[:delimiter]).each do |p|
          Product.create(p.merge(:store => txt[:store]))
        end
        puts "#{Product.all.length - c} products created."
      end
    end

    def fetch_stores
      stores = []
      for store in YAML.load(File.new(File.dirname(__FILE__) + '/stores.yml'))[:stores]
        data = {}
        data[:store] = store[0]
        data[:delimiter] = store[1][:delimiter]
        dump = open("#{HOME}#{store[0]}-#{Time.now.to_i}.txt", "wb")
        data[:txt] = open(store[1][:txt]).read
        dump.write(data[:txt])
        dump.close
        puts "Store #{store[0]} dumped... "
        stores << data
      end
      stores
    end

    def parse(txt, del)
      products = []
      txt.each_line do |l|
        sid, name, price = l.split(del)
        next unless price
        products << { :sid => sid, :name => name, :price => price }
      end
      products
    end

    def get_or_create_home
      unless File.exists? HOME
        FileUtils.mkdir_p HOME
      end
      HOME
    end

    def list(*query)
      q = {}
      q.merge!(:name.like => "%#{query[0]}%") if query[0]
      q.merge!(:order => [query[1]]) if query[1]

      prods = q.empty? ? Product.all : Product.all(q)
      prods.each do |prod|
        puts sprintf("%6s | %20s %6d |  R$ %d", prod.store, prod.name,  prod.price, prod.price * DOLETA * TAX)
      end
      puts "Total: #{prods.length}"
    end

    def clear
      Product.all.destroy
    end
  end
end
