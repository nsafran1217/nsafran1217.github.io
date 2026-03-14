# Setting up Synergy on UNIX workstations to share mouse and keyboards
*Published: 30-May-2025 - Last Updated: 30-May-2025*

When I first read about Synergy when I was kid, I was so excited about it. I had a slight obsession with KVMs, and Synergy seemed like an even cooler experience. I remember I set it up on 2 Windows XP computers, but I think I had issues getting it to work on boot up, so I never ended up using it much.

Now, I'd like to get it working on some of my UNIX workstations since keyboards and mice take up too much space. Although I mostly access the computers via terminal or remote X session, I still like to have a physical setup that I can use.

I will add to this page when I setup more systems with synergy.

## Synergy 1.2.8
This is the last release before they moved to cmake, so this is the one I used.

### Solaris 9
### Build & Install
Building  was easy. I have GNU binutils and GCC.  
`GNU ld (GNU Binutils) 2.24`  
`gcc version 4.2.4`  
I don't have a good list of everything installed for this system.

### Server Configuration
XDM doesn't allow the mouse or keyboard to be shared, so we only put the startup in Xsession.d. You have to login before you can share the mouse and keyboard.

### `/usr/dt/config/Xsession.d/0099.synergys` :

    ps -ef | grep synergys | grep -v grep | awk '{print $2}' | xargs kill
    sleep 1
    /usr/local/bin/synergys --config /etc/synergy.conf

`chmod +x /usr/dt/config/Xsession.d/0099.synergys`

Config file: `/etc/synergy.conf`

    section: screens
        blade150:
        c360:
    end
    section: links
        blade150:
           right = c360
        c360:
           left = blade150
    end

### HP-UX 11.11
### Build & Install
You must have either gnu ld or a fully patched HP ld with patch PHSS_39749. This can be found on the 2009-12 Support Plus CD. See my [blog entry about setting up my C360 for specifics](002-c360-hpux-install.html).  
If you don't, you will get an error about XTest not existing. This is due to a linker error.

I also used GNU make 1.79 to build it. HP's make may or may not work.

`./configure `  
`make`  
`make install`

There are many keymaps that need commented out in `lib/platform/CXWindowsUtil.cpp` since HP-UX 11.11 X11 headers do not have them. Then we need automake aclocal-1.6 to make since we changed the file. [See my setup blog for details](002-c360-hpux-install.html).  
You can download the modified file here: [https://gist.github.com/nsafran1217/6ca46271ab33d60256d0ee4c7797c94f](https://gist.github.com/nsafran1217/6ca46271ab33d60256d0ee4c7797c94f)

With the modified file, it build and works just fine.

### Client Configuration
We want synergy to startup automatically at dtlogin so we can interact with the login screen. Note that you must have a mouse and keyboard connected to the computer, otherwise X will fail to start. There is a way around this, but I didn't configure that. I just leave a mouse and keyboard connected.


I ignored the warning in these files about not modifying them.   
My synergy server's name is `blade150`

### `/usr/dt/config/Xsetup` :

    ps -ef | grep synergyc | grep -v grep | awk '{print $2}' | xargs kill
    sleep 1
    /usr/local/bin/synergyc blade150

### `/usr/dt/config/Xstartup` :

    ps -ef | grep synergyc | grep -v grep | awk '{print $2}' | xargs kill
    sleep 1

### `/usr/dt/config/Xsession.d/0099.synergyc` :

    ps -ef | grep synergyc | grep -v grep | awk '{print $2}' | xargs kill
    sleep 1
    /usr/local/bin/synergyc blade150

