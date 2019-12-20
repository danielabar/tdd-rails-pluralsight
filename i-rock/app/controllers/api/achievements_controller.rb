module Api
  class AchievementsController < ApiController
    def index
      p request.headers['Content-Type']
      achievements = Achievement.public_access
      # temp debug
      achievements.each do |a|
        puts "id = #{a.id}, title = #{a.title}"
      end
      render json: achievements
    end
  end
end
