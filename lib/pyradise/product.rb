class Product
 include DataMapper::Resource

  property :id, Serial
  property :sid, String
  property :name, String, :nullable => false, :length => (2..20)
  property :price, Integer
  property :store, String
  property :prices, Text
  # has n, :orders

  # def self.count
  #   all.length
  # end
  # def to_param
  #   id.to_s
  # end
  before :save do
#    self[:prices] = Marshal.dump({ Time.now.to_i => price })
    phist = { Time.now.to_i => price }
    self[:prices] = Marshal.dump(prices ? prices.merge(phist) : phist)

  end

  def prices
    self[:prices] ? Marshal.load(self[:prices]) : nil
  end

  def prices=(price)
    self[:prices] = Marshal.dump(prices ? prices.merge(price) : price)
  end


  #no idea why..
  def self.identity_field
    "product"
  end
end
