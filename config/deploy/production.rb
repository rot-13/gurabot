# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}
server "roomba.local", :user => "pi", :roles => %{web app}, ssh_options: { password: 'raspberry' }
set :branch, "master"
set :ssh_options, { :forward_agent => true }

after :deploy, :restart_server

task :restart_server do
	on release_roles :all do
		within "#{current_path}" do
			execute("fuser -k 4567/tcp")
			execute("bundle exec ruby ./index.rb")
		end
	end
end
