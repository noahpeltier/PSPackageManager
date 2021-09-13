# spi Package Manager
spi (Simple Package Installer), is an attempt to create a sort of package management module that uses native powershell only

# What is this?
This module is a project that birthed from some limitations I found with Chocolaty and scoop on variouse systems.

The spi module uses the windows native `net.webclient` with no dependancies, using suport code to call from a json file wich serves as a manifest of software sources.
The manifest contains a hash of the file as well to compare when it is downloaded to asure security.
<br>
<br>

# Examples

### To install an application:
```powershell
spi install appname
```

You can also pass additional commandline arguments at the end:
```powershell
spi install greenshot "/VERYSILENT /SKIPPOPUPS"
```

### To uninstall an application:

for now, spi is using the registry to find software installed and uses the uninstall string in the Reg key.
```powershell
spi uninstall greenshot
```

## To Do:
- Support for upgrading applications
- Support for installing package dependancies
- Cup holder
