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
				next if val<1
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
						 	#puts "Oppening #{z},#{c} cause of #{y+1},#{x+1} val=#{val} nb=#{nb} flagged=#{flagged}"
							#@field[z][c]=-69
						 end

					end


				end
				if (val-flagged)==nb 
					next if nb==0
					adj.each do |z,c,v|
					 if v==-1 and !right_click.include? [z,c]
							right_click << [z,c]
						 	self.right_click(z,c)
						 	#puts "Flagging #{z},#{c} cause of #{y+1},#{x+1}  val=#{val} nb=#{nb} flagged=#{flagged}"
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
	def self.get_adj_4(row,column)
			adjacents=[]
			adjacents << [row+1,column] if row<16
			adjacents << [row-1,column] if row>1
			adjacents << [row,column+1] if column<30
			adjacents << [row,column-1] if column>1
			return adjacents
	end
	def self.get_clickable_fields(row,column)
		adj = get_adjacent(row,column)
		clickable = adj.reject{|z,c| @field[z][c]!=-1}
		return clickable
	end
	def self.count_flags(row,column)
			adj = get_adjacent(row,column)
			flags = adj.reject{|z,c| @field[z][c]!=-2}
			return flags.size

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
	def self.heuristic
		16.times do |y|
			30.times do |x|
				 val=@field[y+1][x+1] 
				 #puts "#{y+1},#{x+1}(#{val})"
				 next if val<1
				 clickable = get_clickable_fields(y+1,x+1)
				 flags_nr=self.count_flags(y+1,x+1)
				 next if clickable.empty?
				 adj4 = get_adj_4(y+1,x+1)
				 adj4.each do |z,c|
				 	val_adj4=@field[z][c]
				 	next if val_adj4<1
				 	#next if val_adj4>val
				 	clickable_adj4=get_clickable_fields(z,c)
				 	flags_nr4=self.count_flags(z,c)
				 	diff=clickable-clickable_adj4
				 	puts "y=#{y+1},x=#{x+1}(#{val}),r=#{z},c=#{c}(#{val_adj4}), clickable=#{clickable.inspect},clickable_adj4=#{clickable_adj4.inspect},dif=#{diff.inspect}"
		
				 	if diff.size==(val-flags_nr-val_adj4+flags_nr4) and diff.size!=0
				 		diff.each do |t,m| 
				 			puts "Rc #{t},#{m}"
				 			self.right_click(t,m) 
				 		end
				 	return 1
				 	elsif val-flags_nr==val_adj4-flags_nr4 and diff.size!=0 and (clickable_adj4-clickable).size==0
				 		diff.each do |t,m|
				 			puts "Lc #{t},#{m}"
				 			self.click(t,m)
				 		end
				 	return 1
				 	end
				 end
			end
		end
		return nil
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
		 if lc.empty? and rc.empty?
		 	puts "xd"
		 	v=self.heuristic
		 	#self.click(rand(16)+1, rand(30)+1) if v.nil?
		 end
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
	rescue 	NoMethodError=>e
		#sleep(9999)
		puts "Retry?(y/n)"
		if gets.chomp=="y"
			retry
		else
			exit
		end

	rescue Selenium::WebDriver::Error::UnhandledAlertError
		puts "Retry?(y/n)"
		if gets.chomp=="y"
			retry
		else
			exit
		end
 		
	rescue StandardError=>e
		puts "#{e.inspect}"
		retry
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

