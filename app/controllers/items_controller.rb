class ItemsController < ApplicationController
    before_action :set_item, only: %i[ show edit update destroy ]
    
    def new
        @item = Item.new
    end

    def create
        @item = Item.new(item_params)
        if @item.save
            redirect_to :new_container
        else
            redirect_to :new_container
        end
    end

    def edit
        
    end

    def update
        
        if @item.update(item_params)
            redirect_to :new_container
        end
    end

    def destroy
        @item = Item.find(params[:id])
        @item.destroy
        redirect_to :new_container
    end

    private
        def set_item
            @item = Item.find(params[:id])
        end

        def item_params
            params.require(:item).permit(:packing_style, :length,:width, :height,:height_unit, :weight,:weight_unit, :cog_height_type, :cog_height, :cog_height_unit)
        end

    
end
