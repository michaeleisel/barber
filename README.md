# Barber
## Fast build times for big Swift projects

## How it works

When working on a single small part of your app, e.g. `SettingsViewController`, you don't want to be compiling the whole app. You only need to work on this screen, after all. To get a fast build time in this situation, you can swap in a small AppDelegate that merely runs this one screen, and then use Barber to strip dependencies that aren't needed by it. When you're done, just revert the project.pbxproj file changes. Note: it only trims Swift dependencies, not Objective-C ones.

## Installation

`[sudo] gem install xcode_barber`

## Usage

```
# add the small AppDelegate for this one screen to your project
# remove the other AppDelegate from the "Compile Sources" build phase, e.g. by unchecking the box for it in "Target Membership" or temporarily removing it from the project altogether.
# build your project after swapping app delegates - it must be successfully built for this to work
barber -t MyTarget -r MyApp/AppDelegate.swift -p MyApp/MyApp.xcodeproj -d ~/.../DerivedData/MyApp-asdf/path/to/swiftdeps/files
# unnecessary files are no longer compiled! now you can do your work on that one screen
# reset the .pbxproj file when you're done, e.g. `git co head -- MyApp/MyApp.xcodeproj/project.pbxproj`
```

You can see a fully worked out example at ExampleApp/README.md in this repo

## Any issues?

Computing dependencies is a tricky thing. If it didn't work for you for any reason, feel free to make a short Github issue about it, and you can expect a prompt response!
