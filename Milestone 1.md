## List of third party libraries:

- MessageKit (<https://cocoapods.org/pods/MessageKit>)
- ChatSDK (<https://cocoapods.org/pods/ChatSDK>) 		

## Server Support:  

- [Herokuapp](https://herokuapp.com/) (?)

  - Free server host

## APIs:

- APIs for login

- getUserProfile( )

  - Querying a single user

- updateUserProfile( )

  - Updating a user’s profile

- getChatLog( )

  - Retrieve recent chat history

- getUsers( ) 

  - Return a list of users matching a particular query

## List of Models:

- ChatModel (WIP)

  - Should chats be stored locally on server-side?

    - Combination of both?

  - Time vs space complexity

- ProfileModel

  - DisplayName (editable)

    - Perhaps separate from real name

  - Avatar

  - Previous classes

  - Current classes

  - Privacy setting

    - Each field can be made private

    - Privacy modes:

      - Visible to everyone
      - Visible only to people in same chat rooms 

## List of ViewControllers:

- LoginViewController (entry point for logged out users)

- SettingViewController

  - Segue from LoginViewController after successful login for new users
  - New users should fill in their profile
  - Old users can update their profile here
  - Logout 

- MainViewController

  - Display all chat rooms the user is in
  - Search 
  - Add new chat room

- ChatViewController 

  - Should have a button to view the list of active members in the current chat session
  - Should have a button to view the list of all the members registered in the classroom

- ProfileViewController

  - Click on a user’s avatar navigates to his or her profile page
  - Viewing a user’s own profile will allow them to edit it

- SearchViewController

  - Search for users or attributes (such as classes enrolled)

## List of week-long tasks and timeline:

| Task                       | Estimated Completion |
| -------------------------- | -------------------- |
| Server                     | Nov 18               |
| Database                   | Nov 18               |
| Storyboard                 | Nov 16               |
| RegisterViewController     | Nov 23               |
| LoginViewController        | Nov 23               |
| AccountSetUpViewController | Nov 23               |
| ChatViewController         | Nov 27               |
| ProfileViewController      | Nov 27               |
| SearchViewController       | Nov 30               |
| Beta Testing               |                      |

## https://trello.com/b/qZOR6l2A/sponsor-me

### LoginVC

<img src="https://user-images.githubusercontent.com/24563722/48452662-ed5f6d00-e764-11e8-85d2-222efdb127d8.jpg" width="250">

### AccountSetupVC

<img src="https://user-images.githubusercontent.com/24563722/48452663-ed5f6d00-e764-11e8-919d-6bbe5c736b5d.jpg" width="250">

### MainVC

<img src="https://user-images.githubusercontent.com/24563722/48452664-ed5f6d00-e764-11e8-97a8-2ef0e0345954.jpg" width="250">

### ChatVC

<img src="https://user-images.githubusercontent.com/24563722/48452665-ed5f6d00-e764-11e8-8704-970057d82bbf.jpg" width="250">

### SettingVC

<img src="https://user-images.githubusercontent.com/24563722/48452666-ed5f6d00-e764-11e8-840d-c82b8b0d47f1.jpg" width="250">

### ProfileVC

<img src="https://user-images.githubusercontent.com/24563722/48452667-edf80380-e764-11e8-952b-9a4b030e9fc4.jpg" width="250">
