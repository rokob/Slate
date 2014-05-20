#!/usr/bin/env ruby
require 'fileutils'

secret_file = "Slate/Resources/Other-Sources/slate-config-secret.plist"
public_file = "Slate/Resources/Other-Sources/slate-config.plist"
temp_file = "Slate/Resources/Other-Sources/slate-config.plist.temp"

if File.exist?(secret_file)
  FileUtils.mv public_file, temp_file, force: true, verbose: true
  FileUtils.mv secret_file, public_file, force: true, verbose: true
end
