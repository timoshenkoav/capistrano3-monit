namespace :monit do

  desc 'Monit status'
  task :status do
    on roles :app do
      puts capture :sudo, :monit, :status
    end
  end

  desc 'Start all processes'
  task :start do
    all_processes_do :start
  end

  desc 'Stop all processes'
  task :stop do
    all_processes_do :stop
  end

  desc 'Restart all processes'
  task :restart do
    all_processes_do :restart
  end

  def monit_do(*args)
    on roles :app do
      execute :sudo, :monit, *args
    end
  end

  def all_processes_do(cmd)
    on roles :app do
      output = capture :sudo, :monit, :status
      filter = fetch(:monit_services)
      processes = output.lines.grep(/^Process '/)
      puts filter
      processes.each do |process|
        process_name = process.split(/\s+/).last.delete "'"      
        monit_do cmd, process_name if filter.include?(process_name)
      end
    end
  end
end
