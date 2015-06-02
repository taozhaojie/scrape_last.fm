require 'httparty'
require 'url'

def getResponse(url)
	cnt_err = 0
	while cnt_err <= 5
		begin
			encoded_uri = URI::encode url
			response = HTTParty.get(encoded_uri, :verify => false)
			break
		rescue
			cnt_err += 1
			puts "Connection error, retry #{cnt_err} secs later..."
			sleep(cnt_err)
			response = nil
			next
		end
	end
	return response
end

def getTrackInfo(response)
	r = ""
	if !(response.nil?)
		begin
			h = JSON.parse(response.body)
			len = h["track"]["duration"]
			hot = h["track"]["playcount"]
			alb = h["track"]["album"]["title"]
			tag = h["track"]["toptags"]["tag"]

			arr = []
			if tag.nil?
				tags = ""
			else
				if tag.is_a? Array
					tag.each{|x| arr << x["name"]}
					tags = arr.join("--")
				else
					tags = tag["name"]
				end
			end
			r = len + "," + hot + "," + q(alb) + "," + tags
		rescue
			return r
		end
	end
	return r
end

def q(str)
	return '"' + str + '"'
end

api_key = "072a234d286841ac47e05c13999bb25c"

# get all tracks from banned and loved tracks
puts "fetching tracks..."
f = File.open("user_BannedTracks.csv",:encoding=>'utf-8')
f2 = File.open("user_LovedTracks.csv",:encoding=>'utf-8')
track = []
f.each{|line|
	line = line.chomp
	ln = line.split(',')
	str = ln[1] + "-" + ln[2]
	track << str
}
f.close
f2.each{|line|
	line = line.chomp
	ln = line.split(',')
	str = ln[1] + "-" + ln[2]
	track << str
}
f2.close

track = track.uniq

f = File.open("tracks_info.csv","wb")
cnt = 0
track.each{|line|
	line = line.chomp
	ln = line.split('"-"')
	art = ln[0].gsub('"','')
	trk = ln[1].gsub('"','')

	cnt += 1
	puts "Processing track no.#{cnt}."

	url = "http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=#{api_key}&artist=#{art}&track=#{trk}&format=json"
	response = getResponse(url)
	f.puts q(art) + "," + q(trk) + "," + getTrackInfo(response)
}
f.close