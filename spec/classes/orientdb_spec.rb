require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'orientdb' do

  let(:title) { 'orientdb' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }

  describe 'Test standard installation via package' do
    let(:params) { {:install => 'package' } }

    it { should contain_package('orientdb').with_ensure('present') }
  end

  describe 'Test installation via netinstall' do
    let(:params) { {:version => '1.0' } }
    it 'should install version 1.0 via netinstall' do
      content = catalogue.resource('puppi::netinstall', 'netinstall_orientdb').send(:parameters)[:url]
      content.should match "http://orient.googlecode.com/files/orientdb-1.0.zip"
    end
  end

  describe 'Test installation via puppi' do
    let(:params) { {:version => '1.0' , :install => 'puppi' } }
    it 'should install version 1.0 via puppi' do
      content = catalogue.resource('puppi::project::archive', 'orientdb').send(:parameters)[:source]
      content.should match "http://orient.googlecode.com/files/orientdb-1.0.zip"
    end
  end

  describe 'Test package installation with monitoring and firewalling' do
    let(:params) { {:monitor => true , :install => 'package' , :firewall => true, :port => '42', :protocol => 'tcp' } }

    it { should contain_package('orientdb').with_ensure('present') }
    it 'should monitor the process' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:enable]
      content.should == true
    end
    it 'should place a firewall rule' do
      content = catalogue.resource('firewall', 'orientdb_tcp_42').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test decommissioning - absent' do
    let(:params) { {:absent => true, :install => 'package', :monitor => true , :firewall => true, :port => '42', :protocol => 'tcp'} }

    it 'should remove Package[orientdb]' do should contain_package('orientdb').with_ensure('absent') end 
    it 'should not enable at boot Service[orientdb]' do should contain_service('orientdb').with_enable('false') end
    it 'should not monitor the process' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:enable]
      content.should == false
    end
    it 'should remove a firewall rule' do
      content = catalogue.resource('firewall', 'orientdb_tcp_42').send(:parameters)[:enable]
      content.should == false
    end
  end

  describe 'Test decommissioning - disable' do
    let(:params) { {:disable => true, :install => 'package', :monitor => true , :firewall => true, :port => '42', :protocol => 'tcp'} }

    it { should contain_package('orientdb').with_ensure('present') }
    it 'should not monitor the process' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:enable]
      content.should == false
    end
    it 'should remove a firewall rule' do
      content = catalogue.resource('firewall', 'orientdb_tcp_42').send(:parameters)[:enable]
      content.should == false
    end
  end

  describe 'Test decommissioning - disableboot' do
    let(:params) { {:disableboot => true, :install => 'package', :monitor => true , :firewall => true, :port => '42', :protocol => 'tcp'} }
  
    it { should contain_package('orientdb').with_ensure('present') }
    it 'should not enable at boot Service[orientdb]' do should contain_service('orientdb').with_enable('false') end
    it 'should not monitor the process locally' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:enable]
      content.should == false
    end
    it 'should keep a firewall rule' do
      content = catalogue.resource('firewall', 'orientdb_tcp_42').send(:parameters)[:enable]
      content.should == true
    end
  end 

  describe 'Test customizations - template' do
    let(:params) { {:template => "orientdb/spec.erb" , :options => { 'opt_a' => 'value_a' } } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'orientdb.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
    it 'should generate a template that uses custom options' do
      content = catalogue.resource('file', 'orientdb.conf').send(:parameters)[:content]
      content.should match "value_a"
    end

  end

  describe 'Test customizations - source' do
    let(:params) { {:source => "puppet://modules/orientdb/spec" , :source_dir => "puppet://modules/orientdb/dir/spec" , :source_dir_purge => true } }

    it 'should request a valid source ' do
      content = catalogue.resource('file', 'orientdb.conf').send(:parameters)[:source]
      content.should == "puppet://modules/orientdb/spec"
    end
    it 'should request a valid source dir' do
      content = catalogue.resource('file', 'orientdb.dir').send(:parameters)[:source]
      content.should == "puppet://modules/orientdb/dir/spec"
    end
    it 'should purge source dir if source_dir_purge is true' do
      content = catalogue.resource('file', 'orientdb.dir').send(:parameters)[:purge]
      content.should == true
    end
  end

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "orientdb::spec" , :template => "orientdb/spec.erb"} }
    it 'should automatically include a custom class' do
      content = catalogue.resource('file', 'orientdb.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
  end

  describe 'Test Puppi Integration' do
    let(:params) { {:puppi => true, :puppi_helper => "myhelper"} }

    it 'should generate a puppi::ze define' do
      content = catalogue.resource('puppi::ze', 'orientdb').send(:parameters)[:helper]
      content.should == "myhelper"
    end
  end

  describe 'Test Monitoring Tools Integration' do
    let(:params) { {:monitor => true, :monitor_tool => "puppi" } }

    it 'should generate monitor defines' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:tool]
      content.should == "puppi"
    end
  end

  describe 'Test Firewall Tools Integration' do
    let(:params) { {:firewall => true, :firewall_tool => "iptables" , :protocol => "tcp" , :port => "42" } }

    it 'should generate correct firewall define' do
      content = catalogue.resource('firewall', 'orientdb_tcp_42').send(:parameters)[:tool]
      content.should == "iptables"
    end
  end

  describe 'Test OldGen Module Set Integration' do
    let(:params) { {:monitor => "yes" , :monitor_tool => "puppi" , :firewall => "yes" , :firewall_tool => "iptables" , :puppi => "yes" , :port => "42" , :protocol => 'tcp' } }

    it 'should generate monitor resources' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:tool]
      content.should == "puppi"
    end
    it 'should generate firewall resources' do
      content = catalogue.resource('firewall', 'orientdb_tcp_42').send(:parameters)[:tool]
      content.should == "iptables"
    end
    it 'should generate puppi resources ' do 
      content = catalogue.resource('puppi::ze', 'orientdb').send(:parameters)[:ensure]
      content.should == "present"
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => true , :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }
    let(:params) { { :port => '42' } }

    it 'should honour top scope global vars' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :orientdb_monitor => true , :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }
    let(:params) { { :port => '42' } }

    it 'should honour module specific vars' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :orientdb_monitor => true , :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }
    let(:params) { { :port => '42' } }

    it 'should honour top scope module specific over global vars' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :ipaddress => '10.42.42.42' , :operatingsystem => 'ubuntu' } }
    let(:params) { { :monitor => true , :firewall => true, :port => '42' } }

    it 'should honour passed params over global vars' do
      content = catalogue.resource('monitor::process', 'orientdb_process').send(:parameters)[:enable]
      content.should == true
    end
  end

end

