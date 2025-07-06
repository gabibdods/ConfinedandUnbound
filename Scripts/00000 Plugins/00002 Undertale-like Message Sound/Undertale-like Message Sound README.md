# Introduction
Hello you Undertale fan! This README will teach you how to use this weird plugin!

Current version of the plugin is 0.0.2.0, updated on October 4th, 2023!

## How does the plugin work?

To make your bloop sound play, you just need to use the corresponding message tag.

Here's an example of how it's used!

`
:[name=Toriel]:Hello human, my name is Toriel and I come from Undertale!:[bloop_sound=toriel_sound,100,100]:
`

With this message tag, you're telling the system you want the Message system to play the audio file 'toriel_sound', with a volume of 100, and a tempo of 100. Note that the file must be located in the Audio/se/folder, or else it won't work.
Note: the two 100 aren't mandatory, so if you don't want to setup the volume and the tempo to something other than 100, you can just write `:[bloop_sound=toriel_sound]:`

With the command written above, the system will play the audio file every 8 characters (I believe spaces are counted). As of 0.0.2.0, there is two ways to change this number. The first is adding a fourth parameter to the message tag, as showed below:

`
:[name=Toriel]:Hello human, my name is Toriel, I come from Undertale and I'm a rap god!:[bloop_sound=toriel_sound,100,100,4]:
`

This way, the system will play the sound every four characters. Depending on the sound used, you might want to tweak this value until you have a proper result.
There is one disadvantage to this way: you need to write the four parameters. So, for 0.0.2.0, I thought about adding a second message tag. Here's an example of its use:

`
:[name=Toriel]:Hello human, my name is Toriel, I come from Undertale and I'm sleepy...:[bloop_sound=toriel_sound;bloop_mod=4]:
`

You can write the way just above, or this way, if you prefer:

`
:[name=Toriel]:Hello human, my name is Toriel, I come from Undertale and I'm sleepy...:[bloop_sound=toriel_sound]::[bloop_mod=12]:
`

Know that adding the bloop_mod message tag alone in a message will do absolutely nothing as it needs to be used along the bloop_sound message tag, and is here if you don't want to add the four parameters constantly.

# Afterwords

I hope you'll have fun using this plugin! If you have suggestions about it, you can send me a PM on Discord at @pw_rey !

Of course, make sure to credit me for this! It didn't take too much time to work on, but a credit is always appreciated.
Also, if other makers want to use this plugin, please give them the link of the resource topic on the Pokémon Workshop Discord server, or the direct link to the plugin entry on the Pokémon Workshop website! :D

# Changelog
0.0.1.0 — October 17th, 2022:
- First version of the plugin
0.0.2.0 — October 4th, 2023:
- Fixed a loading problem with the PluginManager due to a PSDK constant being renamed recently
- Added a bloop_mod message tag to help in not having to write four parameters in the bloop_sound message tag

# Roadmap
- Add the possibility to play one unique sound during a text message directly inside PSDK
- Refactor this plugin when the Audio in messages feature will be officially implemented to make use of that feature
- Suggestions people might throw at me...?
