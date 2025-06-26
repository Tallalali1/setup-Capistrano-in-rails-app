# setup-Capistrano-in-rails-app-with-rbenv-and-passenger

## Step 1: Add required gems

Add the following gems to your `Gemfile`:

```ruby
gem 'passenger'
gem 'capistrano', '~> 3.11'
gem 'capistrano-rails', '~> 1.4'
gem 'capistrano-passenger', '~> 0.2.0'
gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.4'
```

Then run:

```sh
bundle install
```

## Step 2: Install Capistrano

Run the following command to generate Capistrano’s configuration files:

```sh
bundle exec cap install
```

This will create several files including a `Capfile` in your project root.  
You can use the following as a sample `Capfile`:

```ruby
require "capistrano/setup"
require "capistrano/deploy"
require 'capistrano/rails'
require 'capistrano/passenger'
require 'capistrano/rbenv'

set :rbenv_type, :user
set :rbenv_ruby, '3.1.2'

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
```

## Step 3: Configure Capistrano

Create a file at `config/deploy.rb` with the following content:

```ruby
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
```

## Step 4: Configure Production Deployment

Create a file at `config/deploy/production.rb` with the following content for AWS EC2 (pem file authentication):

```ruby
set :stage, :production
set :rails_env, :production
set :branch, "main"

set :ssh_options, {
  forward_agent: false,
  auth_methods: %w[publickey],
  user: 'ubuntu',
  keys: %w[./Desktop/pemfile_name.pem]
}

server 'your_server_ip', port: 22, roles: [:web, :app, :db]
```

Or, for password authentication (e.g., DigitalOcean):

```ruby
set :stage, :production
set :rails_env, :production
set :branch, "main"
set :ssh_options, {
  forward_agent: false,
  auth_methods: %w(password),
  password: 'password_here',
  user: 'deploy'
}
server 'your_server_ip', roles: [:web, :app, :db], primary: true
```

## Step 5: Deploy the App (server should be setup before running this command)

Before running the deployment command, you need to have your server ready for deployment.  
If you need help with setting up the server, use the guide:  
[https://github.com/Tallalali1/deploy-rails-app-with-capistrano-and-passenger](https://github.com/Tallalali1/deploy-rails-app-with-capistrano-and-passenger)

To deploy your application to the production server, run:

```sh
cap production deploy
```

This command will execute the deployment process using the configuration you set up in the previous steps.

## Step 6: Fix missing `database.yml` or `master.key` errors

If you deploy and encounter errors about missing `config/database.yml` or `config/master.key` (or `config/credentials/production.key`), you need to upload these files to your server.

First, SSH into your server. For AWS EC2, use:

```sh
ssh -i "yourpemfile.pem" ubuntu@ec2-1-10-11-1.compute-1.amazonaws.com
```

Or for other servers (like DigitalOcean):

```sh
ssh deploy@yourserverip
```

Once connected, manually upload or create the required files in the appropriate `shared/config` directory on your server.

For example, to add your `master.key` and `database.yml`:

```sh
cd yourapp/shared/config
sudo nano master.key
```

Paste your `master.key` content into the editor, save, and exit.  
Repeat the process for `database.yml`:

```sh
sudo nano database.yml
```

Paste your `database.yml` content, save, and exit.

Finally, run the deployment command again:

```sh
cap production deploy
```

Your app should now be deployed

## Optional: Enable Rails Logs Output to STDOUT

To make it easier to view Rails logs on your server, you can add the following to your `config/environments/production.rb`:

```ruby
config.log_formatter = ::Logger::Formatter.new


if ENV["RAILS_LOG_TO_STDOUT"].present?
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)
end
```

With this configuration, you can access your Rails logs by SSHing into your server, navigating to the log directory, and using the following commands:

```sh
cd yourappname/current/log
tail -f production.log         # For real-time logs
tail -n 200 production.log     # For the last 200
```
