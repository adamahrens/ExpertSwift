# SOLID Principles

## Single Responsibility

A class should have one and only one reason to change. Keep the class on a focused role/job. View class should just display data (not responsbile for loading data). Should be able to change from CoreData to Realm but then we have to make changes to the View class then we're violating the principle.

## Open-Closed

Classes, Modules, Functions should be open for extension but closed for modification. Should be able to expand the capabilities of your types without having to alter them. If you want to change beahvior of a class it shouldn't always be necessary to change the class.

Think of an AnalyticEvent enum. If we wanted to add another event, our switch would have to exhaust it. A Better way is to use a struct and make static func that return that Struct for each additional event

## Liskov Substitution

Objects in a program should be replaceable with instances of their subtypes without altering correctness. If we have two Protocols to return Expenses then if it's implemented via CoreData vs Realm then the code calling doesn't need to change.

## Interface Segregation

Clients should not be forced to depend upon interfaces they do not use. Break a protocol into multiple smaller ones. So parts of the app can implement the ones that are relevant to them. Don't implement methods you won't need. Might make sense to split UITableViewDelegate into separate protocols

## Dependency Inversion

Depend on abstractions not concerete implementations. Program to a protocol not the specific implementation.