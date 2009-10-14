#!/usr/bin/env ruby
require "fileutils"
require 'rubygems'
gem 'rspec'
gem 'rspec-rails'

Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

PLUGIN_ROOT = File.expand_path(File.dirname(__FILE__))
# Allows loading of an environment config based on the environment
REDMINE_ROOT = ENV["REDMINE_ROOT"] || File.dirname(__FILE__) + "/../../.."
REDMINE_APP = File.expand_path(REDMINE_ROOT + '/app')
REDMINE_LIB = File.expand_path(REDMINE_ROOT + '/lib')

require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'spec/rake/spectask'

PROJECT_NAME = 'billing_plugin'
REDMINE_PROJECT_NAME = 'redmine-billing'
CLEAN.include('**/semantic.cache', "**/#{PROJECT_NAME}.zip", "**/#{PROJECT_NAME}.tar.gz")

# No Database needed
spec_prereq = :noop
task :noop do
end

task :default => :spec
task :stats => "spec:statsetup"

desc "Run all specs in spec directory (excluding plugin specs)"
Spec::Rake::SpecTask.new(:spec => spec_prereq) do |t|
  t.spec_opts = ['--options', "\"#{PLUGIN_ROOT}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs in spec directory with RCov (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{PLUGIN_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts << ["--rails", "--sort=coverage", "--exclude '/var/lib/gems,spec,#{REDMINE_APP},#{REDMINE_LIB}'"]
  end
  
  desc "Print Specdoc for all specs (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  desc "Print Specdoc for all specs as HTML (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:htmldoc) do |t|
    t.spec_opts = ["--format", "html:doc/rspec_report.html", "--loadby", "mtime"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  [:models, :controllers, :views, :helpers, :lib].each do |sub|
    desc "Run the specs under spec/#{sub}"
    Spec::Rake::SpecTask.new(sub => spec_prereq) do |t|
      t.spec_opts = ['--options', "\"#{PLUGIN_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
    end
  end
end

desc 'Generate documentation for the Budget plugin.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = PROJECT_NAME
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end


namespace :release do
  desc "Create a zip archive"
  task :zip => [:clean] do
    sh "git archive --format=zip --prefix=#{PROJECT_NAME}/ HEAD > #{PROJECT_NAME}.zip"
  end

  desc "Create a tarball archive"
  task :tarball => [:clean] do
    sh "git archive --format=tar --prefix=#{PROJECT_NAME}/ HEAD | gzip > #{PROJECT_NAME}.tar.gz"
  end

  desc 'Uploads project documentation'
  task :upload_doc => ['spec:rcov', :doc, 'spec:htmldoc'] do |t|
    # TODO: Get rdoc working without frames
    `scp -r doc/ dev.littlestreamsoftware.com:/home/websites/projects.littlestreamsoftware.com/shared/embedded_docs/#{REDMINE_PROJECT_NAME}/doc`
    `scp -r coverage/ dev.littlestreamsoftware.com:/home/websites/projects.littlestreamsoftware.com/shared/embedded_docs/#{REDMINE_PROJECT_NAME}/coverage`
  end
end
begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "redmine_billing"
    s.summary = "This is a plugin for Redmine"
    s.email = "edavis@littlestreamsoftware.com"
    s.homepage = "https://projects.littlestreamsoftware.com/projects/TODO"
    s.description = "This is a plugin for Redmine"
    s.authors = ["Eric Davis"]
    s.rubyforge_project = "redmine_billing" # TODO
    s.files =  FileList[
                        "[A-Z]*",
                        "init.rb",
                        "rails/init.rb",
                        "{bin,generators,lib,test,app,assets,config,lang}/**/*",
                        'lib/jeweler/templates/.gitignore'
                       ]
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

