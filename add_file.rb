require 'xcodeproj'

project_path = '/Users/elmerheino/Documents/Projects koodailu/OutRun_release/OutRun.xcodeproj'
project = Xcodeproj::Project.open(project_path)

file_path = '/Users/elmerheino/Documents/Projects koodailu/OutRun_release/OutRun/Views/Data/LabelledWorkoutTypeView.swift'
group = project.main_group.find_subpath('OutRun/Views/Data', true)
target = project.targets.first

unless group.files.any? { |f| f.real_path.to_s == file_path }
  file_reference = group.new_reference(file_path)
  target.add_file_references([file_reference])
  project.save
  puts "Added file to project"
else
  # double check build phase
  if target.source_build_phase.files.any? { |f| f.file_ref && f.file_ref.real_path.to_s == file_path }
    puts "File already in target build phase"
  else
    file_reference = group.files.find { |f| f.real_path.to_s == file_path }
    target.add_file_references([file_reference])
    project.save
    puts "Added to target build phase!"
  end
end
