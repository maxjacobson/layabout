worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout 15
preload_app true

# first argument is the server
# second argument is the worker
# I don't know what that means though
before_fork do |_, _|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

# server, worker
# again
after_fork do |_, _|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing.' \
      'Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end

