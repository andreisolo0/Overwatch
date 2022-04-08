class ItemsController < ApplicationController
    before_action :require_user
    before_action :set_item, only: %i[ show edit update destroy ]
    
    
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

    
    def destroy    
        @item.destroy
        redirect_to items_path
      end
    

    private
    def item_params
        params.require(:item).permit( :item_name, :interval_to_read, :command_to_read, :description)
    end
    def set_item
        @item = Item.find(params[:id])
    end

end