server "roomba.local", :user => "pi", :roles => %{web app}, ssh_options: { password: "raspberry" }
set :branch, "master"
set :ssh_options, { :forward_agent => true }

after :deploy, :restart_server

task :restart_server do
	on release_roles :all do
		execute("fuser -k 4567/tcp", raise_on_non_zero_exit: false)
		run("cd ~/gurabot/current; nohup bundle exec ruby /index.rb >/dev/null 2>&1 &", pty: false)
	end
end
