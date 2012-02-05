require 'rubygems'
require File.join(File.dirname(__FILE__), 'initialize.rb')
DataMapper::Logger.new($stdout, :debug)

#log actions

#Performs the specified action
def perform_action(action, item)
  if action == :approve
    approve(item.fullid)
  elsif action == :remove
    remove(item.fullid)
  elsif action == :alert
      #perform_alert() check condition alert params and proceed
  else
    #something isn't cool, pass or error 
  end
end

#def perform_alert()
#end

#Checks reported items for any matching conditions.
def check_reports(subreddit, conditions)
  reports = get_reddit_reports(subreddit)
  #check_report_alerts(subreddit, "report", reports.count)
  reports.each do |i|
    check_conditions(conditions, i)  
  end
end

#Checks new items on the /about/spam page for any matching conditions.
#def check_new_spam(subreddit, conditions)
  #compare time of first instance to recorded time of last check 
  #spams = get_reddit_spams(subreddit)
  #check_report_alerts(subreddit, "spam", spams.count)
  #spams.each do |sp|
  #  check_conditions(conditions, sp)
  #end
#end

#Checks for items with more reports than the subreddit's threshold.
#def check_alerts(subreddit, alert, count)
#  case alert
#  when "report"
#    if subreddit.report_threshhold <= rc
#      perform_alert()
#    end
#  when "spam"
    #if subreddit
#  else
#  end
#end

#Checks new items on the /new page for any matching conditions.
#def check_new_submissions(name)
#end

#Checks an item against a set of conditions.
#Returns True if a condition matches, or False if none match.
#action_types restricts checked conditions to particular action(s).
#Setting perform to False will check, but not actually perform if matched.
def check_conditions(conditions, item)
  if item.kind == "submitted_link"
    conditions = conditions.all(:subject => :submitted_link)
  elsif item.kind == "comment"
    conditions = conditions.all(:subject => :comment)
  else
    conditions = []
  end
  #puts "CONDITIONS CHECKED"
  #puts conditions.inspect
  conditions.each do |c| #unless conditions.empty? 
    check_condition(c, item)
  end
end

#Checks an item against a single condition (and sub-conditions).
#Returns the condition's ID if it matches.
def check_condition(condition, item)
  case condition.rc_attribute
  when :author
    i = item.author[0]
  when :title
    i = item.title
  when :body
    i = item.body
  when :domain
    i = URI(item.url).host
  when :url
    i = URI(item.url)
  when :self_post
    i = item.is_self
  when :min_account_age
    i = item.author[2]
  when :min_link_karma
    i = item.author[3]
  when :min_comment_karma
    i = item.author[4]
  when :min_combined_karma
    i = (item.author[3] + item.author[4])
   end
  result = condition.test_condition(i)
  if result
    #puts condition.inspect
    perform_action(condition.rc_action, item)
  else
    #log action false or just pass
  end
  #log_action(condition, item)
end  

#main
# get this in an intialization # log
@r ||= Mechanize.new{ |agent| agent.user_agent_alias = 'Mac Safari' }
login
@current_user ||= get_current_user

# do this on a regular basis # log

#perhaps vary this by timer as well...running only by certain time per subbreddit
subreddits = Subreddit.all(:enabled => true)
subreddits.each do |s|
  # log doing for s
  ss = s.rconditions
  if ss.empty?
    puts "no conditions for reddit " + s.name + " defined"#log
  else 
    check_reports(s.name, ss) # log
    #check_new_spam(s.name, s.last_spam, sconditions) #log
    #check_new_submissions(s.name, conditions) #log
  end
end

#class ModBot....listen to pubsub or perform regular, maybe both for specific acts 

  #def initialize
    #@r ||= Mechanize.new{ |agent| agent.user_agent_alias = 'Mac Safari' }
    #login
    #@current_user ||= get_current_user
  #end

  #def perform_scheduled
  #end

  #def listen
  #end

  #def respond
  #end

#end
