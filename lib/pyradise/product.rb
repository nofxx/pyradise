class Product < Sequel::Model

  def before_save
    phist = { Time.now.to_i => price }
    self[:prices] = Marshal.dump(prices ? prices.merge(phist) : phist)
  end

  def prices
    self[:prices] ? Marshal.load(self[:prices]) : nil
  end

  def new_price!(np)
    self.update(:prices => Marshal.dump(prices ? prices.merge({Time.now.to_i => np}) : np))
  end

end
