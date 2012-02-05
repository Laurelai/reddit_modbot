#ad hoc reddit api wrapper

#something more extensive to pull up all routes needed from simple cues
#def reddit_route(route)
#  case route
#  when "c_user"
#  when
#  when
#  when
#  when
#  end
#end

#http://www.reddit.com/user/#{USER_NAME}/about/.json
def get_current_user
  h = Hashie::Mash.new
  x = @r.get 'http://www.reddit.com/user/' +  modbot_config.user_name + '/about/.json'
  x = JSON.parse(x.body)
  h.user_name = x['data']['name']
  h.uh = x['data']['modhash']
  h 
end

#https://ssl.reddit.com/api/login/
def login
  @r.post 'https://ssl.reddit.com/api/login/' + modbot_config.user_name, 
          'passwd' => modbot_config.user_password,
          'user' =>  modbot_config.user_name, #appears required not redundant
          'type' => 'json'
end

#http://www.reddit.com/r/#{SUBREDDIT}/about/reports/.json
def get_reddit_reports(reddit_name)
  route = 'http://www.reddit.com/r/' + reddit_name + '/about/reports/.json'
  q_parse(route, "none")
end

#http://www.reddit.com/r/#{SUBREDDIT}/about/spam/.json
def get_reddit_spams(reddit_name, limit = 5)
  route = 'http://www.reddit.com/r/'+ reddit_name + '/about/spam/.json'
  q_parse(route, limit)
end

#http://www.reddit.com/user/#{USER_NAME}/about/.json
def reddit_user(name)
  x = @r.get 'http://www.reddit.com/user/' + name + '/about.json'
  x = JSON.parse(x.body)
  y = [] 
  y << x['data']['name']
  y << x['data']['created']
  y << user_age( x['data']['created'] )
  y << x['data']['link_karma']
  y << x['data']['comment_karma']
  y << (x['data']['link_karma'].to_f / x['data']['comment_karma'].to_f).round(3)
  y
end

#http://www.reddit.com/api/approve
def approve(id)
  @r.post 'http://www.reddit.com/api/approve', 
          'id' => id , 
          'uh' => @current_user.uh,
          'api_type' => 'json'
end

#http://www.reddit.com/remove
def remove(id)
  @r.post 'http://www.reddit.com/api/remove', 
          'id' => id , 
          'uh' => @current_user.uh,
          'api_type' => 'json'
end

#misc utility methods
def q_parse(route, limit)
  if limit == "none" 
    x = @r.get route
  else 
    x = @r.get route, 'limit' => limit
  end
  y = JSON.parse(x.body)['data']['children']
  z = []
  if y.empty?
    z << "Nothing!"
  else
    y.each do |yy|
      h = Hashie::Mash.new
      h.id = yy['data']['id']
      h.fullid = yy['data']['name']
      h.author = reddit_user(yy['data']['author'])
      if yy['kind'] == "t1"
        h.kind = "comment"
        h.comment = yy['data']['body']
      elsif yy['kind'] == "t3"
        h.kind = "submitted_link"
        h.title = yy['data']['title']
        h.is_self = yy['data']['is_self']
        h.selftext = yy['data']['selftext']
        h.url = yy['data']['url']
      else
        h.kind = "wtf, something not a link or comment" 
      end
      z << h
    end
  end
  z
end

def user_age_to_readable(from_when)
  user_age(from_when).to_s + " days"
end

def user_age(from_when)
  (((( ( Time.at(Time.now) - Time.at(from_when) )/ 60 )/ 60)/ 24).to_i)
end
