# -*- encoding : utf-8 -*-
# encode: UTF-8
# name of application
require "rubygems"
gem "activesupport"
require "active_support/core_ext"
$application_name = "lottery_game"

set :application, $application_name
$files_and_dirs = %w( app config Gemfile public lib Rakefile db script spec vendor Capfile config.ru )

#for ssh
set :scm , :none

role :code_tmp_server, "119.254.88.71:10130" ,
     :ssh_options => { :username => "root" }

role :formal_server, "119.254.88.71:10130" ,
     :ssh_options => { :username => "root" }

$code_tmp_code_path = "/opt/projects/#{$application_name}_code_tmp_codes/copy_#{Time.current.strftime("%Y%m%d%s")}"
$code_tmp_app_lns = "/opt/projects/#{$application_name}_code_tmp"


$formal_code_path = "/opt/projects/#{$application_name}_codes/copy_#{Time.current.strftime("%Y%m%d%s")}"
$formal_app_tmp_path = "/opt/projects/#{$application_name}_tmp"
$formal_app_log_path = "/opt/projects/#{$application_name}_log"
$formal_app_lns = "/opt/projects/#{$application_name}"
$formal_bundle = "/opt/ree/bin/bundle"
$formal_rake = "/opt/ree/bin/rake"

namespace :deploy do
  
  task :code_tmp_server ,:roles => :code_tmp_server  do
    run "mkdir -p #{$code_tmp_code_path}"
    $files_and_dirs.each do|fd|
      top.upload fd , "#{$code_tmp_code_path}/#{fd}" , :mode => "a+" if File.directory? fd or File.exists? fd
    end
    run "ln -nfs #{$code_tmp_code_path} #{$code_tmp_app_lns}"
  end
  

  task :formal_server ,:roles => :formal_server  do
    upload_file_and_init($formal_code_path, $formal_app_log_path, $formal_app_tmp_path, $formal_app_lns, $formal_bundle, $formal_rake, "production")
  end
  
  def self.upload_file_and_init(code_path, log_path, tmp_path, lns_path , bundle_path, rake_path, type)
    run "mkdir -p #{tmp_path}" unless File.directory?(tmp_path)
    run "mkdir -p #{log_path}" unless File.directory?(log_path)
    run "mkdir -p #{code_path}"
    $files_and_dirs.each do|fd|
      top.upload fd , "#{code_path}/#{fd}" , :mode => "a+" if File.directory?( fd ) or File.exist?( fd )
    end
    run "ln -nfs #{code_path} #{lns_path}"
    run "ln -nfs #{log_path}  #{lns_path}/log"
    run "ln -nfs #{tmp_path}  #{lns_path}/tmp"
    run "cd #{lns_path} && #{bundle_path} --without test" if ENV["need_bundle"]
    run "chmod -R 777 #{code_path}"
    run "cd #{lns_path} && #{bundle_path} exec #{rake_path} db:create RAILS_ENV=#{type}" if ENV["need_create_db"]
    if ENV["need_migration"]
      run "cd #{lns_path} && #{bundle_path} exec #{rake_path} db:migrate RAILS_ENV=#{type}"
      run "cd #{lns_path} && #{bundle_path} exec #{rake_path} db:seed RAILS_ENV=#{type}"
    end
    run "cd #{lns_path} && #{bundle_path} exec #{rake_path} assets:clean RAILS_ENV=#{type}"
    run "cd #{lns_path} && #{bundle_path} exec #{rake_path} assets:precompile RAILS_ENV=#{type}"
    run "cd #{lns_path} && touch tmp/restart.txt"
  end
end

