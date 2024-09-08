```python
#!/usr/bin/env python

import requests

server='http://xelov.cz:4533' # replace with your server base url, can also be e.g. http://127.0.0.1:4533
username='xela' # replace with your username
password='xelalsut78AT' # replace with your password

version='1.8.0'
client='NavidromeUI'

url=f'{server}/auth/login'
r = requests.post(url, json={"username": username,"password": password})
auth_response = r.json()
token = auth_response['subsonicToken']
salt = auth_response['subsonicSalt']

url=f'{server}/rest/getArtists?u={username}&v={version}&c={client}&t={token}&s={salt}&f=json'
r = requests.get(url)
for artist_index in r.json()['subsonic-response']['artists']['index']:
  for artist in artist_index['artist']:
    r = requests.get(artist["artistImageUrl"])
    if r.status_code != 200:
      print(f'{artist["name"]} => error: {r.content.decode("utf-8")}')
    else:
      print(f'{artist["name"]} OK!')

```
