require 'spec_helper'

describe 'tomcat::config::context::loader', :type => :define do
  let :pre_condition do
    'class {"tomcat": }'
  end
  let :facts do
    {
      :osfamily => 'Debian',
      :augeasversion => '1.0.0'
    }
  end
  let :title do
    'TomcatInstrumentableClassLoader'
  end
  context 'Add Loader' do
    let :params do
      {
        :catalina_base         => '/opt/apache-tomcat/test',
        :loader_class           => 'org.springframework.instrument.classloading.tomcat.TomcatInstrumentableClassLoader',
        :additional_attributes => {
          'searchExternalFirst' => 'false',
          'delegate'            => 'true',
          'reloadable'          => 'true',
        },
        :attributes_to_remove  => [
          'foobar',
        ],
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-loader-TomcatInstrumentableClassLoader').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'set Context/Loader[#attribute/loaderClass=\'org.springframework.instrument.classloading.tomcat.TomcatInstrumentableClassLoader\']/#attribute/loaderClass org.springframework.instrument.classloading.tomcat.TomcatInstrumentableClassLoader',
        'set Context/Loader[#attribute/loaderClass=\'org.springframework.instrument.classloading.tomcat.TomcatInstrumentableClassLoader\']/#attribute/searchExternalFirst \'false\'',
        'set Context/Loader[#attribute/loaderClass=\'org.springframework.instrument.classloading.tomcat.TomcatInstrumentableClassLoader\']/#attribute/delegate \'true\'',
        'set Context/Loader[#attribute/loaderClass=\'org.springframework.instrument.classloading.tomcat.TomcatInstrumentableClassLoader\']/#attribute/reloadable \'true\'',
        'rm Context/Loader[#attribute/loaderClass=\'org.springframework.instrument.classloading.tomcat.TomcatInstrumentableClassLoader\']/#attribute/foobar',
        ]
      )
    }
  end
  context 'Remove Loader' do
    let :params do
      {
        :catalina_base => '/opt/apache-tomcat/test',
        :ensure        => 'absent',
      }
    end
    it { is_expected.to contain_augeas('context-/opt/apache-tomcat/test-loader-TomcatInstrumentableClassLoader').with(
      'lens' => 'Xml.lns',
      'incl' => '/opt/apache-tomcat/test/conf/context.xml',
      'changes' => [
        'rm Context/Loader[#attribute/loaderClass=\'TomcatInstrumentableClassLoader\']',
        ]
      )
    }
  end
end
