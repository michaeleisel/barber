Steps:
1. Build the app in Xcode
2. Get the swiftdeps directory for this project, e.g. by doing:
```
cd <path to build, probably .../DerivedData but whatever is in your settings for build artifacts> \
&& find . -name 'OtherViewController.swiftdeps'
```
3. From this readme's directory, run:
```
barber -t ExampleApp \
       -p ExampleApp.xcodeproj \
       -r ExampleApp/AppDelegate.swift \
       -d <swiftdeps directory>
```
4. Now, nothing should have changed (you can verify with `git diff`). This is because we used the main app delegate file, `AppDelegate.swift`, as the root, and it has recursive dependencies to everything. In a real app, this is equivalent to the normal app delegate.
5. Remove `AppDelegate.swift` from the `compile sources phase`, e.g. by removing it from the project or unchecking the box for it in "Target membership".
6. Add `ExampleApp/SingleScreenAppDelegate.swift` to the project. This is our app delegate that just displays `OtherViewController`.
7. Build
8. Run the same `barber` command as above, but this time replacing `ExampleApp/AppDelegate.swift` with `ExampleApp/SingleScreenAppDelegate.swift`.
9. The tool should now have removed `RootViewController.swift` and `RootModel.swift` from the compile phase. This is because `SingleScreenAppDelegate`, unlike `AppDelegate` doesn't depend on `RootViewController`. `RootModel` is removed since it's only depended upon by `RootViewController`.
10. Verify that step 9 occurred correctly by checking the compile sources phase, or by doing `git diff -- ExampleApp.xcodeproj/project.pbxproj`.
