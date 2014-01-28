PowerShell-Profile
==================

	    _/_/_/    _/_/_/  
	   _/    _/  _/    _/ 
	  _/_/_/    _/_/_/    
	 _/        _/         
	_/        _/          

PowerShell Profile is a Server Management Framework.
Checkout the [wiki page](https://github.com/janikvonrotz/PowerShell-Profile/wiki) for more information.

# References

> Holy fucking creeper shit, this is the best Powershell Server Management Framework I've used!

-- You in a few seconds

#How to install

Download the latest release:

![GitHub Download ZIP](https://raw.github.com/janikvonrotz/PowerShell-Profile/master/doc/GitHub%20Download%20ZIP.png)

and unzip it in the directory of your choice OR use git to clone the whole repository:

	git clone git://github.com/janikvonrotz/PowerShell-Profile.git

Now add a profile configuration file to the config folder:

	COPY    \templates\EXAMPLE.profile.config.xml    TO    \config\... 
	
And
	
	RENAME    EXAMPLE.profile.config.xml    TO    [SOMETHING].profile.config.xml

Now take your time to edit your new PowerShell Profile config file.
Checkout the [wiki page](https://github.com/janikvonrotz/PowerShell-Profile/wiki#custom-features) for more information.

	EDIT    [SOMETHING].profile.config.xml

	SAVE    [SOMETHING].profile.config.xml
	
Open your Powershell commandline and enter:

	PS C:\Powershell-Profile> Set-ExecutionPolicy remotesigned
	
Or depending on your windows security restrictions:
	
	PS C:\Powershell-Profile> Set-ExecutionPolicy unrestricted

At last execute the install script from the PowerShell commad line:

	PS C:\Powershell-Profile> .\Microsoft.PowerShell_profile.install.ps1
