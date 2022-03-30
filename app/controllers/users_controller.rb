class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :require_user, only: [:show, :edit, :update]
    before_action :require_same_user, only: [:edit, :update]


    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        
        @user.viewer = true
        @user.regular_user = false
        @user.admin = false
        

        if @user.save
            if session[:user_id] == nil
                # check if session exists when creating new and if exists do no switch to a session for that user
                session[:user_id] = @user.id
                flash[:notice] = "#{@user.username} welcome to Overwatch"
                #redirect_to dashboard_path
                redirect_to users_path
            else
                flash[:notice] = "User #{@user.username} created successfully!!"
                redirect_to users_path
            end
        else
            render 'new'
        end
        
    end

    def edit
        #@user = User.find(params[:id])
    end

    def update
        #@user = User.find(params[:id])

        if @user.update(user_params)
            flash[:notice] = "User #{@user.username} was updated successfully"
            redirect_to @user
       else
          render 'edit'
       end

    end

    def index
        #@users = User.all
        @users = User.paginate(page: params[:page], per_page: 3)
    end

    def show
        #@user = User.find(params[:id])
    end

    def destroy
        #@user = User.find(params[:id])
        username=@user.username
        username_id=@user.id
        #Get admin_id to assign orphaned hosts before deletion
        admin_id=User.find_by(username: 'admin').id
        Host.where(user_id: username_id).update_all(user_id: admin_id)
        
        @user.destroy
        #to ensure session is destroyed too
        if session[:user_id] == @user.id
            session[:user_id] = nil
            redirect_to root_path
       else
            flash[:notice] = "User "+ username +" was deleted succesfully!"
            redirect_to users_path
       end
    end

    private

    def user_params
        params.require(:user).permit(:username, :email, :password, :first_name, :last_name, :regular_user, :admin, :viewer)
    end
    def set_user
        @user = User.find(params[:id])
    end
    def require_same_user
        if current_user != @user
            flash[:alert] = "You can only edit your own account"
            redirect_to @user
        end
    end
    
    

end
