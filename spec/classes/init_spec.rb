require 'spec_helper'
describe 'radius-auth' do

  context 'with defaults for all parameters' do
    it { should contain_class('radius-auth') }
  end
end
