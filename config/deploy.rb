# config valid for current version and patch releases of Capistrano
lock "~> 3.17.0"

set :application, "YourAppName"
set :repo_url,        'git@github.com:YourUsername/YourRepo.git'
set :user,            'ubuntu'
set :puma_threads,    [4, 16]
set :puma_workers,    0
set :branch,          'main'
set :passenger_restart_with_touch, true
# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/#{fetch(:application)}"
set :puma_bind,       "unix:///home/#{fetch(:user)}/#{fetch(:application)}/shared/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "/home/#{fetch(:user)}/#{fetch(:application)}/shared/tmp/pids/puma.state"
set :puma_pid,        "/home/#{fetch(:user)}/#{fetch(:application)}/shared/tmp/pids/puma.pid"
set :puma_access_log, "/home/#{fetch(:user)}/#{fetch(:application)}/shared/log/puma.error.log"
set :puma_error_log,  "/home/#{fetch(:user)}/#{fetch(:application)}/shared/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to true if using ActiveRecord
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets')
# Add any additional directories you want to link
append :linked_files, "config/credentials/production.key"
# or
# append :linked_files, "config/master.key"
append :linked_files, "config/database.yml"