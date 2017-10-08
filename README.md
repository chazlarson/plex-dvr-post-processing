# Plex DVR Post Processing
A script intended to be used with Plex DVR. Script copies raw DVR'd shows to a temp directory, strips commercials, transcodes, puts processed version alongside original, and then deletes the original.

This script copies the original to a local temp directory because in my environment Plex records to a network mount (Drobo 5N). Tests confirmed that Comskip and Handbrake work much faster with local IO. If your storage is local the copy steps can be removed.

Script should be reviewed for your environment. I've written this for my environment (Mac OS, HD HomeRun Prime, Comskip, Handbrake, Plex, Drobo 5N) and while it should work with other setups it'll probably take some tinkering.

## Install

Install Handbrake CLI
`brew install handbrake`

Install PlexComskip from https://github.com/ekim1337/PlexComskip.

## Usage

In Plex Settings > Live TV & DVR set POSTPROCESSING SCRIPT to location of the process.rb script. Example:
`/Users/john/development/plex-dvr-post-processing/process.rb`
