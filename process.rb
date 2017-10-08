#!/usr/bin/env ruby
require 'logger'
require 'tmpdir'
require 'shellwords'

PLEX_COMSKIP_PATH = "/Users/john/development/PlexComskip/PlexComskip.py"
HANDBRAKE_PRESET = "Apple 720p30 Surround"
HANDBRAKE_OUTPUT_EXTENSION = "m4v"
TEST_MODE = false

LOG_PATH = File.join(File.dirname(__FILE__), 'process.log')
LOG = Logger.new(LOG_PATH)

LOG.warn "TEST MODE IS ON" if TEST_MODE

input = ARGV[0]
input = File.expand_path(input)

def subout(command, tag = false)
  LOG.info command
  IO.popen("#{command} 2>&1").each do |line|
    LOG.debug "#{tag ? "[#{tag}] " : nil}#{line.strip}"
  end
end

LOG.info "Processing \"#{input}\""

tmp_dir = Dir.mktmpdir
LOG.info "Created Temporary Working Directory \"#{tmp_dir}\""

input_tmp_path = File.join(tmp_dir, File.basename(input))
LOG.info "Copying \"#{input}\" to #{input_tmp_path}"
copy_command = "cp #{Shellwords::shellescape input} #{Shellwords::shellescape input_tmp_path}"
subout copy_command, 'COPY'

LOG.info "Stripping Commercials"
comskip_command = "#{PLEX_COMSKIP_PATH} #{Shellwords::shellescape input_tmp_path}"
subout comskip_command, 'COMSKIP'

LOG.info "Transcoding"
transcoded_tmp_path = "#{input_tmp_path}.#{HANDBRAKE_PRESET}.#{HANDBRAKE_OUTPUT_EXTENSION}"
transcode_command = "HandBrakeCLI --preset \"#{HANDBRAKE_PRESET}\" -i #{Shellwords::shellescape input_tmp_path} -o #{Shellwords::shellescape transcoded_tmp_path}"
transcode_command += " --stop-at duration:60" if TEST_MODE
subout transcode_command, 'TRANSCODE'

LOG.info "Copying processed file to source directory"
output = File.join(File.dirname(input), File.basename(transcoded_tmp_path))
LOG.info "Copying \"#{transcoded_tmp_path}\" to \"#{output}\""
copy_command = "cp #{Shellwords::shellescape transcoded_tmp_path} #{Shellwords::shellescape output}"
subout copy_command, 'COPY'

LOG.info "Deleting Temporary Working Directory \"#{tmp_dir}\""
FileUtils.rm_rf tmp_dir
LOG.info "Done!"
