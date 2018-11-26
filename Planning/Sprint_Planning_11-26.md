# Spring Planning - 11.26



## 1. What we did

### Server

- We used Firebase as the backend of our server
  - Firebase's existing services of user authentication and databases allow us to avoid reinventing the wheel
- Additionally, we switched libraries from ChatSDK to MessageKit
  - ChatSDK was very comprehensive, which is what drew us into it
  - However, the views from this library were implemented in Objective-C, which meant customizing/adding views required an understanding of Objective-C that we did not believe was feasible in our short timeline



### Sign-in

- Users are only able to sign-in via Google authentication
  - Because our app is targeted at UC Davis students, this creates a restriction requiring a `@ucdavis.edu` address


### Database

- Using Firebase's NoSQL database, we plan on storing objects for Users and Channels

  - Users

    - Username  email address)
    - List of channels they are currently in 
    - Profile 

  - Channels

    - List of users
    - List of messages (ADT containing sender, content, and messageID)
    - Channel type (public/private)


### ChatView

- The ChatView is the View users interact in, containing messages and chat bubbles
- Using components from the MessageKit Cocoapod, this has already been implemented



### Started ChannelView

- The ChannelView is entered after a user is authenticated
- This contains a list of all Channels a user is currently participating in
- This view also allows them to enter a channel and create a new one

- A tab bar is used to access other Views within the app



## 2. What we plan on doing

### Finish rest of Chatroom

- Finish the ChannelView 
  - Fetch data correctly from database
  - Tab bar for other Views selection
- Data interaction for users in chatroom 
- Currently, data is localized for the user signed in
  - Would like to fetch other users' data from the database



## 3. Issues we're having

- Login too slow
  - One potential way to address this by using a dispatch queue
  - However, an issue with proceeding to the next View is that this would be done unconditionally 
    - In the event of an authentication failure, this would present problems
  - Potentially introduce an intermediary loading screen