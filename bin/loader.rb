if ARGV.size != 1
  puts "usage: #{File.basename($PROGRAM_NAME)} [anki_collection_path]"
  exit 1
end

require 'rubygems'
require 'bundler/setup'
Bundler.require :default
require 'require_all'
