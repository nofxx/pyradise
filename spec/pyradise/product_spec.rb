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
end
