require 'rubygems'
require 'pathname'
require 'fakeweb'
require 'dm-validations'

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'dm-rest-adapter'

ROOT = Pathname(__FILE__).dirname.parent

DataMapper.setup(:default, {
  :adapter => :rest,
  :host => "localhost",
  :port => 4000,
  :user => "admin",
  :password => "secret",
  :format => "xml"
})

Pathname.glob((ROOT + 'spec/fixtures/**/*.rb').to_s).each { |file| require file }

FakeWeb.allow_net_connect = false
