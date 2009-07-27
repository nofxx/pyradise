require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Product" do
  it "should create a product" do
    Product.create(:sid => "111", :name => "CPU", :price => 1000).should be_true
  end

  it "should list products" do
    Product.all.length.should eql(1)
  end

  it "should clean up" do
    Product.first.destroy
    Product.all.should be_empty
  end

  it "should store all prices" do
    Time.stub_chain(:now, :to_i).and_return(1)
    p = Product.create(:name => "foo", :price => 1300)
    p.prices.should eql({1 => 1300})
    p.prices = { 2 => 1000 }
    p.prices.should eql({1 => 1300, 2 => 1000})
  end


end
