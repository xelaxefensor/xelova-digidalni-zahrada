plasma extenskon fix: https://gist.github.com/Aishou/6441aeb87e381b606e4cefd615900f0c

- 1. first install the package:

`zypper in -y plasma-browser-integration`

- 2. get the folder ready needed in ur .mozilla folder
    
    `mkdir ~/.mozilla/native-messaging-hosts`
    
- 3. copy the json file.

`cp /usr/lib64/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json ~/.mozilla/native-messaging-hosts`

- 4. Done.