require 'spec_helper'

augeas_file = Puppet::Type.type(:augeas_file)

describe augeas_file do
  context 'when augeas is present', :if => Puppet.features.augeas? do
    it 'should have a default provider inheriting from Puppet::Provider' do
      expect(augeas_file.defaultprovider.ancestors).to be_include(Puppet::Provider)
    end

    it 'should have a valid provider' do
      expect(augeas_file.new(:path => '/foo').provider.class.ancestors).to be_include(Puppet::Provider)
    end
  end

  describe 'basic structure' do
    it 'should be able to create an instance' do
      provider_class = Puppet::Type::Augeas_file.provider(Puppet::Type::Augeas_file.providers[0])
      Puppet::Type::Augeas_file.expects(:defaultprovider).returns provider_class
      expect(augeas_file.new(:path => '/bar')).not_to be_nil
    end

    properties = [:returns]
    params = [:path, :base, :lens, :root, :load_path, :type_check, :show_diff, :changes]

    properties.each do |property|
      it "should have a #{property} property" do
        expect(augeas_file.attrclass(property).ancestors).to be_include(Puppet::Property)
      end

      it "should have documentation for its #{property} property" do
        expect(augeas_file.attrclass(property).doc).to be_instance_of(String)
      end
    end

    params.each do |param|
      it "should have a #{param} parameter" do
        expect(augeas_file.attrclass(param).ancestors).to be_include(Puppet::Parameter)
      end

      it "should have documentation for its #{param} parameter" do
        expect(augeas_file.attrclass(param).doc).to be_instance_of(String)
      end
    end
  end

  describe 'default values' do
    before do
      provider_class = augeas_file.provider(augeas_file.providers[0])
      augeas_file.expects(:defaultprovider).returns provider_class
    end

    it 'should be / for root' do
      expect(augeas_file.new(:name => :root)[:root]).to eq("/")
    end

    it 'should be blank for load_path' do
      expect(augeas_file.new(:name => :load_path)[:load_path]).to eq("")
    end

    it 'should be false for type_check' do
      expect(augeas_file.new(:name => :type_check)[:type_check]).to eq(:false)
    end

    it 'should be true for show_diff' do
      expect(augeas_file.new(:name => :show_diff)[:show_diff]).to eq(:true)
    end

    it 'should be [] for changes' do
      expect(augeas_file.new(:name => :changes)[:changes]).to eq([])
    end
  end

  describe 'provider interaction' do

    it 'should return 0 if it does not need to apply' do
      provider = stub('provider', :need_to_apply? => false)
      resource = stub('resource', :resource => nil, :provider => provider, :line => nil, :file => nil)
      changes = augeas_file.attrclass(:returns).new(:resource => resource)
      expect(changes.retrieve).to eq(0)
    end

    it 'should return :need_to_apply if it needs to apply' do
      provider = stub('provider', :need_to_apply? => true)
      resource = stub('resource', :resource => nil, :provider => provider, :line => nil, :file => nil)
      changes = augeas_file.attrclass(:returns).new(:resource => resource)
      expect(changes.retrieve).to eq(:need_to_apply)
    end
  end
end
