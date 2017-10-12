#!/usr/bin/env ruby
require './common.rb'

local_copy do |local_path|
  LOG.info "Stripping Commercials"
  comskip_command = "#{PLEX_COMSKIP_PATH} #{Shellwords::shellescape local_path}"
  subout comskip_command, 'COMSKIP'

  LOG.info "Copying processed file to source directory"
  output = File.join(input_dirname, "#{File.basename(local_path)}.comskip")
  LOG.info "Copying \"#{local_path}\" to \"#{output}\""
  copy_command = "cp #{Shellwords::shellescape local_path} #{Shellwords::shellescape output}"
  subout copy_command, 'COPY'

  LOG.info "Copying the processed file over the original"
  move_command = "mv #{Shellwords::shellescape output} #{Shellwords::shellescape input}"
  if TEST_MODE
    LOG.info "Skipping the move command because of TEST_MODE. Would have been:\n#{move_command}"
  else
    subout move_command, 'MOVE'
  end
end

# Detect if the script was run as a Plex POSTPROCESSING script or manually. If run manually, notify the Plex Media Server of the change.
unless (ENV['XPC_SERVICE_NAME'] || '').include?('plex')
  LOG.info "Telling Plex to rescan \"#{input_dirname}\""
  plex_media_scan_command = "#{PLEX_MEDIA_SCAN_PATH} --directory #{Shellwords::shellescape input_dirname}"
  subout plex_media_scan_command, 'PLEX MEDIA SCAN'
end

LOG.info "Done!"