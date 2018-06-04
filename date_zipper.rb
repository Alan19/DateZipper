require 'rubygems'
require 'zip'

class DateZipper
  folder = "config"
  zipfile_name = "config" + Date.today.strftime("%Y%m%d")

  Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
    zipfile.add(folder, File.join)
  end
end