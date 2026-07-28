require 'xcodeproj'

project_path = 'LightMD.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
source_build_phase = target.source_build_phase

# The files we need to ensure are in the build phase
files_to_add = [
  'ThemeBackgroundView.swift',
  'SceneTheme.swift',
  'SceneTheme+Factory.swift'
]

files_to_add.each do |filename|
  # Find the file reference by name in the entire project
  file_ref = project.files.find { |f| f.path == filename || f.name == filename }
  if file_ref
    # Check if it's already in the source build phase
    unless source_build_phase.files.any? { |bf| bf.file_ref == file_ref }
      puts "Adding #{filename} to compile sources..."
      source_build_phase.add_file_reference(file_ref)
    else
      puts "#{filename} is already in compile sources."
    end
  else
    puts "Warning: Could not find file reference for #{filename}"
  end
end

project.save
puts 'Done!'
