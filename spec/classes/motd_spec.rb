require 'spec_helper'

describe 'motd', type: :class do
  describe 'On a non-linux system' do
    let(:facts) { { kernel: 'Unknown' } }
    it 'should not fail' do
      expect do
        subject
      end.not_to raise_error
    end
    it { should_not contain_file('/etc/motd') }
    it { should_not contain_file('/etc/issue') }
    it { should_not contain_file('/etc/issue.net') }
  end

  describe 'On Linux' do
    let(:facts) do
      {
        kernel: 'Linux',
        operatingsystem: 'TestOS',
        operatingsystemrelease: 5,
        osfamily: 'Debian',
        architecture: 'x86_64',
        processor0: 'intel awesome',
        fqdn: 'test.example.com',
        ipaddress: '123.23.243.1',
        memoryfree: '1 KB'
      }
    end
    context 'When neither template or source are specified' do
      it do
        should contain_File('/etc/motd').with(
          ensure: 'file',
          backup: 'false',
          content: "TestOS 5 x86_64\n\nFQDN:         test.example.com (123.23.243.1)\nProcessor:    intel awesome\nKernel:       Linux\nMemory Free:  1 KB\n"
        )
      end
    end

    context 'When both template and source are specified' do
      let(:params) do
        {
          content: 'Hello!',
          template: 'motd/spec.erb'
        }
      end
      it do
        should contain_File('/etc/motd').with(
          ensure: 'file',
          backup: 'false',
          content: "Test Template for Rspec\n"
        )
      end
    end

    context 'When a source is specified' do
      let(:params) { { content: 'Hello!' } }
      it do
        should contain_File('/etc/motd').with(
          ensure: 'file',
          backup: 'false',
          content: 'Hello!'
        )
      end
    end

    context 'When an external template is specified' do
      let(:params) { { template: 'motd/spec.erb' } }
      it do
        should contain_File('/etc/motd').with(
          ensure: 'file',
          backup: 'false',
          content: "Test Template for Rspec\n"
        )
      end
    end

    context 'When a template is specified for /etc/issue' do
      let(:params) { { issue_template: 'motd/spec.erb' } }
      it do
        should contain_File('/etc/issue').with(
          ensure: 'file',
          backup: 'false',
          content: "Test Template for Rspec\n"
        )
      end
    end

    context 'When content is specified for /etc/issue' do
      let(:params) { { issue_content: 'Hello!' } }
      it do
        should contain_File('/etc/issue').with(
          ensure: 'file',
          backup: 'false',
          content: 'Hello!'
        )
      end
    end

    context 'When both content and template is specified for /etc/issue' do
      # FIXME duplicate behaviour described in FM-5956 until I'm allowed to fix it
      let(:params) do
        {
          issue_content: 'Hello!',
          issue_template: 'motd/spec.erb'
        }
      end
      it do
        should contain_File('/etc/issue').with(
          ensure: 'file',
          backup: 'false',
          content: "Test Template for Rspec\n"
        )
      end
    end

    context 'When a template is specified for /etc/issue.net' do
      let(:params) { { issue_net_template: 'motd/spec.erb' } }
      it do
        should contain_File('/etc/issue.net').with(
          ensure: 'file',
          backup: 'false',
          content: "Test Template for Rspec\n"
        )
      end
    end

    context 'When content is specified for /etc/issue.net' do
      let(:params) { { issue_net_content: 'Hello!' } }
      it do
        should contain_File('/etc/issue.net').with(
          ensure: 'file',
          backup: 'false',
          content: 'Hello!'
        )
      end
    end

    context 'When both content and template is specified for /etc/issue.net' do
      # FIXME duplicate behaviour described in FM-5956 until I'm allowed to fix it
      let(:params) do
        {
          issue_net_content: 'Hello!',
          issue_net_template: 'motd/spec.erb'
        }
      end
      it do
        should contain_File('/etc/issue.net').with(
          ensure: 'file',
          backup: 'false',
          content: "Test Template for Rspec\n"
        )
      end
    end
  end

  describe 'On Debian based Operating Systems' do
    let(:facts) do
      {
        kernel: 'Linux',
        operatingsystem: 'Debian',
        operatingsystemmajrelease: '7',
        osfamily: 'Debian'
      }
    end

    context 'When dynamic motd is false' do
      let(:params) { { dynamic_motd: false } }
      it { should contain_file_line('dynamic_motd').with_line('session    optional     pam_motd.so  motd=/run/motd.dynamic noupdate') }
    end

    context 'When dynamic motd is true' do
      let(:params) { { dynamic_motd: true } }
      it { should_not contain_file_line('dynamic_motd') }
    end
  end
  describe 'On Windows' do
    let(:facts) do
      {
        kernel: 'windows',
        operatingsystem: 'TestOS',
        operatingsystemrelease: 5,
        osfamily: 'windows',
        architecture: 'x86_64',
        processor0: 'intel awesome',
        fqdn: 'test.example.com',
        ipaddress: '123.23.243.1',
        memoryfree: '1 KB'
      }
    end
    context 'When neither template or source are specified' do
      it do
        should contain_Registry_value('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext').with(
          ensure: 'present',
          type: 'string',
          data: "TestOS 5 x86_64\n\nFQDN:         test.example.com (123.23.243.1)\nProcessor:    intel awesome\nKernel:       windows\nMemory Free:  1 KB\n"
        )
      end
    end
    context 'When content is specified' do
      let(:params) do
        {
          content: 'Hello!'
        }
      end
      it do
        should contain_Registry_value('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext').with(
          ensure: 'present',
          type: 'string',
          data: 'Hello!'
        )
      end
    end
  end
end
