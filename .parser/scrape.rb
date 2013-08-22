#!/usr/bin/env ruby
# Scrape data from Wufoo survey.
# See https://help.github.com/articles/remove-sensitive-data !!!

require 'wuparty'
require 'fileutils'

def get_api_key
  key = ""

  File.open("api_key.txt", "r").each_line do |line|
    key = line
  end

  key
end

ACCOUNT = 'flatironschool'
FORM_ID = 'ruby-002-student-profile-survey'

def scraper

  names = []

  api_key = get_api_key

  if api_key == ""
    print "\nNo API key set. Please run `./parse.sh api [key]`.\n"
    return 0
  elsif api_key.length != 19
    print "\nAPI key is invalid.\n"
    return 0
  end

  wufoo = WuParty.new(ACCOUNT, api_key)
  form = wufoo.form(FORM_ID)

  FileUtils.mv('bak/sps.txt', 'bak/sps.txt.bak')

  File.open("bak/sps.txt", "w") do |sps|

    form.entries(:limit => 1000).each do |student|
      count = 0
      txt = ""
      name = []

      student.each do |field|

        count += 1
        if count == 2 or count == 3
          name << field[1]
        end

        txt << ("%s\t" % (field[1].inspect)[1..-2]) if count < 22

      end

      names << name


      # for profile_looper in name
      #   Page_Titles << profile_looper.to_s
      # end
      # Page_Titles << "_profile\n"
      # for resume_looper in name
      #   Page_Titles << resume_looper.to_s
      # end
      # Page_Titles << "_resume\n"


      txt << "\n"
      sps.write(txt)

    end

    names = names.uniq
    names.sort!

    # Refactor this bit #
    for student_name in names
      item = ""

      for part in student_name
        item << part
      end

      Page_Titles << "#{item}_profile/index.html\n#{item}_resume/index.html\n"
    end
    #####################

    File.open("pdf_page_names.txt", "w") { |file|
      file.write(Page_Titles)
    }

    id = 1

    for student in names
      Student_IDs[student] = id
      id += 1
    end

    # Has the file closed?..
  end

#  sps.close # ^ ?

end
