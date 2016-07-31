server "roomba.local", :user => "pi", :roles => %{web app}, ssh_options: { password: "raspberry" }
set :branch, "master"
set :ssh_options, { :forward_agent => true }

before :deploy, :push_to_github
after :deploy, :restart_server

task :push_to_github do

	# Check for any local changes that haven't been committed
	# Use 'cap deploy:push IGNORE_DEPLOY_RB=1' to ignore changes to this file (for testing)
	status = %x(git status --porcelain).chomp
	if status != ""
		if status !~ %r{^[M ][M ] config/deploy.rb$}
			raise Capistrano::Error, "Local git repository has uncommitted changes"
		elsif !ENV["IGNORE_DEPLOY_RB"]
			# This is used for testing changes to this script without committing them first
			raise Capistrano::Error, "Local git repository has uncommitted changes (set IGNORE_DEPLOY_RB=1 to ignore changes to deploy.rb)"
		end
	end

	# Check we are on the master branch, so we can't forget to merge before deploying
	branch = %x(git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \\(.*\\)/\\1/').chomp
	if branch != "master" && !ENV["IGNORE_BRANCH"]
		raise Capistrano::Error, "Not on master branch (set IGNORE_BRANCH=1 to ignore)"
	end

	# Push the changes
	if ! system "git push #{fetch(:repository)} master"
		raise Capistrano::Error, "Failed to push changes to #{fetch(:repository)}"
	end

end

task :restart_server do
	on release_roles :all do
		within "#{current_path}" do
			execute("fuser -k 4567/tcp", raise_on_non_zero_exit: false)
			execute(:bundle, :exec, :ruby, "./index.rb")
		end
	end
end
