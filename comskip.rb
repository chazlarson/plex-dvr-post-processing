#!/usr/bin/env ruby
require './common.rb'

local_copy(input) do |local_path|
  LOG.info "Stripping Commercials"
  comskip_command = "#{PLEX_COMSKIP_PATH} #{Shellwords::shellescape local_path}"
  subout comskip_command, 'COMSKIP'

  LOG.info "Copying processed file to source directory"
  output = File.join(input_dirname, File.basename(local_path))
  LOG.info "Copying \"#{local_path}\" to \"#{output}\""
  copy_command = "cp #{Shellwords::shellescape local_path} #{Shellwords::shellescape output}"
  subout copy_command, 'COPY'

  LOG.info "Moving the processed file over the original"
  move_command = "mv #{Shellwords::shellescape output} #{Shellwords::shellescape input}"
  if TEST_MODE
    LOG.info "Skipping the move command because of TEST_MODE. Would have been:\n#{move_command}"
  else
    subout move_command, 'MOVE'
  end
end

#LOG.info "Transcoding"
#transcoded_tmp_path = "#{input_tmp_path}.#{HANDBRAKE_PRESET}.#{HANDBRAKE_OUTPUT_EXTENSION}"
#transcode_command = "#{HANDBRAKE_BIN} --preset \"#{HANDBRAKE_PRESET}\" -i #{Shellwords::shellescape input_tmp_path} -o #{Shellwords::shellescape transcoded_tmp_path}"
#transcode_command += " --stop-at duration:60" if TEST_MODE
#subout transcode_command, 'TRANSCODE'

# Detect if the script was run as a Plex POSTPROCESSING script or manually. If run manually, notify the Plex Media Server of the change.
unless (ENV['XPC_SERVICE_NAME'] || '').include?('plex')
  LOG.info "Telling Plex to rescan \"#{input_dirname}\""
  plex_media_scan_command = "#{PLEX_MEDIA_SCAN_PATH} --directory #{Shellwords::shellescape input_dirname}"
  subout plex_media_scan_command, 'PLEX MEDIA SCAN'
end

LOG.info "Done!"
