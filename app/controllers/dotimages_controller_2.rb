# encoding: utf-8
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
    @dotimage.save
        image = ChunkyPNG::Image.from_file(@dotimage.resized_image.path(:small))
        new_image = ChunkyPNG::Image.from_file(@dotimage.resized_image.path(:new_image))
        d_palette = Color.all
        x = 0
        for x in 0..31
          y = 0
            for y in 0..31
              color = ChunkyPNG::Color.to_truecolor_bytes(image[x,y])
              dist = []
              d_palette.each do |palette|
                dist << Math::sqrt((color[0]-palette.r)**2+(color[1]-palette.g)**2+(color[2]-palette.b)**2)
              end
              new_color = Color.find(dist.index(dist.min)+1)
              @dotimage.palettes.create(:position_x => x, :position_y => y, :color_id => new_color.id)
              new_image[x,y] = ChunkyPNG::Color.rgb(new_color.r, new_color.g, new_color.b)
              y = y + 1
            end
          x = x + 1
        end
        new_image.save(@dotimage.resized_image.path(:new_image))
        @dotimage.save

        #パレット内の色数を数える
        color_palettes = []
        original_palettes = @dotimage.palettes
        palettes = original_palettes.select(:color_id).uniq

        if palettes.count < 16
          num = 0
          palettes.each do |color_num|
            num += 1
              original_palettes.where(:color_id => color_id).each do |palette|
                palette.palette_no = num
                palette.save
              end
          end
            redirect_to dotimage_path(@dotimage) and return
        end

        palettes.each do |count|
          sum = @dotimage.palettes.where(:color_id => count.color_id).count
          color_palettes << [sum, count.color_id]
        end
 
        new_palettes = []
        dist_const = 20
        dist_cal = Math::sqrt(dist_const**3)
        until new_palettes.count == 15 do
          until color_palettes.count == 0 do
            color_palettes = color_palettes.sort
            z = color_palettes.shift
            ed_color = Color.find(z[1])
            dist_all = []
              color_palettes.each do |diff|
                st_color = Color.find(diff[1])
                dist = Math::sqrt((st_color.r-ed_color.r)**2+(st_color.g-ed_color.g)**2+(st_color.b-ed_color.b)**2)
                dist_all << [dist, diff]
              end
              if dist_all.min[0] < dist_cal
                color_palettes.delete(dist_all.min[1])
                new_palettes << [z[0]+dist_all.min[1][0], dist_all.min[1][1]]
                if new_palettes.count + color_palettes.count == 15
                  new_palettes += color_palettes and return
              else
                new_palettes << z
                if new_palettes.count + color_palettes.count == 15
                  new_palettes += color_palettes and return
              end
          end
            color_palettes = new_palettes
            new_palettes = []
        end

            new_color = [new_color_r/sum, new_color_g/sum, new_color_b/sum]
            dist = []
              d_palette.each do |palette|
                dist << Math::sqrt((new_color[0]-palette.r)**2+(new_color[1]-palette.g)**2+(new_color[2]-palette.b)**2)
              end
            new_color = Color.find(dist.index(dist.min)+1)
            color_palettes_fix << [sum, new_color.id]
              unless color_palettes_fix.count < 16
              pixel_color.each do |exchange|
                pixels = original_palettes.where(:color_id => exchange[1])
                  pixels.each do |change|
                    change.color_id = new_color.id
                    change.save
                  end
                color_palettes.delete(exchange)
              end
              end
          elsif color_palettes_fix > 16
            color_palettes_fix << z
            color_palettes.shift
          else
            color_palettes.shift
          end
          dist_const += 20
          if color_palettes.count == [] && color_palettes_fix > 15
            color_palettes = color_palettes_fix
            color_palettes_fix = []
          end
        end
        redirect_to dotimage_path(@dotimage)
  end

  def edit
  end

  def show
    @dotimage = Dotimage.find(params[:id])
  end

  def update
  end

end
