require 'logger'
require 'tmpdir'
require 'shellwords'

PLEX_MEDIA_SCAN_PATH = "/Applications/Plex\ Media\ Server.app/Contents/MacOS/Plex\ Media\ Scanner"
PLEX_COMSKIP_PATH = "/Users/john/development/PlexComskip/PlexComskip.py"
HANDBRAKE_BIN = "/usr/local/bin/HandBrakeCLI"
HANDBRAKE_PRESET = "Apple 720p30 Surround"
HANDBRAKE_OUTPUT_EXTENSION = "m4v"
TEST_MODE = true
LOG_ROOT = File.join(File.dirname(__FILE__), 'logs')
FileUtils.mkdir_p LOG_ROOT
LOG_PATH = File.join(LOG_ROOT, "#{input_basename}.log")
LOG = Logger.new(LOG_PATH)

LOG.warn "TEST MODE IS ON" if TEST_MODE

LOG.debug "ARGV:\n\t#{ARGV.join("\n\t")}"
LOG.debug "ENV:\n#{ENV.collect{|k,v| "\t#{k}: #{v}"}.join("\n")}"

Process.setpriority(Process::PRIO_PROCESS, 0, 20)

def input
  File.expand_path ARGV[0]
end

def input_basename
  File.basename(input)
end

def input_dirname
  File.dirname(input)
end

def subout(command, tag = false)
  LOG.info command
  IO.popen("#{command} 2>&1").each do |line|
    LOG.debug "#{tag ? "[#{tag}] " : nil}#{line.strip}"
  end
end

def local_copy(input)
  tmp_dir = Dir.mktmpdir
  LOG.info "Created Temporary Working Directory \"#{tmp_dir}\""
  input_tmp_path = File.join(tmp_dir, input)
  begin
    LOG.info "Copying \"#{input}\" to #{input_tmp_path}"
    copy_command = "cp #{Shellwords::shellescape input} #{Shellwords::shellescape input_tmp_path}"
    subout copy_command, 'COPY'
    yield input_tmp_path
  ensure
    LOG.info "Deleting Temporary Working Directory \"#{tmp_dir}\""
    FileUtils.rm_rf tmp_dir
  end
end
