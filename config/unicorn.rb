# unicorn_rails -c config/unicorn.rb -E production -D

user = "www"
app = "17up"
app_path = "/home/#{user}/#{app}/current"

worker_processes 2
working_directory app_path
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

listen "#{app_path}/tmp/sockets/unicorn.sock", :backlog => 2048
listen 8081, :tcp_nopush => true
pid "#{app_path}/tmp/pids/unicorn.pid"
##
# REE
stderr_path "#{app_path}/log/unicorn.stderr.log"
stdout_path "#{app_path}/log/unicorn.stdout.log"
# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

#unicorn cannot restart properly somtimes;
#see here: http://blog.willj.net/2011/08/02/fixing-the-gemfile-not-found-bundlergemfilenotfound-error/
before_exec do |server|
 ENV['BUNDLE_GEMFILE'] = "#{app_path}/Gemfile"
end

before_fork do |server, worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.
  #  defined?(ActiveRecord::Base) and
  #  ActiveRecord::Base.connection.disconnect!

  old_pid = app_path + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end


#after_fork do |server, worker|
#    defined?(ActiveRecord::Base) and
#    ActiveRecord::Base.establish_connection
#end
