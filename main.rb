require 'sinatra'

require 'yaml'
require 'json'

require 'digest'
require 'digest/md5'

require 'pivotal-tracker'

puts "Please specify your Pivotal account email and password through env as PIVOTAL_EMAIL and PIVOTAL_PASSWORD. E.g.: \n\tPIVOTAL_EMAIL=user@example.com PIVOTAL_PASSWORD=example ruby main.rb" if ENV['PIVOTAL_EMAIL'].nil? or ENV['PIVOTAL_PASSWORD'].nil?

puts "Connecting to Pivotal tracker with email '#{ENV['PIVOTAL_EMAIL']}' and password '#{ENV['PIVOTAL_PASSWORD']}'"

PivotalTracker::Client.token(ENV['PIVOTAL_EMAIL'], ENV['PIVOTAL_PASSWORD'])

get '/' do

	all_projects = PivotalTracker::Project.all

	people = all_projects.collect {|p| p.memberships.all.collect {|m| { :name => m.name, :email => m.email } } }.flatten.uniq + [{:name => "Unassigned", :email => ""},]

	tasks = Hash[people.collect {|p| [p[:name], {:current => {}, :backlog => {}, :unscheduled => {} }]}]

	all_projects.each do |project|
		PivotalTracker::Iteration.current(project).stories.group_by(&:owned_by).each do |name, iter_tasks|
			name ||= "Unassigned"
			tasks[name][:current][project.name] = iter_tasks unless name.nil?
		end

		PivotalTracker::Iteration.backlog(project).collect {|i| i.stories.group_by(&:owned_by) }.each do |subiter|
			subiter.each do |name, iter_tasks|
				name ||= "Unassigned"
				tasks[name][:backlog][project.name] = iter_tasks unless name.nil?
			end
		end

		PivotalTracker::Project.find(project.id).stories.find(:all, {:state => 'unscheduled'}).group_by(&:owned_by).each do |name, iter_tasks|
			name ||= "Unassigned"
			tasks[name][:unscheduled][project.name] = iter_tasks unless name.nil?
		end
	end

  erb :index, :locals => {:people => people, :tasks => tasks}
end

get '/projects' do
  projects = PivotalTracker::Project.all
  
  erb :projects, 
    :content_type => "text/javascript", 
    :layout => false,
    :locals => {
      :projects => projects
    }
end
