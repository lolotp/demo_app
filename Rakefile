#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'bundler/setup'
Bundler.require(:default)

require 'resque/tasks'
require 'resque_scheduler/tasks'

DemoApp::Application.load_tasks

task "resque:setup" do
  ENV['QUEUE'] = '*'
  Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
