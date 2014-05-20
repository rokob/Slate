#!/usr/bin/env ruby
require 'fileutils'

secret_file = "Slate/Resources/Other-Sources/slate-config-secret.plist"
public_file = "Slate/Resources/Other-Sources/slate-config.plist"
temp_file = "Slate/Resources/Other-Sources/slate-config.plist.temp"

if File.exist?(temp_file)
  FileUtils.mv public_file, secret_file
  FileUtils.mv temp_file, public_file
end
