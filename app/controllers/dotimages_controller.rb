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

        image = ChunkyPNG::Image.from_file(@dotimage.resized_image.path(:small))
        new_image = ChunkyPNG::Image.from_file(@dotimage.resized_image.path(:new_image))

        a1 = [255,255,255]
        a2 = [255,0,255]
        a3 = [255,0,0]
        a4 = [0, 255,0]
        d5 = [0,0,255]
        d6 = [0,0,0]

        d_palette = [a1,a2,a3,a4,d5,d6]
        x = 0
        for x in 0..31
          y = 0
            for y in 0..31
              color = ChunkyPNG::Color.to_truecolor_bytes(image[x,y])
              dist = []
              d_palette.each do |palette|
                dist << Math::sqrt((color[0]-palette[0])**2+(color[1]-palette[1])**2+(color[2]-palette[2])**2)
              end
              new_color = d_palette[dist.index(dist.min)]
              new_image[x,y] = ChunkyPNG::Color.rgb(new_color[0], new_color[1], new_color[2])
              y = y + 1
            end
          x = x + 1
          new_image.save(@dotimage.resized_image.path(:new_image))
        end
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
