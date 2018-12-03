# Spring Planning - 12.3

## 1. What we did

### Complete ChannelView and ChatView

- Synchronized local messages to database
  - Listen for Firebase updates to update view
- New users can access existing chat history
  - Messages are posted to server



### Recommend Channels

- In the ChannelView:
  - Tries to determine class user is in based on time and current location
  - Recommends this class to user via Alert
    - Each class is recommended once (prevent spamming user if they don't want to join)



## 2. What we plan on doing

### Polish ChatView

- Currently does not scroll to bottom, hiding new messages
- Avatars do not work



### Skip LoginView

- Store auth token locally to skip login for returning users

- Addresses slow login



### Finish Recommended Channels

- Currently fetches user GPS
- Still need to check if it is within a destination radius



### Implement ProfileView

- Create persistent profile in database
- ProfileView to allow user editing



## 3. Issues we're having

### GPS

- Finding clean way to check if current location in within a range

  - Currently attempting to build a rectangle of coordinates using the destination, and checking if user coordinate lies within bound
