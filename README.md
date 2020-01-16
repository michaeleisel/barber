# Barber
## Fast build times for big Swift projects

## How it works

When working on a single small part of your app, e.g. `SettingsViewController`, you don't want to be compiling the whole app. You only need to work on this screen, after all. To get a fast build time in this situation, you can swap in a small AppDelegate that merely runs this one screen, and then use Barber to strip dependencies that aren't needed by it. When you're done, just revert the project.pbxproj file changes. Note: it only trims Swift dependencies, not Objective-C ones.

## Installation

`[sudo] gem install xcode_barber`

## Usage

```
# add the small AppDelegate for this one screen to your project
# build your project with the new app delegate - it must be successfully built for this to work
git clone https://github.com/michaeleisel/Barber
./Barber/barber.rb -t MyTarget -r MyApp/AppDelegate.swift -p MyApp/MyApp.xcodeproj -d ~/.../DerivedData/MyApp-asdf/path/to/swiftdeps/files
# unnecessary files are removed! now you can do your work
# reset the .pbxproj file when you're done, e.g. `git co head -- MyApp/MyApp.xcodeproj/project.pbxproj`
```

## Any issues?

Computing dependencies is a tricky thing. If it didn't work for you for any reason, feel free to make a short Github issue about it, and you can expect a prompt response!

## Author

Michael Eisel, michael.eisel@gmail.com
