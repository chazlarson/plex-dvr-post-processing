# Plex DVR Post Processing

A script intended to be used with Plex's DVR. Script copies raw DVR'd shows to a temp directory, strips commercials, transcodes, and then replaces original DVR'd show in original location.

## Install

Install Handbrake CLI
`brew install handbrake`

Install PlexComskip from https://github.com/ekim1337/PlexComskip.

## Usage

In Plex Settings > Live TV & DVR set POSTPROCESSING SCRIPT to:
`/Users/john/development/plex-dvr-post-processing/process.rb`
