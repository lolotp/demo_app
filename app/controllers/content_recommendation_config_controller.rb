class ContentRecommendationConfigController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user

  def index
    @friend_notification_limit = REDIS_WORKER.get('FRIEND_COUNT_SEND_NOTIFICATION_LIMIT')
    @follow_notification_limit = REDIS_WORKER.get('FOLLOW_COUNT_SEND_NOTIFICATION_LIMIT')
    if (@friend_notification_limit == nil or not ((@friend_notification_limit =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/) != nil))
      @friend_notification_limit = 1000000000
    end
    if (@follow_notification_limit == nil or not ((@follow_notification_limit =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/) != nil))
      @follow_notification_limit = 1000000000
    end
  end

  def create
    new_friend_limit = params[:FRIEND_COUNT_SEND_NOTIFICATION_LIMIT]
    new_follow_limit = params[:FOLLOW_COUNT_SEND_NOTIFICATION_LIMIT]
    if (new_friend_limit =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/) != nil
      REDIS_WORKER.set('FRIEND_COUNT_SEND_NOTIFICATION_LIMIT', new_friend_limit)
    end
    if (new_follow_limit =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/) != nil
      REDIS_WORKER.set('FOLLOW_COUNT_SEND_NOTIFICATION_LIMIT', new_follow_limit)
    end
    redirect_to '/content_recommendation_config'
  end

end
