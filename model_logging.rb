module ModelLogging

  def rresource
    self.name
  end

  def rname
    self.name + '_' + self.id
  end

  def rlog
    self.name[0..3]
  end

  def log_pack
   [rresource, rname, rlog]
  end

  def resourcelog
    Log4r::Logger[ log_pack[0] +'_logging::'+ log_pack[1] ]
  end

  def resource_log_path
    log_pack[0].to_s + "/" + log_pack[1].to_s
  end 

  def resource_log_file_path
    #(Rails.root.join("..", "logs/")).to_s + self.resource_log_path + "/" + log_pack[2] +".log"
  end

  def setup_resource_log
    #FileUtils.mkdir_p(Rails.root.join("..","logs/", resource_log_path))
    #File.open(Rails.root.join(self.resource_log_file_path), 'a+') { |f| f.write("**#{log_pack} log created #{Time.now}") }
  end

  def resource_logger(lvl,msg)
    if self.resourcelog
      self.resourcelog.send(lvl.to_sym, msg)
    else
      Log4r::Logger.new(log_pack[0] +'_logging::'+ log_pack[1])
      FileOutputter.new(log_pack[1]+'f', :filename=>resource_log_file_path, :trunc => false)
      Log4r::Logger[(log_pack[0] +'_logging::'+ log_pack[1])].add log_pack[1]+'f'
      Log4r::Logger[(log_pack[0] +'_logging::'+ log_pack[1])].send(lvl.to_sym, msg)
    end
  end
  
  def read_resource_log
    f = File.open(self.resource_log_file_path, 'r')
    result = f.read
    result
  end

end
