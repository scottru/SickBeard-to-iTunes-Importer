sb_lib = "/Volumes/500GB/Sick\\ Beard"
it_lib = "/Volumes/2TB/iTunes"
pathToHB = "/Applications/"
outPath = "/Users/zach/Movies/"
preset = "AppleTV 2"
options = ""
nice = "/usr/bin/nice -n 19"

def get_filename(path)
    path.split("/").last.gsub(/\.(mkv|avi|wmv)$/,"").chomp
end

def create_show_details(filename)
    filename.split(" - ")
end

def get_show_name(info)
    info.first.gsub(/\W/, " ")
end

def get_title(info)
  info.last
end

def get_season_number(info)
    if info[1] =~ /\./
       info[1].split(".").first
    else
        info[1].split("x").first
    end
end

def get_episode_number(info)
    if info[1] =~ /\./
      parts = info[1].split(".")
      "#{parts[1]}#{parts[2]}"
    else
      info[1].split("x").last
    end
end

def get_itunes_title(info)
    "#{get_season_number(info)}x#{get_episode_number(info)} #{get_title(info)}"
end

while 1 == 1

  file_list = Array.new

  `find #{sb_lib} -iname *\.mkv -o -iname *\.avi -o -iname *\.wmv`.each do |f|
    filename = get_filename(f)
    info = create_show_details(filename)
    results = `find #{it_lib} -iname "*#{get_itunes_title(info)}\.m4v"`.chomp

    if results.size == 0
       file_list.push(f.chomp)
    end
  end

  file_list.each do |inPath|
      filename = get_filename(inPath)
      outPathWName = outPath + filename.gsub(/\W/,"_") + ".m4v"
      inPath.chomp!
      system "#{nice} #{pathToHB}HandBrakeCLI -i \"#{inPath}\" -o \"#{outPathWName}\" --preset=\"#{preset}\" #{options}"
      outPathWName.gsub!(/\'/,"\\'")
      track_id = `/usr/bin/osascript -e 'tell application \"iTunes\" to add POSIX file \"#{outPathWName}\"'`.chomp.split(" ")[3]
      info = create_show_details(filename)
      system "/usr/bin/osascript -e 'tell application \"iTunes\" to set name of track id #{track_id} to \"#{get_itunes_title(info)}\"'"
      system "/usr/bin/osascript -e 'tell application \"iTunes\" to set video kind of track id #{track_id} to tv show'"
      system "/usr/bin/osascript -e 'tell application \"iTunes\" to set season number of track id #{track_id} to #{get_season_number(info)}'"
      system "/usr/bin/osascript -e 'tell application \"iTunes\" to set episode number of track id #{track_id} to #{get_episode_number(info)}'"
      system "/usr/bin/osascript -e 'tell application \"iTunes\" to set show of track id #{track_id} to \"#{get_show_name(info)}\"'"
      sleep 10
      if track_id.to_i > 0
        File.delete(outPathWName)
      end
  end

  end_time = Time.new.strftime("%m/%d %H:%M")
  if file_list.size == 0
     puts "\n\n*** [#{end_time}] No jobs to process, sleeping for an hour\n\n"
     sleep 3600
  else
     puts "\n\n*** [#{end_time}] Done with work, sleeping a half hour\n\n"
     sleep 1800
  end
end


