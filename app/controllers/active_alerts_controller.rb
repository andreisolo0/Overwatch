class ActiveAlertsController < ApplicationController
    def show
        
    end

    def index
        @active_alerts = ActiveAlert.all
    end
    
    def create
        #No longer needed because we have 'before_action' @article = Article.new(article_params)
    
        @article = Article.new(article_params)
        @article.user = User.first
        if @article.save 
            flash[:notice] = "Article was created successfully"
            redirect_to @article
       else
          render 'new'
       end
    end
end