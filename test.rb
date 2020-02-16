require 'watir'
require 'webdrivers'
require 'faker'
require 'nokogiri'

class MinesweeperTest
	@browser
	def self.open
		@browser = Watir::Browser.new :chrome
		@browser.goto "minesweeperonline.com"	
		#data=@browser.html
		#parsed=Nokogiri::HTML(data)
		#puts parsed.css("div#game")


		#	@browser.wait 1000
	end

#trash, dont use those two
	def self.scan
		field={}
		16.times do |y|
			field[y+1]={}
			30.times do |x|
				field[y+1][x+1]=self.represent(@browser.div(id:"#{y}_#{x}").attribute_value("class"))

			end
		end
return field
	end


	def self.parse_html 
	field={}
	data=@browser.html
	parsed=Nokogiri::HTML(data)
		16.times do |y|
			field[y+1]={}
			30.times do |x|
				field[y+1][x+1]=self.represent(parsed.css("div##{y}_#{x}")[0]["class"])
			
			end
		end
return field
	end	


#best thus far, need scope improvements, regex checking should start at line X(constant) and loop should end after 16 30
	def self.parse_game_field
	field={}
	data=@browser.html
	parsed=Nokogiri::HTML(data).css("div#game")
		parsed.to_s.each_line do |line|
			#<div class="square blank" id="12_16"></div>
			if line =~ /<div class="square ([a-z|0-9| ]*)" id="([0-9]*)_([0-9]*)"><[\/]div>/
 			field[$2.to_i]={} if ($3=="1")
 			field[$2.to_i][$3.to_i]=represent($1) 
			end
		end
	return field

	end


	def self.represent value
		#puts value
		case value
		when /blank/	 
			return -1
		when /open([0-9])/ 
			return ($1).to_i	
		when /flagged/
			return -2
	end
	end
	def self.print_field field
		16.times do |y|
			30.times do |x|
					#print "(#{x},#{y})"
					print " #{field[y+1][x+1]} "
				end
				puts
			end
	end
end
MinesweeperTest.open	
starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
field =  MinesweeperTest.parse_game_field
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting
puts elapsed

#puts field
#puts field[16][30]
MinesweeperTest.print_field field
#puts "done xd "
#puts MinesweeperTest.represent(ARGV[0])