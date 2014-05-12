require 'spec_helper'

describe PagesHelper do
  it 'concats two strings with spaces' do
    helper.concat_strings("this", "that").should eq "this that"
  end
end
