module Rohbau
  module Require
    module_function

    def require_all(*sub_dirs)
      called_by = caller_locations(1, 1).first
      file = called_by.absolute_path

      dir = File.basename(file, '.rb')

      sub_dirs.each do |sub_dir|
        dir = File.join(dir, sub_dir)
      end

      files = File.expand_path("../#{dir}/*.rb", file)
      Dir[files].each { |f| require f }
    end

  end
end
