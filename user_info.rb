require 'httparty'
require 'url'

api_key = "xxxxxxxxxxxxxxxx"

Limit_banned = 20
Limit_loved = 200

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

def getUserInfo(response)
	r = ""
	if !(response.nil?)
		begin
			h = JSON.parse(response.body)

			loc = h["user"]["country"]
			age = h["user"]["age"]
			sex = h["user"]["gender"]
			reg = h["user"]["registered"]["unixtime"]

			r = loc + "," + age + "," + sex + "," + reg
		rescue
			return r
		end
	end
	return r
end

arr_user = []
f = File.open("user_log.csv","r")
f.each{|line|
	line = line.chomp
	ln = line.split(',')
	if ln[1].to_i >= Limit_banned && ln[2].to_i >= Limit_loved
		user << ln[0]
	end
}
f.close
arr_user = arr_user.uniq

f = File.open("users_info.csv","wb")
cnt = 0
arr_user.each{|uid|
	cnt += 1
	puts "Processing user no.#{cnt}."

	url = "http://ws.audioscrobbler.com/2.0/?method=user.getinfo&user=#{uid}&api_key=#{api_key}&format=json"
	response = getResponse(url)

	f.puts uid + "," + getUserInfo(response)
}
f.close