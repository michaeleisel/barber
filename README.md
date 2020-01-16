# Barber
## Fast build times in big projects!

## Details

When working on a single small part of your app, e.g. `SettingsViewController`, you don't want to be compiling the whole app. You only need to work on this screen, after all. To get a fast build time in this situation, you can swap in a dummy AppDelegate that merely runs this one screen, and then use Barber to strip dependencies that you don't need. When you're done, just revert the project.pbxproj file changes. Note: it only trims swift dependencies, not Objective-C etc.

## Usage

```
# remove the real AppDelegate from your compile sources phase
# add the mock AppDelegate that has fewer dependencies to the compile sources phase
# build your project with the new app delegate - it must be successfully built for this to work
git clone https://github.com/michaeleisel/Barber
./Barber/barber.rb -t MyTarget -r MyApp/AppDelegate.swift -p MyApp/MyApp.xcodeproj -d ~/.../DerivedData/MyApp-asdf/path/to/swiftdeps/files
# unnecessary files are removed! now you can do your work
git co head -- MyApp/MyApp.xcodeproj/project.pbxproj # reset the .pbxproj file when you're done
```

## Any issues?

Computing dependencies is a tricky thing. If it didn't work for you for any reason, feel free to make a short Github issue explaining why, and you can expect a prompt response!

## Installation

The project simply consists of a script, so just `git clone` it.

## Author

Michael Eisel, michael.eisel@gmail.com
