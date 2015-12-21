module ZK_Setup
  def self.start_zk(port=21811)
    @port = port
    if SPAWN_ZK
      kill_old_zk_servers
      # remove_zk_data
      server = ZK::Server.new do |config|
        config.client_port = port
        config.client_port_address = 'localhost'
        config.force_sync = false
        config.tick_time = 2000
        config.init_limit = 10
        config.sync_limit = 5
        config.snap_count = 1000000
        config.base_dir = zk_dir
      end
      server.run
      @zk_server = server
      times = 5
      puts zk_ok?
      while !zk_ok? || times > 0
        sleep(1)
        times =- 1
      end
      puts zk_ok?
      ENV['ZK_URL'] = "localhost:#{port}"
    end
  end

  def self.stop_zk
    if SPAWN_ZK
      @zk_server.shutdown
      # remove_zk_data
    end
  end

  def self.zk_dir
    File.join CELLECT_ROOT, 'tmp/zookeeper'
  end

  def self.zk_ok?
    `echo ruok | nc 127.0.0.1 #{@port}`.chomp == 'imok'
  end

  def self.kill_old_zk_servers
    if zk_ok?
      pid = `ps aux | grep -e 'Cellect[\/]tmp[\/]zookeeper'`.split[1]
      puts "Killing rogue zookeeper process: #{ pid }..."
      `kill -s TERM #{ pid }`
      sleep 1
    end
  end

  def self.remove_zk_data
    `rm -rf #{ zk_dir }; mkdir -p #{ zk_dir }`
  end
end
