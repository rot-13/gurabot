server "roomba.local", :user => "pi", :roles => %{web app}, ssh_options: { password: "raspberry" }
set :branch, "master"
set :ssh_options, { :forward_agent => true }

after :deploy, :restart_server

task :restart_server do
	on release_roles :all do
		within "#{current_path}" do
			execute("fuser -k 4567/tcp", raise_on_non_zero_exit: false)
			execute(:bundle, :exec, :ruby, "./index.rb")
		end
	end
end
