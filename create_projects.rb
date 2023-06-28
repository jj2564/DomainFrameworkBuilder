require 'xcodeproj'

def create_project(base_name, suffix)
    
    name = "#{base_name}.#{suffix}"
    
    project = Xcodeproj::Project.new("#{name}/#{name}.xcodeproj")
    target = project.new_target(:framework, name, :ios, '13.0')
    
    configurations = project.build_configurations
    
    debug_config = configurations.find { |config| config.name == 'Debug' }
    release_config = configurations.find { |config| config.name == 'Release' }
    
    
    # Remove the existing configurations
    project.build_configurations.clear
    
    if debug_config
        dev_config = project.new(Xcodeproj::Project::XCBuildConfiguration)
        dev_config.name = 'DEV'
        dev_config.build_settings = dev_config.build_settings.dup
        project.build_configurations << dev_config
        
        stage_config = project.new(Xcodeproj::Project::XCBuildConfiguration)
        stage_config.name = 'STAGE'
        stage_config.build_settings = dev_config.build_settings.dup
        project.build_configurations << stage_config
    else
        puts "Warning: 'Debug' config does not exist, unable to create 'STAGE' config."
    end
    
    if release_config
        prod_config = project.new(Xcodeproj::Project::XCBuildConfiguration)
        prod_config.name = 'PROD'
        prod_config.build_settings = release_config.build_settings.dup
        project.build_configurations << prod_config
    else
        puts "Warning: 'Release' config does not exist, unable to create 'STAGE' config."
    end
    
    #    Set 'IPHONEOS_DEPLOYMENT_TARGET' and 'TARGETED_DEVICE_FAMILY' for each configuration target
    project.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'  # '1' is for iPhone, '2' is for iPad
        config.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos ipados'
    end
    
    project.targets.each do |target|
        target.frameworks_build_phase.clear
    end
    
    project.save
    
end

# Add framework dependencies
#def add_framework_dependencies(base_name, suffix)
#
#    name = "#{base_name}.#{suffix}"
#
#    hosting_path = "#{name}/#{name}.xcodeproj"
#
#    hosting_project = Xcodeproj::Project.open(hosting_path)
#    hosting_target = hosting_project.targets.find { |target| target.name == suffix }
#
#    ['Core', 'Accesses'].each do |apply_name|
#        framework_name = "#{base_name}.#{apply_name}"
#        framework_project_path = "#{framework_name}/#{framework_name}.xcodeproj"
#        framework_project = Xcodeproj::Project.open(framework_project_path)
#        framework_target = framework_project.targets.find { |target| target.name == apply_name }
#        framework_product_path = "#{framework_name}/Build/Products/Release-iphoneos/#{framework_name}.framework"
#        puts framework_product_path
#        hosting_target.add_framework(framework_product_path)
#    end
#
#    hosting_project.save
#end


# check base name
if ARGV.empty?
    puts "Please provide a base name."
else
    base_name = ARGV[0]
    ["Core", "Hosting", "Accesses"].each do |suffix|
        create_project(base_name, suffix)
    end

#    add_framework_dependencies(base_name, 'Hosting')
end

