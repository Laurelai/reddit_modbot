class Subreddit
  include DataMapper::Resource
  include ModelLogging

  has n, :rconditions
  #has n, :action_logs

  property :id, Serial                 
  property :name, String               
  property :enabled, Boolean, :default => true           
  property :last_submission, DateTime  
  property :last_spam, DateTime        
  property :report_threshold, Integer
  property :spam_threshold, Integer

  #post create hook to create intial log entry
  #def set_log 
  #end
  
end

class Rcondition
  include DataMapper::Resource
  
  belongs_to :subreddit

  property :id, Serial
  property :title, String
  property :subject, Enum[:submitted_link, :comment], :default => :comment
  property :rc_attribute, Enum[:author,
                               :title, 
                               :domain,
                               :url,
                               :body,
                               :self_post,
                               :min_account_age,
                               :min_link_karma,
                               :min_comment_karma,
                               :min_combined_karma], :default => :author
  property :rc_query, Enum[:contains,
                           :does_not_contain,
                           :is,#equals
                           :is_greater_than,
                           :is_less_than], :default => :contains
  #property :rc_modifier, Enum[:any,
  #                            :all]
  property :rc_text_value, Text
  property :rc_integer_value, Integer
  property :rc_action, Enum[:approve, :remove, :alert], :default => :approve
  property :rc_regex, Regexp#post create hook, create regex, use == 1 db call, possibly

  after :create do
    if self.rc_query == :contains
      self.rc_regex = "placeholder contains" # process self.rc_text_value as regex
    elsif self.rc_query == :does_not_contain
      self.rc_regex = "placeholder does not contain" # process self.rc_text_value as regex
    else
    end 
  end

  def gist
    a = []
    a << self.subject
    a << self.rc_attribute
    a << self.rc_query
    self.rc_text_value.nil? ? a << self.rc_integer_value : a << self.rc_text_value
    a << self.rc_action 
  end
 
  #return true or false
  def test_condition(i)
    case self.rc_query
    when (:contains || :is)
       #i =~ #self.rc_regex
    when :does_not_contain
       #i =~ #self.rc_regex
    when :is_greater_than
       i > self.rc_integer_value
    when :is_less_than
       i < self.rc_integer_value 
    when :equals
       i == self.rc_integer_value
    else
       false 
    end
  end 

  #after create hooks
  #def set_rc_query
  #end

end

#class ActionLog
#  include DataMapper::Resource
#  belongs_to :subreddit
#   
#  property :id, Serial
#  property :title, Text
#  property :user, String
#  property :url, String
#  property :domain, String
#  property :permalink, String
#  property :created_utc, DateTime
#  property :action_time, DateTime
# property :action, Enum[:approve, :remove, :alert], :default => :approve
#end

DataMapper.finalize
