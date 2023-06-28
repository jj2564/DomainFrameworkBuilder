require 'xcodeproj'

def clear_configuration(base_name, suffix)
    
    name = "#{base_name}.#{suffix}"
    
    project = Xcodeproj::Project.open("#{name}/#{name}.xcodeproj")
    
    configurations = project.build_configurations
    
    debug_config = configurations.find { |config| config.name == 'Debug' }
    release_config = configurations.find { |config| config.name == 'Release' }
    
    if debug_config
        project.build_configurations.delete(debug_config)
    end
    
    if release_config
        project.build_configurations.delete(release_config)
    end
    
    project.save
    
    project.build_configurations.each do |config|
        puts config.name
    end
    
end

# check base name
if ARGV.empty?
  puts "Please provide a base name."
else
  base_name = ARGV[0]
  ["Core", "Hosting", "Accesses"].each do |suffix|
      clear_configuration(base_name, suffix)
  end
end
