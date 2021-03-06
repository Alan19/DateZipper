require 'rubygems'
require 'zip'
require 'date'
require 'fileutils'

# This is a simple example which uses rubyzip to
# recursively generate a zip file from the contents of
# a specified directory. The directory itself is not
# included in the archive, rather just its contents.
#
# Usage:
#   directory_to_zip = "/tmp/input"
#   output_file = "/tmp/out.zip"
#   zf = ZipFileGenerator.new(directory_to_zip, output_file)
#   zf.write()

class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  # Zip the input directory.
  def write
    entries = Dir.entries(@input_dir) - %w(. ..)

    ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
      write_entries entries, '', zipfile
    end
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, zipfile)
    entries.each do |e|
      zipfile_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zipfile_path)
      puts "Deflating #{disk_file_path}"

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
    zipfile.mkdir zipfile_path
    subdir = Dir.entries(disk_file_path) - %w(. ..)
    write_entries subdir, zipfile_path, zipfile
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.get_output_stream(zipfile_path) do |f|
      f.write(File.open(disk_file_path, 'rb').read)
    end
  end
end

# Default list of folders to copy
folders_to_copy = %w(/config /structures /scripts /resources)

# Additional folders to copy
ARGV.each {|arg|
  folders_to_copy.push("/#{arg}")
  puts("Adding #{arg}")
}

minecraft_directory = File.expand_path("..")
temp_folder_name = 'foo'
current_directory = Dir.pwd

folders_to_copy.each { |f|
  #Delete original folders if present
  directory_to_zip = minecraft_directory + f
  output_file = "#{directory_to_zip}#{Date.today.strftime("%Y%m%d")}.zip"
  if File.exist?(output_file)
    FileUtils.rm_rf(temp_folder_name)
    FileUtils.rm(output_file)
    puts "Removed #{temp_folder_name} and #{output_file}"
  end

  #Create exterior folder and copy config folder into that folder
  FileUtils::mkdir_p temp_folder_name
  puts("Created #{temp_folder_name}")
  FileUtils.cp_r(directory_to_zip, temp_folder_name)

  #Zip configs
  puts "Zipping #{minecraft_directory + temp_folder_name} to #{output_file}"
  zf = ZipFileGenerator.new("#{current_directory}/#{temp_folder_name}", output_file)
  zf.write
  FileUtils.rm_rf(temp_folder_name)

  puts("Zipping successful, created #{output_file}")
}





