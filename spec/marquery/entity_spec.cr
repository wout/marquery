require "../spec_helper"

describe Marquery::Entity do
  it "includes Marquery::Model" do
    query = DefaultModelQuery.new

    query.all.first.should be_a(Marquery::Entity)
  end

  it "has all base fields" do
    entry = DefaultModelQuery.new.all.first

    entry.slug.should be_a(String)
    entry.title.should be_a(String)
    entry.content.should be_a(String)
    entry.date.should be_a(Time)
  end
end
