# config valid for current version and patch releases of Capistrano
lock "~> 3.18.0"

set :application, "dosandbox"
set :repo_url, "git@github.com:bnwpro/dosandbox.git"
set :user, "deploy"
set :puma_user, fetch(:user)
set :puma_threads, [4, 16]
set :puma_workers, 0

# Default branch is :main
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
#set :branch, :main
set :use_sudo, false
set :systemctl_user, :system
# Default deploy_to directory is /var/www/my_app_name
set :pty, true

set :stage, :production
#set :deploy_via, :remote_cache
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
#set :puma_role, :app
set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log, "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true
#set :puma_enable_socket_service, true
set :sidekiq_roles, :worker
set :sidekiq_default_hooks, true
set :sidekiq_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
set :sidekiq_config_files, ['sidekiq.yml']

# Default value for :format is :airbrussh.
set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
#append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", ".bundle", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 2

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
namespace :sidekiq do
	desc "Quieting sidekiq"
	task :quiet_sidekiq do
		on roles(:worker) do
			execute :service, "sidekiq quiet"
		end
	end

	desc "Toggle sidekiq service"
	task :restart_sidekiq do
		on roles(:worker) do
			execute :service, "sidekiq restart"
		end
	end
end

desc "Check that we can access everything"
task :write_permissions do
  on roles(:all) do |host|
    if test("[ -w #{fetch(:deploy_to)} ]")
      info "#{fetch(:deploy_to)} is writable on #{host}"
    else
      error "#{fetch(:deploy_to)} is not writable on #{host}"
    end
  end
end

namespace :puma do
	desc "Create Directories for Puma pids and Socket"
	task :make_dirs do
		on roles(:app) do
			execute "mkdir #{shared_path}/tmp/sockets -p"
			execute "mkdir #{shared_path}/tmp/pids -p"
		end
	end
	before :start, :make_dirs
end

namespace :deploy do
	desc "Make sure local git is in sync with remote"
	task :check_revision do
		on roles(:app) do
			unless `git rev-parse HEAD` == `git rev-parse origin/main`
				puts "WARNING: HEAD is not the ame as origin/main"
				puts "Run `git push` to sync changes"
				exit
			end
		end
	end

	desc "Initial deploy"
	task :initial do
		on roles(:app) do
			before 'deploy:restart', 'puma:start'
			invoke 'deploy'
		end
	end

	desc "Restart Application"
	task :restart do
		on roles(:app), in: :sequence, wait: 5 do
			invoke 'puma:restart'
		end
	end

	#before :starting, :check_revision
	after "deploy:starting", "quiet_sidekiq"
	after "deploy:reverted", "restart_sidekiq"
	after :finishing, :compile_assets
	after :finishing, :cleanup
	after "deploy:published", "restart_sidekiq"
	#after :finishing, :restart
end

