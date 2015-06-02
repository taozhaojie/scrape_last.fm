# scrape_last.fm
Use to scrape users, music, and related information using Last.fm API.
 
# getUser
Scrape users from a Last.fm group. Save usernames to user_list.csv.

# getTracks
Scrape banned and loved tracks for each user in user_list.csv. Save results to user_BannedTracks.csv, user_LovedTracks.csv, and user_log.csv.

Similarly, this can be extend to include other Last.fm track related API, e.g. getRecentTracks, getTopTracks.

# user_info
Get basic information for users in previous step. (country, age, gender).

# track_info
Get infotmation for tracks in users' banned and loved lists. (album, playcount, tags, artist, duration).
