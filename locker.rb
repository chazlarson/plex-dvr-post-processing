PID_FILE = File.join(File.dirname(__FILE__), 'current.pid')

def lock
  LOG.info "Waiting for lock on #{PID_FILE}"
  File.open(PID_FILE, File::RDWR|File::CREAT, 0644) do |file|
    begin
      file.flock File::LOCK_EX
      LOG.info "Lock established on #{PID_FILE}"
      file.rewind
      file.write "#{Process.pid}\n"
      file.flush
      file.truncate file.pos
      yield
    ensure
      file.truncate 0
      LOG.info "Releasing lock on #{PID_FILE}"
    end
  end
end
