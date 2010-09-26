require 'rubygems'
require 'active_record'
ActiveRecord::ActiveRecordError # hack for https://rails.lighthouseapp.com/projects/8994/tickets/2577-when-using-activerecordassociations-outside-of-rails-a-nameerror-is-thrown

RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
RUBYDOCTEST = ENV['RUBYDOCTEST'] || "#{RUBY} -S rubydoctest"

$:.unshift File.expand_path('../../hobo_support/lib', __FILE__)
$:.unshift File.expand_path('../lib', __FILE__)
require 'hobo_support'
require 'hobo_fields'

GEM_ROOT = File.expand_path('../')
TESTAPP_PATH = '/tmp/hobo_fields_testapp'
BIN = File.expand_path('../bin/hobofields')
require 'hobo_support/common_tasks'
include HoboSupport::CommonTasks


namespace "test" do
  desc "Run the doctests"
  task :doctest do |t|
    files=Dir['test/*.rdoctest'].map {|f| File.expand_path(f)}.join(' ')
    exit(1) if !system("#{RUBYDOCTEST} #{files}")
  end

  desc "Run the unit tests"
  task :unit do |t|
    Dir["test/test_*.rb"].each do |f|
      exit(1) if !system("#{RUBY} #{f}")
    end
  end

end
