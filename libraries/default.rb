# OsConfiguration module
module OsConfiguration
  def self.change_config_file(name, separator, field, value)
    a = [ '*', '?', '|', '(', ')', '[', ']', '{', '}', '$', '+']
    tempfile = Chef::Util::FileEdit.new(name)
    line = field + separator + value
    a.each {|special| field = field.gsub(special, '\\' + special)}
    unless tempfile.search_file_replace_line(/^#{field}/, line)
      tempfile.insert_line_if_no_match(/^#{field}/, line)
    end
    tempfile.write_file
    if FileUtils.cmp(name, name + '.old')
      FileUtils.mv name + '.old', name, force: true
    end
  end

  def self.save_config_file(name)
    time = Time.new
    date = time.year.to_s.rjust(2, '0')
    date += time.month.to_s.rjust(2, '0')
    date += time.day.to_s.rjust(2, '0')
    date += '_'
    date += time.hour.to_s.rjust(2, '0')
    date += time.min.to_s.rjust(2, '0')
    cmd = "cp -p #{name} #{name}.#{date}"
    Mixlib::ShellOut.new(cmd).run_command unless File.exist?(name + '.' + date)
  end
end
