require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Pyradise" do
  it "should fetch the stores" do
    pending
    Time.stub_chain(:now, :to_i).and_return(55)
    Pyradise.should_receive(:open).with("a","wb").and_return(mf = mock("File"))
    Pyradise.should_receive(:open).with("http://www.master10.com.py/importar/arquivos/lista.master.txt").and_return(mr = mock("Remote"))
    mr.should_receive(:read).and_return("11| Cool stuff | 20.00")
    mf.should_receive(:write).with("11| Cool stuff | 20.00").and_return true
    mf.should_receive(:close).and_return true
    Product.should_receive(:create).with({:store=>:master,:sid=>"11", :price=>" 20.00", :name=>" Cool stuff "})
    Pyradise.fetch.should be_true
  end


end

