require 'spec_helper'

describe 'tomcat::connector' do

  let (:title) {'ConnectBar'}

  let :pre_condition do
    "class { 'tomcat': }"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :puppet_vardir => '/var/lib/puppet',
        })
      end

      context 'when using a wrong ensure value' do
        let (:params) {{
          :ensure   => 'foobar',
          :instance => 'instance1',
          :port     => '8422',
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/validate_re\(\):/)
        end
      end

      context 'when using a wrong port value' do
        let (:params) {{
          :ensure   => 'present',
          :instance => 'instance1',
          :port     => 'aaa',
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/validate_re\(\):/)
        end
      end

      context 'when using a wrong instance value' do
        let (:params) {{
          :ensure   => 'present',
          :instance => true,
          :port     => '8442',
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/.+ is not a string/)
        end
      end

      context 'when using a wrong owner value' do
        let (:params) {{
          :ensure   => 'present',
          :instance => 'instance1',
          :port     => '8442',
          :owner    => true
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/.+ is not a string/)
        end
      end

      context 'when using a wrong group value' do
        let (:params) {{
          :ensure   => 'present',
          :instance => 'instance1',
          :port     => '8442',
          :group    => true
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/.+ is not a string/)
        end
      end

      context 'when using a wrong connection_timeout value' do
        let (:params) {{
          :ensure   => 'present',
          :instance => 'instance1',
          :port     => '8442',
          :connection_timeout    => 'bbbb'
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/validate_re\(\)/)
        end
      end

      context 'when using a wrong redirect_port value' do
        let (:params) {{
          :ensure   => 'present',
          :instance => 'instance1',
          :port     => '8442',
          :redirect_port    => 'bbbb'
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/validate_re\(\)/)
        end
      end

      context 'when using a wrong options value' do
        let (:params) {{
          :ensure   => 'present',
          :instance => 'instance1',
          :port     => '8442',
          :options  => 'not_array'
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/.+ is not an Array/)
        end
      end

      context 'when using a wrong manage value' do
        let (:params) {{
          :ensure   => 'present',
          :instance => 'instance1',
          :port     => '8442',
          :manage   => 'bibi'
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/.+ is not a boolean/)
        end
      end

      context 'when using a wrong instance_basedir value' do
        let (:params) {{
          :ensure   => 'present',
          :instance => 'instance1',
          :port     => '8442',
          :instance_basedir => 'some/relative/path'
        }}
        it 'should fail' do
          expect { 
            is_expected.to compile.with_all_deps
          }.to raise_error(/.+ is not an absolute path/)
        end
      end

      context 'with params' do
        let(:params) {{
          :instance         => 'instance1',
          :port             => '8442',
          :instance_basedir => '/srv/tomcat',
        }}
        let(:pre_condition) do
          "class { 'tomcat': }
          tomcat::instance { 'instance1': }"
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat_fragment('connector_ConnectBar+01').with_content(/port="8442"/)
          is_expected.to contain_concat_fragment('connector_ConnectBar+99').with_content(/protocol="HTTP\/1.1"/)
          is_expected.to contain_concat('/srv/tomcat/instance1/conf/connector-ConnectBar.xml').with({
            'ensure'  => 'present',
            'owner'   => 'tomcat',
            'group'   => 'adm',
            'mode'    => '0460',
            'replace' => false,
          })
        }
      end
    end
  end
end
