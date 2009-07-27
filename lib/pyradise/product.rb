class Product
 include DataMapper::Resource

  property :id, Serial
  property :sid, String
  property :name, String, :nullable => false, :length => (2..20)
  property :price, Integer
  property :store, String
  # has n, :orders

  def self.count
    all.length
  end
  # def to_param
  #   id.to_s
  # end

end
