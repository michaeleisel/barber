# Barber
## Fast build times for big Swift projects

## How it works

Why compile your whole app and run the same steps to navigate to it every time you run when you're just working on a single view controller or a smaller section of your app?

To improve build times, and your productivity in this situation, why not swap in a small AppDelegate that runs a smaller section of your app?  Use Barber to strip your unused dependencies and speed things up.

**Note:** Barber only trims Swift dependencies, not Objective-C ones.

## Installation

`sudo gem install xcode_barber`

## Usage

1. First, add a new AppDelegate that focuses on a specific view controller or section of your app.
2. Temporarily prevent the existing AppDelegate from being compiled. The easiest way to achieve this is to select it in the Project Navigator and use the File Inspector to remove it from the Target Membership for the target.
3. Build the app and ensure that everything is working you expect.

Then, run `barber`. Pass the target name, the project file path, the new AppDelegate path, and the path to the directory that contains the `swiftdeps` files for the project.

````
barber -t MyTarget -r MyApp/AppDelegate.swift -p MyApp/MyApp.xcodeproj -d ~/.../DerivedData/MyApp-asdf/path/to/swiftdeps/files
````

That’s it! The project no longer compiles unnecessary files. To reset everything, just discard your `.pbxproj` file changes.

## Example app

You can see a full example in the [ExampleApp directory](https://github.com/michaeleisel/barber/tree/master/ExampleApp)

## Any issues?

Computing dependencies is tricky. If it didn't work for you, feel free to create a [GitHub issue](https://github.com/michaeleisel/barber/issues). You can expect a prompt response!
