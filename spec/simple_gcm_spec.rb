require 'spec_helper'

#
# Pending real tests. Trying to work out how to 
# automate GCM without a real device ID and APP key
#


describe SimpleGCM, "notify" do
  context "with invalid key" do
    before :all do
      @response = SimpleGCM.notify ["42", "54"], 
        key: "abcdef", 
        dry_run: true,
        data: {
          message: "Hello World!"
        }
    end

    it "should have errors" do
      @response.errors?.should eq(true)
    end
  end
end