# Chanoply

Chanoply is a minamalistic plugin to give channel operator status to users based on the server, channel and hostname of the user.

## Usage 

Copy the chanoply.pl file into .irssi/scripts and optionally symlink it in .irssi/scripts/autorun to enable it to run on start up.

### Add a user.

In the window for the channel you want the user to be in type `/chanoply add nickname` where nickname is the nickname of the user.  The user MUST be present in the channel at the time.

### Delete a user.

In the window for the channel you want the user to be in type `/chanoply del nickname` where nickname is the nickname of the user.  The user MUST be present in the channel at the time.

## Configuration

Two options exist:

`/chanoply_cmd` the command the user will type to get channel operator status in the channel.  This defaults to .opme

`/chanoply_path` the path to the file to store information about the users on the access list.  This defaults to .irssi/chanoply

## Bugs

Please report bugs to symkat@symkat.com.
