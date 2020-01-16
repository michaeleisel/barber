# require "xcode_barber/version"
require 'set'
require 'slop'
require 'xcodeproj'

module XcodeBarber
  class Error < StandardError; end

  def collect_args(testing)
    deps_help = 'The path to the directory containing the .swiftdeps files for this project. To find it, go to your build directory (usually either ~/Library/Developer/Xcode/DerivedData or ./Build) and go to the <app name>-<random letters> subdirectory. From there, run `find . -name \'*.swiftdeps\'` and find the directory containing the swiftdeps files for this target. If this is a big pain, feel free to file an issue.'
    if !testing
      begin
        return Slop.parse do |o|
          o.string '-t', '--target', 'The name of the target', required: true
          o.string '-p', '--project', 'The path to the .xcodeproj', required: true
          o.string '-r', '--root', 'The path to the root that the app starts from. Must be a swift UIApplicationDelegate.', required: true
          o.string '-d', '--deps', deps_help, required: true
          o.separator 'other options:'
          # o.bool '-f', '--force', 'Force the project.pbxproj file to be changed without asking first'
          o.on '--help' do
            puts "Example: ./barber.rb -t MyAppDebug -p MyApp.xcodeproj -r MyApp/AppDelegate.swift -d ~/.../DerivedData/.../MyAppDebug.build/Objects-normal/x86_64/"
            puts o
            exit
          end
        end
      rescue
        puts "Invalid arguments, try `barber --help` for usage"
        exit
      end
    else
      return {:project => "Beam.xcodeproj", :target => "beam", :root => "Beam/AppDelegate.swift", :deps => "#{ENV['HOME']}/Library/Developer/Xcode/DerivedData/Beam-asdsclslxivvadcbnjflpwajrfmp/Build/Intermediates.noindex/Beam.build/Debug-iphonesimulator/beam.build/Objects-normal/x86_64/"}
    end
  end

  def yesno
    begin
      system("stty raw -echo")
      str = STDIN.getc
    ensure
      system("stty -raw echo")
    end
    return str.downcase == "y"
  end

  def confirm_overwrite(testing, project_path)
    return if testing
    puts "This script will make changes to #{project_path}! Are you sure you want to continue? [y/n]"
    continue = yesno()
    exit unless continue
  end

=begin
  def export()
    # remove loops
    (0...(fs.size)).each { |i| o[i][i] = 0 }

    format = "S" * fs.size
    out = o.map { |row| row.pack(format) }.join("")
    puts fs.size
    IO.write("/tmp/deptrim.bin", out)
  end
=end

  def summarize_bottlenecks(fs, file_to_dep, provide_to_file)
    f_to_idx = fs.each_with_index.to_h

    dep_hash = fs.map do |file, deps|
      deps = file_to_dep[file]
      files = deps.flat_map do |dep|
        provide_to_file[dep]
      end
      [f_to_idx[file], files.map { |f| f_to_idx[f] }.uniq.sort - [f_to_idx[file]]]
    end

    o = Array.new(fs.size) { Array.new(fs.size) { 0 } }
    dep_hash.each do |i, idxs|
      idxs.each { |idx| o[i][idx] = 1 }
    end

    reverse = Hash.new { |h, k| h[k] = [] }

    dep_hash.each do |d, ds|
      ds.each do |n|
        reverse[n] << d
      end
    end

    n = 10
    summary = `mktemp /tmp/summary_XXXXXX`.chomp
    open(summary, "w") do |file|
      file.puts "Top #{n} with highest ratio dependencies to dependents:"
      top = dep_hash.map do |d, ds|
        [d, ds, ds.size.to_f / reverse[d].size]
      end.sort_by(&:last).reverse.take(n)
      file.puts top.map(&:first).map { |i| fs[i] }
      file.puts ""

      file.puts "Same as above, but with heavier weighting towards those with a low total number of dependents:"
      top = dep_hash.map do |d, ds|
        [d, ds, ds.size.to_f / (reverse[d].size ** 2)]
      end.sort_by(&:last).reverse.take(n)
      file.puts top.map(&:first).map { |i| fs[i] }
      file.puts ""

      file.puts "Still not finding the key bottlenecks in the dependency graph? Feel free to file an issue."
    end

    summary
  end

  def trimmed_deps(project_path, swiftdeps_path, root)
    # Dir.chdir(__dir__)
    raise "--project must be a .xcodeproj" unless project_path.end_with?(".xcodeproj")

    raise "pbxproj file not found in #{project_path}" unless File.file?("#{project_path}/project.pbxproj")

    provide_section = false
    depends_section = false

    file_to_dep = Hash.new { |h, k| h[k] = [] }
    provide_to_file = Hash.new { |h, k| h[k] = [] }

    files = `ls #{swiftdeps_path}/*.swiftdeps`.split("\n")
    names = files.map { |file| File.basename(file, ".swiftdeps") }

    files.each do |file|
      name = File.basename(file, ".swiftdeps")
      File.foreach(file) do |line|
        if line.start_with?("provides-top-level:")
          provide_section = true
          depends_section = false
          next
        elsif line.start_with?("depends-top-level:")
          provide_section = false
          depends_section = true
          next
        elsif line.start_with?("depends-member:")
          break
        elsif line.start_with?("depends-") || line.start_with?("provides-")
          provide_section = false
          depends_section = false
          next
        else
          str = line.start_with?("- !pri") ? line[12..-3] : line[3..-3]
          if provide_section
            provide_to_file[str] << name
          elsif depends_section
            file_to_dep[name] << str
          end
        end
      end
    end

    root_name = File.basename(root, ".swift")

    fs = [root_name]
    idx = 0
    files_seen = fs.to_set
    while idx < fs.size
      name = fs[idx]
      deps = file_to_dep[name]
      deps.each do |dep|
        files = provide_to_file[dep]
        fs.concat(files.reject { |f| files_seen.include?(f) })
        files_seen.merge(files)
      end
      idx += 1
    end

    fs_set = fs.to_set
    summary = summarize_bottlenecks(fs, file_to_dep, provide_to_file)
    puts "Trimming complete. Potential dependency bottlenecks summarized at #{summary}"
    return fs_set
  end

  def rewrite_project(target, project_path, fs_set)
    project = Xcodeproj::Project.open(project_path)
    target = project.targets.detect { |t| t.name == target }
    raise "Couldn't find target #{target} in #{project_path}. Is it capitalized correctly and all that?" unless target

    phase = target.source_build_phase
    phase.files.select do |f|
      path = f.file_ref.path.to_s
      next false unless path.end_with?(".swift")
      next false if fs_set.include?(File.basename(path, ".swift"))
      true
    end.each do |f|
      phase.remove_build_file(f)
    end

    project.save
  end

  def run()
    testing = false
    opts = collect_args(testing)
    project_path = opts[:project]
    confirm_overwrite(testing, project_path)
    deps = trimmed_deps(project_path, opts[:deps], opts[:root])
    rewrite_project(opts[:target], project_path, deps)
  end
end
