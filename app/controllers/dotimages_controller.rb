class DotimagesController < ApplicationController

  def index
  end

  def new
    @dotimage = Dotimage.new

    respond_to do |format|
      format.html
      format.json { reder json: @dotimage }
    end
  end

  def create
    @dotimage = Dotimage.new(params[:dotimage])
    
    respond_to do |format|
      if @dotimage.save
        format.html { redirect_to dotimage_path(@dotimage) }
        format.json { render json: @dotimage, status: :created, location: @dotimage }
      else
        redirect_to new_dotimage_path
      end
    end
  end

  def edit
  end

  def show
    @dotimage = Dotimage.find(params[:id])
  end

  def update
  end

end
