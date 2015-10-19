# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'rubygems'
require 'nokogiri'
require 'open-uri'
["PHP"].each do |language|
  [	  #"Shanghai",
	  #"Beijing",
	  "Shenzhen","Guangzhou",
	  "Hangzhou", "Chengdu",
	  "Nanjing","Xiamen",
	  "Wuhan","Dalian","Hefei","Fuzhou","Dongguan",
	  "Suzhou","Wuxi","Qingdao","Chongqin"].each do |location|
    url1 = "https://github.com/search?utf8=%E2%9C%93&q=language%3A#{language}+location%3A#{location}&type=Users&ref=searchresults"
    doc1 = Nokogiri::HTML(open(url1))
    if doc1.css(".pagination").css(".gap").empty?
      pages=doc1.css(".pagination").css("a").size
      puts "gap为空"
    else
      pages=doc1.css(".pagination").css("a")[5].text.to_i
      puts "gap拥有"
    end
    puts "#{location} #{pages}页"
    (1..pages).each do |_id|
      puts "输出第#{_id}页"
      url = "https://github.com/search?l=#{language}&p=#{_id}&q=language%3A#{language}+location%3A#{location}&ref=advsearch&type=Users&utf8=%E2%9C%93"
      doc = Nokogiri::HTML(open(url))
	doc.css(".user-list-info").each do |item|
	  user_name = item.css("a").first.text
	  url_profile = "https://github.com/#{user_name}"
	  profile = Nokogiri::HTML(open(url_profile))
	  if profile.css(".vcard-details").present?
	    if profile.css(".octicon-organization").present? 
	      employer = profile.css(".vcard-detail").first.text unless profile.css(".vcard-detail").nil?
	    end
	    followers = profile.css(".vcard-stat-count").first.text unless profile.css(".vcard-stat-count").nil?
	    join_year = profile.css(".join-date").text.to_date.strftime("%Y").to_i unless profile.css(".join-date").nil?
	    today = Date.today.strftime("%Y").to_i
	    year = today-join_year
	  end
          if item.css("a").last.text =~/\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/
	    email_text = item.css("a").last.text
	    Candidate.create(user_id:10000,followers:followers,year:year,employer:employer,name:item.text.split.second,
			     title:(language=="C%23" ? "C#" : "#{language}"),email:email_text,city:location)
	  end
	  sleep 5
        end
      sleep 5
    end
  end
end

