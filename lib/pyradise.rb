require 'rubygems'
require 'open-uri'
require 'sequel'

#TODO: def init
HOME = ENV['HOME'] + "/.pyradise"
FileUtils.mkdir_p HOME unless File.exists? HOME

DB = Sequel.connect("sqlite://#{HOME}/py.sqlite3")
require 'pyradise/product'
# require 'pyradise/stat'

unless DB.table_exists? :products
  require 'pyradise/migrate'
  CreatePyradise.apply DB, :up
end

module Pyradise

  CONF = YAML.load(File.new(HOME + "/conf.yml"))
  RATE = CONF[:rate] || 2.1
  TAX = CONF[:tax] || 1.3

  class << self

    def run! comm, opts
      if respond_to? comm[0]
        send(*comm)
      else
        puts "Can't do that..."
        exit
      end
    end

    def fetch
      create fetch_stores
    end

    def list(*query)
      t = Time.now
      w = terminal_size[0]
      s = w - 35
      puts "Searching #{'"' + query[0] + '"' if query[0]}... Order by: #{query[1] || 'name'}"
      puts "_" * w
      prods = Product.filter(:name.like("%#{query[0]}%")).order(query[1] ? query[1].to_sym : :name)
      prods.each_with_index do |prod, i|
        name = prod.name.length > s ? prod.name[0..s] + ".." : prod.name
        out = sprintf("%-6s | %-5s | %-#{w-38}s %-3d |  R$ %d", prod.store, prod.sid,  name,  prod.price, prod.price * RATE * TAX)
        puts i % 2 == 0 ? bold(out) : out
      end
      puts "_" * w
      puts green("Total: #{prods.all.length} (#{Time.now - t}s)")
    end
    alias :search :list

    def info(sid=nil)
      if !sid
        puts red("Use: pyradise view <ID>")
      elsif !prod = Product.filter(:sid => sid.to_i).first
        puts yellow("Product not found.")
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
    alias :show :info

    def clear
      Product.dataset.delete
    end

    private

    def create txts
      products = []
      for txt in txts
        print "Parsing #{txt[:store]}..."
        c = Product.all.length
        parse(txt[:txt], txt[:delimiter]).each do |t|
          next if t[:price] == 0
          create_product(t, txt[:store].to_s)
        end
        puts "#{Product.all.length - c} products created."
      end
    end

    def create_product(t, store)
      if prod = Product.filter(:name => t[:name], :store => store).first
        prod.new_price!(t[:price]) if t[:price] != prod.price
      else
        Product.create(t.merge(:store => store))
      end
      rescue  => e
      puts "SQLITE Err #{e}, #{t.inspect} - #{store} #{prod}"
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
        sid, *info = l.split(del)
        next if info.length < 2
        price = info.delete_at(-1).strip.to_i
        next if price.nil? || price.zero?
        products << { :sid => sid.strip, :name => info.join("").strip.gsub(/\.{2,}/, ""), :price => price }
      end
      products
    end

    #from highliner
    def terminal_size
      `stty size`.split.map { |x| x.to_i }.reverse
    end

    def red(txt);      "\e[31m#{txt}\e[0m";    end
    def green(txt);    "\e[32m#{txt}\e[0m";    end
    def yellow(txt);   "\e[33m#{txt}\e[0m";    end
    def bold(txt);      "\e[2m#{txt}\e[0m";    end
  end
end
