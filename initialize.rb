require 'mechanize'
require 'data_mapper'
require 'hashie'
require 'json'
require 'log4r'

requires = ['model_logging', 'models', 'reddit_wrap', ]
requires.each do |r|
  require File.join(File.dirname(__FILE__), (r + '.rb') )
end

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/rrbot.sqlite")
DataMapper.auto_upgrade!

def modbot_config
  h = Hashie::Mash.new
  h.user_name = ''
  h.user_password = ''
  h
end

#preconfigure 1 subreddit and conditions for testing, better method to do this later
def modbot_models
  h = Hashie::Mash.new
  h.subreddits = [ ["", 5, 5] ]
  h.rconditions = [  [:comment, :author, :contains, "", :remove],  
                     [:comment, :body, :contains, "", :remove],
                     [:comment, :min_comment_karma, :is_less_than, 100, :remove],
                     [:submitted_link, :author, :contains, "", :remove],
                     [:submitted_link, :title, :contains, "", :remove],
                     [:submitted_link, :url, :contains, "", :remove],
                     [:submitted_link, :min_comment_karma, :is_less_than, 100, :remove],
                     [:submitted_link, :min_account_age, :contains, 365, :remove],
                     [:submitted_link, :author, :is, "", :remove]
                  ]
  h
end

if Subreddit.any?
else
  modbot_models.subreddits.each do |x|
    Subreddit.create(:name => x[0], :report_threshold => x[1], :spam_threshold => x[2] )
  end
  #y = Subreddit.first
  #modbot_models.rconditions.each do |z|
  #  y.rconditions.create   
end
