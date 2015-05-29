require 'httparty'
require 'url'

# Last.fm API Key
api_key = "xxxxxxxxxxxxxxxxxxxxxxxxxx"

# no. of banned and loved tracks that users should at least have
# change this to 0 when fetching all users
Limit_banned = 20
Limit_loved = 200

# functions
def getBannedTracks(response)
	r = []
	begin
		h = JSON.parse(response.body)
	rescue
		return r
	end
	arr = h["bannedtracks"]["track"]
	cnt = 0
	begin
		if !(arr.nil?)
			if arr.is_a? Hash
				if arr["@attr"].nil?
					cnt += 1
					artist = arr["artist"]["name"]
					music = arr["name"]
					timestamp = arr["date"]["uts"].to_s
					r << '"' + artist + '","' + music + '",' + timestamp
				end
			else
				arr.each{|x|
					if x["@attr"].nil?
						cnt += 1
						artist = x["artist"]["name"]
						music = x["name"]
						timestamp = x["date"]["uts"].to_s
						r << '"' + artist + '","' + music + '",' + timestamp
					end
				}
			end
		end
	rescue
		f = File.open("error_log.txt","a")
		f.puts response
		f.close
	end
	return r
end

def getLovedTracks(response)
	r = []
	begin
		h = JSON.parse(response.body)
	rescue
		return r
	end
	arr = h["lovedtracks"]["track"]
	cnt = 0
	begin
		if !(arr.nil?)
			if arr.is_a? Hash
				if arr["@attr"].nil?
					cnt += 1
					artist = arr["artist"]["name"]
					music = arr["name"]
					timestamp = arr["date"]["uts"].to_s
					r << '"' + artist + '","' + music + '",' + timestamp
				end
			else
				arr.each{|x|
					if x["@attr"].nil?
						cnt += 1
						artist = x["artist"]["name"]
						music = x["name"]
						timestamp = x["date"]["uts"].to_s
						r << '"' + artist + '","' + music + '",' + timestamp
					end
				}
			end
		end
	rescue
		f = File.open("error_log.txt","a")
		f.puts response
		f.close
	end
	return r
end

def getPageVol(response,str)
	case str
	when "Banned"
		track_str = "bannedtracks"
	when "Loved"
		track_str = "lovedtracks"
	end

	h = JSON.parse(response.body)
	r = h[track_str]["@attr"]["total"]
	return r.to_i
end

# read in usernames
arr_user = []
f = File.open("user_list.csv","r")
f.each_line{|line|
	line = line.chomp
	arr_user << line
}
f.close

# files to save results
f2 = File.open("user_BannedTracks.csv","a") # users' banned tracks
f3 = File.open("user_LovedTracks.csv","a") # users' loved tracks
f4 = File.open("user_log.csv","a") # record no. of tracks

cnt = 0
cnt_get = 0

arr_user.each{|uid|
	cnt += 1

	puts "Processing user no.#{cnt}, #{cnt_get} fetched."

	# get the amount of tracks
	# banned
	while true
		begin
			url = "http://ws.audioscrobbler.com/2.0/?method=user.getbannedtracks&user=#{uid}&limit=1&api_key=#{api_key}&format=json"
			encoded_uri = URI::encode url
			response = HTTParty.get(encoded_uri, :verify => false)
			break
		rescue
			puts "Connection error, retry 3 secs later..."
			sleep(3)
			next
		end
	end
	begin
		vol_banned = getPageVol(response,"Banned")
	rescue
		vol_banned = 0
	end

	# loved
	while true
		begin
			url = "http://ws.audioscrobbler.com/2.0/?method=user.getlovedtracks&user=#{uid}&limit=1&api_key=#{api_key}&format=json"
			encoded_uri = URI::encode url
			response = HTTParty.get(encoded_uri, :verify => false)
			break
		rescue
			puts "Connection error, retry 3 secs later..."
			sleep(3)
			next
		end
	end
	begin
		vol_loved = getPageVol(response,"Loved")
	rescue
		vol_loved = 0
	end

	# set an upper bound for maximun number of tracks to fetch
	vol_banned = 1500 if vol_banned >= 1500
	vol_loved = 1500 if vol_loved >= 1500

	# when the user satisfy the condition
	if vol_banned >= Limit_banned && vol_loved >= Limit_loved
		cnt_get += 1

		# banned tracks
		cnt_err = 0
		while cnt_err <= 5
			begin
				url = "http://ws.audioscrobbler.com/2.0/?method=user.getbannedtracks&user=#{uid}&limit=#{vol_banned}&api_key=#{api_key}&format=json"
				encoded_uri = URI::encode url
				response = HTTParty.get(encoded_uri, :verify => false)
				break
			rescue
				cnt_err += 1
				puts "Connection error (banned: #{vol_banned}), retry #{cnt_err} secs later..."
				sleep(cnt_err)
				response = nil
				next
			end
		end
		result = getBannedTracks(response)
		if result.nil?
			size_banned = 0
		elsif result.size == 1
			f2.puts '"' + uid + '",' + result[0]
			size_banned = 1
		else
			result.each{|line|
				f2.puts '"' + uid + '",' + line
			}
			size_banned = result.size
		end

		# loved tracks
		cnt_err = 0
		while cnt_err <= 5
			begin
				url = "http://ws.audioscrobbler.com/2.0/?method=user.getlovedtracks&user=#{uid}&limit=#{vol_loved}&api_key=#{api_key}&format=json"
				encoded_uri = URI::encode url
				response = HTTParty.get(encoded_uri, :verify => false)
				break
			rescue
				cnt_err += 1
				puts "Connection error (loved: #{vol_loved}), retry #{cnt_err} secs later..."
				sleep(cnt_err)
				response = nil
				next
			end
		end
		result = getLovedTracks(response)
		if result.nil?
			size_loved = 0
		elsif result.size == 1
			f3.puts '"' + uid + '",' + result[0]
			size_loved = 1
		else
			result.each{|line|
				f3.puts '"' + uid + '",' + line
			}
			size_loved = result.size
		end

		f4.puts '"' + uid + '",' + size_banned.to_s + "," + size_loved.to_s
	end
}

f2.close
f3.close
f4.close