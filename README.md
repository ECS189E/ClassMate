# ClassMate

## Why we built ClassMate

We wanted to build a platform to better connect students. We drew inspiration from LinkedIn and Piazza to create a social network for students. Although Piazza exists as a platform to connect students within the same class, its forum-style nature makes it too formal. LinkedIn allows people to build professional connections, but isn’t designed exclusively for students. 

Our vision was to create an app that would allow students to connect with other students based on criteria such as current/past classes, clubs, year, etc. We wanted to create public chat rooms that all students enrolled in a class would automatically be a part of, and the ability to create private chats with other students. 



## Overview

### Login View

Users can sign in with their Gmail to access our app. Returning users can skip the google login process. However, the login view will not be skipped because of an issue with Firebase and GoogleSignIn.

### Channel View

They will be prompted to join recommended class based on their time and location. For example, if a user is near Art 204 between 9:00 am - 10:00 am, our app will prompt the user want to join ECS 189E. The user won’t be prompted again after he/she has been prompted. 

This view is the root of our app. All classes a user chooses to join will be displayed in this view. Users can join a new classroom, go to their profile page, and sign out through this view.

### Chat view

Simple Chat implemented using MessageKit. We use the database feature from Firebase as the backend data storage for each “Classroom” or Channel, in which contains all the messages belonging to that Chatroom. Certain information is attached with each message, such as the username of the sender, sent date, and so on.

### Profile View

Users can access profile details such as their display name and year. Changes performed on this view are updated to the database.



## Contributions

Andy Li: ProfileView, Location detection to automatically prompt users to join class

Min Duan: ChatView, Login management with Weisu, and setting up the Firebase

Weisu Yin: LoginView with Min, ChannelView, help Min to fix bugs in ChatView