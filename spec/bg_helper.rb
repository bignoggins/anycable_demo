# frozen_string_literal: true

hive_pid = nil

procfile = ENV['PROCFILE'] || 'Procfile.spec'

wait = Regexp.new(ENV['BG_WAIT'] || '.+')

puts "Starting background processes..."
rout, wout = IO.pipe
hive_pid = Process.spawn("hivemind #{procfile}", out: wout)

Timeout.timeout(10) do
  loop do
    output = rout.readline
    break if output =~ wait
  end
end

puts "Background processes have been started."

at_exit do
  puts "Stopping background processes..."
  Process.kill 'INT', hive_pid
  Process.wait hive_pid
  puts "Background processes have been stopped."
end
