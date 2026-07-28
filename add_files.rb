require 'xcodeproj'

project_path = 'LightMD.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Add Views/ThemeBackgroundView.swift
views_group = project.main_group.find_subpath(File.join('LightMD', 'Views'), true)
unless views_group.files.any? { |f| f.path == 'ThemeBackgroundView.swift' }
  file_ref = views_group.new_file('ThemeBackgroundView.swift')
  target.add_file_references([file_ref])
end

# Add Models/SceneTheme.swift
models_group = project.main_group.find_subpath(File.join('LightMD', 'Models'), true)
unless models_group.files.any? { |f| f.path == 'SceneTheme.swift' }
  file_ref = models_group.new_file('SceneTheme.swift')
  target.add_file_references([file_ref])
end

# Add Design/SceneTheme+Factory.swift
design_group = project.main_group.find_subpath(File.join('LightMD', 'Design'), true)
unless design_group.files.any? { |f| f.path == 'SceneTheme+Factory.swift' }
  file_ref = design_group.new_file('SceneTheme+Factory.swift')
  target.add_file_references([file_ref])
end

project.save
puts 'Successfully added files to Xcode project!'
