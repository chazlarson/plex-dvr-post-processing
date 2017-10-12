#!/usr/bin/env ruby
require 'logger'
require 'tmpdir'
require 'shellwords'
require './locker.rb'

PLEX_MEDIA_SCAN_PATH = "/Applications/Plex\ Media\ Server.app/Contents/MacOS/Plex\ Media\ Scanner"
PLEX_COMSKIP_PATH = "/Users/john/development/PlexComskip/PlexComskip.py"
HANDBRAKE_BIN = "/usr/local/bin/HandBrakeCLI"
HANDBRAKE_PRESET = "Apple 720p30 Surround"
HANDBRAKE_OUTPUT_EXTENSION = "m4v"
TEST_MODE = false

Process.setpriority(Process::PRIO_PROCESS, 0, 20)

input = ARGV[0]
input = File.expand_path(input)
input_basename = File.basename(input)
input_dirname = File.dirname(input)

LOG_ROOT = File.join(File.dirname(__FILE__), 'logs')
FileUtils.mkdir_p LOG_ROOT
LOG_PATH = File.join(LOG_ROOT, "#{input_basename}.log")
LOG = Logger.new(LOG_PATH)

LOG.warn "TEST MODE IS ON" if TEST_MODE

LOG.debug "ARGV:\n\t#{ARGV.join("\n\t")}"
LOG.debug "ENV:\n#{ENV.collect{|k,v| "\t#{k}: #{v}"}.join("\n")}"

def subout(command, tag = false)
  LOG.info command
  IO.popen("#{command} 2>&1").each do |line|
    LOG.debug "#{tag ? "[#{tag}] " : nil}#{line.strip}"
  end
end

LOG.info "Processing \"#{input}\""

tmp_dir = Dir.mktmpdir
LOG.info "Created Temporary Working Directory \"#{tmp_dir}\""

input_tmp_path = File.join(tmp_dir, input_basename)
LOG.info "Copying \"#{input}\" to #{input_tmp_path}"
copy_command = "cp #{Shellwords::shellescape input} #{Shellwords::shellescape input_tmp_path}"
subout copy_command, 'COPY'

lock do
  LOG.info "Stripping Commercials"
  comskip_command = "#{PLEX_COMSKIP_PATH} #{Shellwords::shellescape input_tmp_path}"
  subout comskip_command, 'COMSKIP'
  
  LOG.info "Transcoding"
  transcoded_tmp_path = "#{input_tmp_path}.#{HANDBRAKE_PRESET}.#{HANDBRAKE_OUTPUT_EXTENSION}"
  transcode_command = "#{HANDBRAKE_BIN} --preset \"#{HANDBRAKE_PRESET}\" -i #{Shellwords::shellescape input_tmp_path} -o #{Shellwords::shellescape transcoded_tmp_path}"
  transcode_command += " --stop-at duration:60" if TEST_MODE
  subout transcode_command, 'TRANSCODE'
end

LOG.info "Copying processed file to source directory"
output = File.join(input_dirname, File.basename(input_tmp_path))
LOG.info "Copying \"#{input_tmp_path}\" to \"#{output}\""
copy_command = "cp #{Shellwords::shellescape input_tmp_path} #{Shellwords::shellescape output}"
subout copy_command, 'COPY'

LOG.info "Moving the processed file over the original"
move_command = "mv #{Shellwords::shellescape output} #{Shellwords::shellescape input}"
if TEST_MODE
  LOG.info "Skipping the move command because of TEST_MODE. Would have been:\n#{move_command}"
else
  subout move_command, 'MOVE'
end

LOG.info "Deleting Temporary Working Directory \"#{tmp_dir}\""
FileUtils.rm_rf tmp_dir

# Detect if the script was run as a Plex POSTPROCESSING script or manually. If run manually, notify the Plex Media Server of the change.
unless (ENV['XPC_SERVICE_NAME'] || '').include?('plex')
  LOG.info "Telling Plex to rescan \"#{input_dirname}\""
  plex_media_scan_command = "#{PLEX_MEDIA_SCAN_PATH} --directory #{Shellwords::shellescape input_dirname}"
  subout plex_media_scan_command, 'PLEX MEDIA SCAN'
end

LOG.info "Done!"
