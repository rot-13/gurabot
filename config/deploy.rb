# config valid only for current version of Capistrano
lock "3.5.0"

set :application, "gurabot"
set :repo_url, "git@github.com:rot-13/gurabot.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/pi/gurabot"


set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, File.read(".ruby-version").strip


set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value
