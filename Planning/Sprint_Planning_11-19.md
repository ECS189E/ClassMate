# Spring Planning - 11.19



## 1. What we did

### Find backend solution

- We started off by tackling the most essential component: the backend server for our app
- We began by examining Heroku, a free online hosting service. We intended to use write our own server in Python (using Flask), to support the necessary API's
- Because chat services are a popular feature of many applications, we examined existing libraries first
- This is where we found ChatSDK, a Cocoapod usable not only for the chat component of our app, but for other backend services as well
- This required setting up Firebase, a popular backend service that already supports many of the features we are looking for, from authentication to APIs, without the need to create our own server

- [Initial Firebase Setup](https://github.com/ECS189E/ClassMate/commit/ba70e527a745abc65503680c426fb0c05f763d27) - commit containing our initial setup for Firebase



### ChatSDK skeleton

- [Using this guide](https://chatsdk.co/docs/ios-quickstart/), we were able create a bare bones chat app

- Many server-related functions are included in this SDK, allowing us to avoid the need to create our own chat-related API's

- Avoiding the need to implement our own server simplifies things greatly. We can focus on the features we want to implement by having a strong start to the chat 




## 2. What we plan on doing

### Finishing the chat 

- This our priority, as it is a central component of the app



### Database

- Setting this up will allow us to store data
- This will pave the way for implementing user profiles 



## 3. Issues we're having

- Some features from Chat SDK are not supported without an Apple Developer account
