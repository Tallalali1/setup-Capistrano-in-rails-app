# if you have a pem file for SSH authentication like in aws ec2 server,
# you can use the following configuration:
set :stage, :production
set :rails_env, :production
set :branch, "main"

set :ssh_options, {
  forward_agent: false,
  auth_methods: %w[publickey],
  user: 'ubuntu',
  keys: %w[./Desktop/pemfile_name.pem]
}

server 'your_server_ip', port: 22, roles: [:web, :app, :db],

# or if you want to use password authentication like in digitalocean,
# you can use the following configuration:

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
