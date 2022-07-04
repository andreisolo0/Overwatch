class ItemsController < ApplicationController
    before_action :require_user
    before_action :set_item, only: %i[ show edit update destroy ]
    before_action :permit_edit_admin, only: [:edit, :update, :destroy]
    
    def new
        @item = Item.new
    end

    def create
        @item = Item.new(item_params)
        if @item.save
            flash[:notice] = "#{@item.item_name} created"
            redirect_to items_path
        else
            render 'new'
        end
        
    end

    def edit
    
    end

    def update
        if @item.update(item_params)
            flash[:notice] = "Item #{@item.item_name} was updated successfully"
            redirect_to @item
       else
          render 'edit'
       end
    end

    def index
        @items = Item.paginate(page: params[:page], per_page: 25)
    end


    def show
        
    end
    
    def unassign_items
        Host.all.each do |x| 
            HostItem.destroy_by(host_id: x.id, item_id: params[:id])
            assigned_now = x.assigned_items_host
            assigned_now.delete(params[:id].to_i)
            Host.find(x.id).update(assigned_items_host: assigned_now)
            
            scheduler_data = YAML.load(File.open(Rails.root.join('config', 'sidekiq_scheduler.yml')))
            job_name="job_for_item_"+ params[:id].to_s+"_on_host_"+x.id.to_s
            if scheduler_data.include?(job_name)
                scheduler_data.delete(job_name)
                File.open(Rails.root.join('config', 'sidekiq_scheduler.yml'), 'w') do |f|
                    f.write(YAML.dump(scheduler_data))
                end
            end
        end
        flash[:notice]="Item was unassigned from all hosts"
        redirect_to items_path
    end
    
    def destroy
        if(HostItem.where(item_id: @item.id).count > 0)
            flash[:alert]= "Item #{@item.item_name} is assigned to a host and cannot be deleted"
        else
            @item.destroy
        end
        redirect_to items_path
      end
    
    
    private
    def item_params
        params.require(:item).permit( :item_name, :interval_to_read, :command_to_read, :description)
    end
    def set_item
        @item = Item.find(params[:id])
    end

    def permit_edit_admin
        if current_user.admin != true
            flash[:alert] = "You don't have rights to modify this item"
            redirect_to items_path
        end
    end

end