# encoding: UTF-8
require 'mechanize'

group_name = "Addicted to Last.fm"
f = File.open("user_list.csv","wb") # save user list here

url_name = group_name.gsub(" ","+")
agent = Mechanize.new

# get page number first
while true
	begin
		page = agent.get("http://www.last.fm/group/#{url_name}/members?memberspage=1")
		break
	rescue
		sleep(2)
		next
	end
end
page_no = page.search("a[class='pagelink lastpage']")[0].text.to_i


for i in 1..page_no
	puts "Fetching page no.#{i}..."
	
	while true # keep fetching until success
		begin
			page = agent.get("http://www.last.fm/group/#{url_name}/members?memberspage=#{i}")
			break
		rescue # in case connection failures
			sleep(2)
			next
		end
	end

	page.search("strong").search("a").map do |text|
		uid = text.attributes['href'].text.gsub("/user/","")
		f.puts uid
	end
end
f.close
