require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Product" do
  it "should create a product" do
    Stat.create(:key => "update", :value => Marshal.dump(Time.now))
#    Stat.first.destroy
    Stat.all.length.should eql(1)
  end

  it "should list products" do
    Stat.all.should_not be_empty
  end
end
