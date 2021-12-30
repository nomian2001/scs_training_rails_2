class ContainersController < ApplicationController
  include ContainersHelper
  before_action :set_container, only: %i[ show edit update destroy ]

  # GET /containers or /containers.json
  def index
    @containers = Container.all
    
  end

  # GET /containers/1 or /containers/1.json
  def show
    @items = Item.all
    handle_input()
    @result 
  end

  # GET /containers/new
  def new
    @container = Container.new
    @items = Item.all
  end

  # GET /containers/1/edit
  def edit
  end

  # POST /containers or /containers.json
  def create
    @container = Container.new(container_params)

    respond_to do |format|
      if @container.save
        format.html { redirect_to container_url(@container), notice: "Container was successfully created." }
        format.json { render :show, status: :created, location: @container }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /containers/1 or /containers/1.json
  def update
    respond_to do |format|
      if @container.update(container_params)
        format.html { redirect_to container_url(@container), notice: "Container was successfully updated." }
        format.json { render :show, status: :ok, location: @container }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1 or /containers/1.json
  def destroy
    @container.destroy

    respond_to do |format|
      format.html { redirect_to containers_url, notice: "Container was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_container
      @container = Container.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def container_params
      params.require(:container).permit(:container_type)
    end

    def handle_input
      @result = convert_input_to_result()
      container_type = @container.container_type
      if(container_type == Container::FR20 || container_type == Container::FR40)
        handle_flat_track_item(@container,@result)
      else
        handle_open_top_item(@container,@result)
      end

    end

    def convert_input_to_result
      result = {}
      result['container_type'] = @container.container_type
      items = Array.new(Item.count)
      items.each_with_index do |item,index_of_item|
        items[index_of_item] = Hash.new
      end
      result['items'] = items
      @items = Item.all
      @items.each_with_index do |item,index_of_item|
        result['items'][index_of_item]['packing_style'] = item.packing_style
        result['items'][index_of_item]['length'] = item.length
        result['items'][index_of_item]['width'] = item.width
        result['items'][index_of_item]['height'] = item.height
        result['items'][index_of_item]['weight'] = item.weight
        result['items'][index_of_item]['cog_height'] = item.cog_height
        result['items'][index_of_item]['cog_height_type'] = item.cog_height_type
      end

      return result
    end

    
end
