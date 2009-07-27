class Stat
 include DataMapper::Resource

  property :id, Serial
  property :key, String
  property :value, String, :nullable => false, :length => (2..20)

end
