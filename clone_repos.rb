#!/usr/bin/ruby

# Author: Mike Helmick - mike.helmick@uc.edu
# Clones all student repositories for a particular assignment
#
# Currently this will clone all student repositories into the current 

$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'highline/question'
require 'highline/import'
require 'highline/compatibility'
require 'octokit'
require 'github_common'

class CloneRepos < GithubCommon

  def initialize()
  end

  def read_info()
    @repository = ask('What repository name should be cloned for each student?') { |q| q.validate = /\w+/ }
    @organization = ask("What is the organization name?") { |q| q.default = 'CS2-Fall2013' }
    @student_file = ask('What is the name of the list of student IDs') { |q| q.default = 'students' }
  end

  def load_files()
    @students = read_file(@student_file, 'Students')
  end

  def create
    confirm("Clone all repositories?")
    
    # create a repo for each student
    init_client()

    org_hash = read_organization(@organization)
    abort('Organization could not be found') if org_hash.nil?
    puts "Found organization at: #{org_hash[:url]}"

    # Load the teams - there should be one team per student.
    org_teams = get_teams_by_name(@organization)
    # For each student - pull the repository if it exists
    puts "\nCloning assignment repositories for students..."
    @students.keys.each do |student|
      unless org_teams.key?(student)
        puts("  ** ERROR ** - no team for #{student}")
        next
      end
      repo_name = "#{student}-#{@repository}"
      
      unless repository?(@organization, repo_name)
        puts " ** ERROR ** - Can't find expected repository '#{repo_name}'"
        next
      end
      
      puts " --> Cloning '#{repo_name}'"
      `git clone #{@web_endpoint}#{@organization}/#{repo_name}.git`
    end
  end
end

cloner = CloneRepos.new
cloner.read_info()
cloner.load_files()
cloner.create()

