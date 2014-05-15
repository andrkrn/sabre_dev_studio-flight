require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*test.rb']
  t.verbose = true
end

desc 'Run tests'
task :default => :test

RDoc::Task.new do |rdoc|
  rdoc.main     = 'README.md'
  rdoc.title    = 'Sabre Dev Studio Flight Shop Gem'
  rdoc.options << '--line-numbers --inline-source'
  rdoc.rdoc_dir = 'doc'
  rdoc.rdoc_files.include('README.md', 'lib/*.rb', 'lib/**')
end
