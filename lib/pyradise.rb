require 'rubygems'
require 'open-uri'
require 'do_sqlite3'
require 'dm-core'
#require "dm-tokyo-adapter"
require 'pyradise/product'
require 'pyradise/stat'

#TODO: def init
HOME = ENV['HOME'] + "/.pyradise/"
#DataMapper.setup(:default, :adapter => 'tokyo_cabinet', :database => 'data.tct', :path => HOME)
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
        parse(txt[:txt], txt[:delimiter]).each do |p|
          if prod = Product.first(:name => p[:name], :store => txt[:store])
            prod.price = p[:price]
          else
            Product.create(p.merge(:store => txt[:store]))
          end
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
        products << { :sid => sid.strip, :name => name.strip.gsub(/\.{2,}/, ""), :price => price.to_i }
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
      t = Time.now
      w = terminal_size[0]
      q = {}
      q.merge!(:name.like => "%#{query[0]}%") if query[0]
      q.merge!(:order => [query[1]]) if query[1]
      puts "Searching #{'"' + query[0] + '"' if query[0]}... Order by: #{query[1] || 'name'}"
      puts "_" * w
      prods = q.empty? ? Product.all : Product.all(q)
      prods.each do |prod|
        s = w - 35
        name = prod.name.length > s ? prod.name[0..s] + ".." : prod.name
        puts sprintf("%-6s | %-5s | %-#{w-38}s %-3d |  R$ %d", prod.store, prod.sid,  name,  prod.price, prod.price * DOLETA * TAX)
      end
      puts "_" * w
      puts "Total: #{prods.length} (#{Time.now - t}s)"
    end

    def view(sid)
      if !sid
        puts "Use: pyradise view <ID>"
      elsif !prod = Product.first(:sid => sid.to_i)
        puts "Product not found."
      else
        w = terminal_size[0] - 20
        prices = prod.prices
        max = prices.values.max.to_f
        prices.keys.sort.each do |k|
          rel = "=" * (prices[k]  / max * w)
          puts "#{Time.at(k).strftime('%M/%d')} #{rel}| #{prices[k]}"
        end
      end
    end

    def clear
      Product.all.destroy
    end

    #from highliner
    def terminal_size
      `stty size`.split.map { |x| x.to_i }.reverse
    end

    def red(txt)
      "[e[31m#{txt}e[0m]"
    end
  end
end
