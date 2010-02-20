require "fileutils"

installed_files = "InstalledFiles"

if not File.exist? installed_files
  STDERR.puts "'InstalledFiles' not found."
  exit 1
end

open( installed_files ){|f|
  while path = f.gets
    path.chomp!

    if File.exist? path
      FileUtils.rm path
    end
  end
}

FileUtils.mv installed_files, installed_files + ".old"
