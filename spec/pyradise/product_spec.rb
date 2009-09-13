require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Product" do

  before do
    Product.dataset.delete
    Time.stub_chain(:now, :to_i).and_return(88)
    @p = Product.create(:sid => "111", :store => "foo", :name => "CPU", :price => 1000).should be_true
  end

  it "should have a price" do
    @p.price.should eql(1000)
  end

  it "should have a store" do
    @p.store.should eql("foo")
  end

  it "should have prices" do
    @p.prices.should eql({88=>1000})
  end

  it "should store another price in prices (merge)" do
    Time.stub_chain(:now, :to_i).and_return(99)
    @p.price = 1300
    @p.save
    @p.prices.should eql({88=>1000, 99=>1300})
  end

  it "should have a better way to do that.." do
    Time.stub_chain(:now, :to_i).and_return(99)
    @p.new_price!(800)
    @p.prices.should eql({88=>1000, 99=>800})
  end

  it "should clean up" do
    Product.all.each(&:destroy)
    Product.all.should be_empty
  end
end
