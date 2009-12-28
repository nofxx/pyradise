module Pyradise
  class Cli

    class << self
      include I18n

      def run! comm
        if respond_to? comm[0]
          send(*comm)
        else
          puts "Can't do that..."
          exit
        end
      end

      def fetch
        create from_stores
      end

      def list(*query)
        p query
        t = Time.now
        w = terminal_size[0]
        s = w - 36
        puts "\n#{t(:search)} #{'"' + green(query.join(" ")) + '"' if query[0]}... #{t(:order)}: #{green(Options[:order])}"
#        puts "_" * w
        puts
        prods = Product.filter(:name.like("%#{query.join("%")}%")).order(Options[:order])
        prods.each_with_index do |prod, i|
          name = prod.name.length > s ? prod.name[0..s] + ".. " : prod.name + " "
          for q in query
            b = i % 2 == 0 ? "\e[0m\e[2m" : "\e[0m\e[0m"
            replaces = name.scan(/#{q}/i).length
            name.gsub!(/#{q}/i, "\e[32m\\0#{b}")
            name += "." until name.length > w - 23
          end
          total_price = prod.price * Options[:rate] * Options[:tax]
          out = sprintf("%-6s | %-6s | %-#{s}s %-3d |  R$ %s", prod.store, prod.sid,  name,  prod.price, yellow(total_price.to_i))

          puts i % 2 == 0 ? bold(out) : out
        end
        puts "_" * w
        puts red("Total: #{prods.all.length} (#{Time.now - t}s)")
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

      #
      # Wipe all data
      def clear
        print t(:delete)
        return puts unless read_char =~ /y/
        Product.dataset.delete
        puts "\nDB cleared."
      end

      private

      def read_char
        system "stty raw -echo"
        out = STDIN.getc
        RUBY_PLATFORM =~ /1.9/ ? out : out.chr
      ensure
        system "stty -raw echo"
      end

      #
      # Create records from txt files
      def create txts
        products = []
        for txt in txts
          print "Parsing #{txt[:store]}..."
          c = Product.all.length
          parse(txt[:txt], txt[:delimiter]).each do |t|
            next if t[:price] == 0
            create_product(t, txt[:store].to_s)
          end
          puts "#{Product.all.length - c} #{t(:created)}."
        end
      end

      def create_product(t, store)
        if prod = Product.filter(:name => t[:name], :store => store).first
          prod.new_price!(t[:price]) if t[:price] != prod.price
        else
          Product.create(t.merge(:store => store))
        end
      rescue  => e
        puts "SQLITE Err => #{e}"
        p t[:name]
        puts t.inspect
      end

      def from_stores
        stores = []
        for store in YAML.load(File.new(File.dirname(__FILE__) + '/../stores.yml'))[:stores]
          data = {}
          data[:store] = store[0]
          data[:delimiter] = store[1][:delimiter]

          # Open URL
          next unless data[:txt] = fetch_store(store)

          # Open local file to write
          open("#{HOME}#{store[0]}-#{Time.now.to_i}.txt", "wb") do |dump|
            dump.write(data[:txt].gsub(/\t/, ""))
          end
          puts "Store #{store[0]} dumped."
          stores << data
        end
        stores
      end

      def fetch_store(store)
        open(store[1][:txt]).read
      rescue => e
        puts "#{store[0]} offline: #{e}.".capitalize
        nil
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

      # Get terminal size to fit the table nicely.
      # From highliner.
      def terminal_size
        `stty size`.split.map { |x| x.to_i }.reverse
      end

      def red(txt);      "\e[31m#{txt}\e[0m";    end
      def green(txt);    "\e[32m#{txt}\e[0m";    end
      def yellow(txt);   "\e[33m#{txt}\e[0m";    end
      def bold(txt);      "\e[2m#{txt}\e[0m";    end
    end



  end
end
