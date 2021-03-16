require "./spec_helper"

describe Office365::OData do
  it "#in" do
    query = Office365::OData.in("id", ["11cbafa6-ffd9-4c79-8685-da18cf653ee4", "4cfb95b4-6c35-4e3b-9128-d829cbb11cd3"])
    query.should eq("(id in ('11cbafa6-ffd9-4c79-8685-da18cf653ee4', '4cfb95b4-6c35-4e3b-9128-d829cbb11cd3'))")
  end
end
