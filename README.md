[Pivotal Tracker] (https://www.pivotaltracker.com/n/projects/1416072)

# Concept
App that allows a user to follow a Kickstarter account and recieve notifications when the kickstarter user posts a new project.



## Auth

<b>Login Request</b>
```
post: /login
{
    "email": USER@EMAIL.COM,
    "password": USER_PASSWORD
}
```


<b>Success</b>
```
{ "auth": true, "token": USER_TOKEN }
```

<b>Failure</b>
```
{ "auth": false }
```
<hr>
<b>Logout Request</b>

```
post: /logout
{ "token": USER_TOKEN }
```
<b>Success</b>
```
{ "auth": true }
```

<b>Failure</b>
```
{ "auth": false }
```
## Registration
<b>New Account</b>
```
post: /registrations
{
	"user": {
    	"email": USER@EMAIL.COM,
        "password": USER_PASSWORD
    }
}
```
<b>Success</b>
```
{ "registered": true, "token": USER_TOKEN }
```
## Project Creators
<b>Search</b>
```
post: /project_creators/search
{
	"search_name": SEARCHTERM
}
```
<b>Response</b>
```
[
	{
    	"name": PROJECT_CREATOR_NAME,
        "profile_url": PROJECT_CREATOR_API_FRIENDLY_URL,
        "profile_avatar": PROJECT_CREATOR_IMAGE_URL
    }
]
```
<b>Create</b>
```
{
	"token":
}
```