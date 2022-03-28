class UsersController < ApplicationController
    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            flash[:notice] = "#{@user.username} welcome to Overwatch"
            redirect_to root_path
        else
            render 'new'
        end
        
    end

    def edit
        @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])

        if @user.update(user_params)
            flash[:notice] = "User #{@user.username} was updated successfully"
            redirect_to @host
       else
          render 'edit'
       end

    end

    def index
        @users = User.all
    end

    def show
        @user = User.find(params[:id])
    end

    private

    def user_params
        params.require(:user).permit(:username, :emails, :password)
    end
end
