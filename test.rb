require 'watir'
require 'webdrivers'
require 'faker'
require 'nokogiri'

class MinesweeperTest
	@browser
	@field
	def self.open
		chromedriver_path =File.path("/home/fmaster/.rvm/gems/ruby-2.4.4/bin/chromedriver.exe")
		puts chromedriver_path
		Selenium::WebDriver::Chrome.driver_path = chromedriver_path
		@browser = Watir::Browser.new :chrome
		@browser.goto "minesweeperonline.com"	
		#data=@browser.html
		#parsed=Nokogiri::HTML(data)
		#puts parsed.css("div#game")


		#	@browser.wait 1000
	end
	def self.close 
			@browser.close
	end
	def self.restart
			@browser.div(id:"face").click
	end
	def self.click (row, column)
		@browser.div(id:"#{row}_#{column}").click
	end
	
	def self.right_click (row, column)
		@browser.div(id:"#{row}_#{column}").right_click
	end
#trash, dont use those two
	


#best thus far, need scope improvements, regex checking should start at line X(constant) and loop should end after 16 30
	def self.parse_game_field
	@field={}
	data=@browser.html
	parsed=Nokogiri::HTML(data).css("div#game")
		parsed.to_s.each_line do |line|
			#<div class="square blank" id="12_16"></div>
			if line =~ /<div class="square ([a-z|0-9| ]*)" id="([0-9]*)_([0-9]*)"><[\/]div>/
 			@field[$2.to_i]={} if ($3=="1")
 			@field[$2.to_i][$3.to_i]=represent($1) 
			end
		end

	end

	def self.algorithm
		right_click=[]
		left_click=[]
		16.times do |y|
			30.times do |x|
				val=@field[y+1][x+1] 
				next if val==0 or val==-1 or val==-2
				ad=get_adjacent(y+1,x+1)
				adj=[]
				flagged=0
				nb=0 #blank fields
				ad.each do |z,c|
					v=@field[z][c]
					adj << [z,c,v]
					nb+=1 if v==-1
					flagged+=1 if v==-2
				end

				if val==flagged
					next if nb==0
					adj.each do |z,c,v|
						 if v==-1 and !left_click.include? [z,c]
							left_click << [z,c]
						 	self.click(z,c)
						 	puts "Oppening #{z},#{c} cause of #{y+1},#{x+1} val=#{val} nb=#{nb} flagged=#{flagged}"
							@field[z][c]=-69
						 end

					end


				end
				if (val-flagged)==nb 
					next if nb==0
					adj.each do |z,c,v|
					 if v==-1 and !right_click.include? [z,c]
							right_click << [z,c]
						 	self.right_click(z,c)
						 	puts "Flagging #{z},#{c} cause of #{y+1},#{x+1}  val=#{val} nb=#{nb} flagged=#{flagged}"
						 	@field[z][c]=-2
						 end
					end
					
				end

			end
		end
		#puts left_click
		#puts right_click
		return left_click,right_click
	end
	
	def self.get_adjacent(row,column)
		adjacents=[]
		rows=[]
		columns=[]

		rows << row
		columns << column
		rows << row-1 if row > 1
		rows << row+1 if row < 16

		columns << column-1 if column > 1
		columns << column+1 if column <30

		#puts rows
		#puts columns
		adjacents = rows.product columns
		#puts adjacents
		adjacents.shift
		return adjacents
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
	def self.print_field
		16.times do |y|
			30.times do |x|
					#print "(#{x},#{y})"
					print @field[y+1][x+1].to_s.rjust(3)
				end
				puts
			end
	end
	
	def self.game
		begin
		self.restart
		self.click 1,10
		while (true)
		self.parse_game_field

		lc=[]
		rc=[]
		lc,rc = self.algorithm
		#puts "lc"+lc.inspect
		#puts "rc"+rc.inspect
		#self.click(rand(16)+1, rand(30)+1) if lc.empty? and rc.empty?
=begin
		if !lc.empty?
			lc.each do |y,x|
				self.click y,x
			end
		end	
		if !rc.empty?
			rc.each do |y,x|
				self.right_click y,x
			end
		end
=end
			#self.print_field
			puts "x"*3*16
		end

			sleep(9999)

		end
	rescue StandardError=>e
		puts "#{e.inspect}"
		retry
	rescue Selenium::WebDriver::Error::UnhandledAlertError
		sleep(9999)
		end
	end
=begin
MinesweeperTest.open	
MinesweeperTest.click 1,10
#starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
MinesweeperTest.parse_game_field
#ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
#elapsed = ending - starting
#puts elapsed

MinesweeperTest.print_field
sleep(10)
MinesweeperTest.close
=end
MinesweeperTest.open
MinesweeperTest.game

