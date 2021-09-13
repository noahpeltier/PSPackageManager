# PSPackageManager
An attempt to create a sort of package management module that uses native powershell only

# What is this?
Right now, it's just called apt but obviosuly as this matures I'll think of a better name.
This module is a project that birthed from a frustrating day when I hit the rate limit using Choco from our RMM and not being able to install Chocolatey on a machine since the Powershell version was too old.

I decide to use the `net.webclient` in powershell for all the downloading with supporting code to handle the running of the file afterwards.
I maintain a json file now as a software manifest with the data needed to get a package.