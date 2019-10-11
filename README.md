# OnMap
Udacity Nanodegree - OnMap

#OnMap info
This app is created as a final project of the [iOS Nanodegree - Udacity](https://www.udacity.com/course/ios-developer-nanodegree--nd003).

The On The Map app allows users to share their location and a URL with their fellow students. To visualize this data, On The Map uses a map with pins for location and pin annotations for student names and URLs, allowing students to place themselves “on the map,” so to speak. 

First, the user logs in to the app using their Udacity or Facebook username and password. After login, the app downloads locations and links previously posted by other students. These links can point to any URL that a student chooses. 

After viewing the information posted by other students, a user can post their own location and link. The locations are specified with a string and forward geocoded. They can be as specific as a full street address or as generic as “Costa Rica” or “Seattle, WA.”

The app has three view controller scenes:

    Login View: Allows the user to log in using their Udacity credentials, or (as an extra credit exercise) using their Facebook account
    Map and Table Tabbed View: Allows users to see the locations of other students in two formats.  
    Information Posting View: Allows the users specify their own locations and links. 

## Build
### Requirements
* Xcode 10.1
* iOS 12.1
* Swift 4.2

### Steps to build
1. Clone the repository.
2. Run `pod install` from the directory containing the `Podfile`.
1. Open `OnMap.xcworkspace`
5. Build app for your device or simulator


## Resources
This app uses the following APIs:

### APIs
| Framework | Description |
| --- | --- |
| [Facebook API](https://developers.facebook.com/docs/facebook-login/ios) | It is used to login to FB. |
| [Parse API](http://blog.parseplatform.org/) | Get student locations. |
