# Crate
Crate is a database viewer (and later an editor) for OSX
=====

![Screenshot](https://raw.githubusercontent.com/arbarlow/crate/master/screens/screen1.jpg)

## Status

Right now Crate is very young and needs a lot of work doing which can be tracked via an open [Trello board](https://trello.com/b/giqJQwWP/crate)

## Database support

Currently crate supports

 - PostgreSQL 8+ (but probably lower, just untested)

It is hopefully written in a way to support any table-like database see the [protocol](https://github.com/arbarlow/crate/blob/master/Crate/Classes/DBProtocols.h) and the current [PostgreSQL adapter](https://github.com/arbarlow/crate/blob/master/Crate/Classes/PostgreSQLAdapter.m)

## Contributing

It's a fairly standard Objective-C XCode project and uses Cocoapods for dependency management..

Awesome! Just fork it and perhaps just check in that i'm not doing that feature before and then get yourself a pull request..

## Swift

The project has no Swift at the moment as that wasn't even around when I started building this, however, whilst the project is written entirely in Objective-C it doesn't mean I have no plans to write some Swift later, but re-writing the project just for the sake of it seems silly right onw.
