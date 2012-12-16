# encoding: utf-8
class DotimagesController < ApplicationController

  def index
  end

  def new
    Dotimage.destroy_all(["created_at < ?", 1.hour.ago])
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
        #@dotimageで使われているカラーを抽出し、RGBの配列をpaletteに格納する
       # palette = []
        color_palettes = []
        image_palettes = @dotimage.palettes.select(:color_id).uniq
        original_palettes = @dotimage.palettes
        cube_array = []
        new_cubes = []
        cubes_fix = []

      if image_palettes.count < 16
        color_no = 0
        image_palettes.each do |color|
          color_no += 1
          original_palettes.where(:color_id => color.color_id).each do |palette|
            palette.palette_no = color_no
            palette.save
          end
        end
        redirect_to dotimage_path(@dotimage) and return

        #median cut法のためpalette内の最小値/最大値を格納する
      else
        max_r = image_palettes.max_by {|red| red.color.r}.color.r #rの最大値がはいる#
        min_r = image_palettes.min_by {|red| red.color.r}.color.r
        max_g = image_palettes.max_by {|green| green.color.g}.color.g
        min_g = image_palettes.min_by {|green| green.color.g}.color.g
        max_b = image_palettes.max_by {|blue| blue.color.b}.color.b
        min_b = image_palettes.min_by {|blue| blue.color.b}.color.b
        #最大値を持つ辺の中央で分割し８個のcubeを作る

        color_array = []
        image_palettes.each do |color|
          color_array << color.color_id
        end
        while new_cubes.count + cubes_fix.count  < 15
        mean = ([max_r- min_r, max_g- min_g, max_b-min_b].max)/2
          if ([max_r-min_r, max_g-min_g, max_b-min_b].max) == max_r-min_r
            key = 'red'
          elsif ([max_r-min_r, max_g-min_g, max_b-min_b].max) == max_g-min_g
            key = 'green'
          else
            key = 'blue'
          end

          cubes = []
          if key == 'red'
            cubes << [[min_r, min_r+mean], [min_g, max_g], [min_b, max_b]]
            cubes << [[min_r+mean+1, max_r], [min_g, max_g], [min_b, max_b]]
          elsif key == 'green'
            cubes << [[min_r, max_r], [min_g, min_g+mean], [min_b, max_b]]
            cubes << [[min_r, max_r], [min_g+mean+1, max_g], [min_b, max_b]]
          else
            cubes << [[min_r, max_r], [min_g, max_g], [min_b, min_b+mean]]
            cubes << [[min_r, max_r], [min_g, max_g], [min_b+mean+1, max_b]]
          end

          cubes.each do |cube|
            count = 0
            color_ids= []
            color_array.each do |palette|
              color = Color.find(palette)
              if (cube[0][0]..cube[0][1]).member?(color.r) && (cube[1][0]..cube[1][1]).member?(color.g) && (cube[2][0]..cube[2][1]).member?(color.b)
              count += original_palettes.where(:color_id => color.id).count
              color_ids << color.id
              end
            end
            if color_ids.count > 1
              new_cubes << [count, cube, color_ids]
              color_array = color_array - color_ids
            elsif color_ids.count == 1
              cubes_fix << [count, cube, color_ids]
              color_array = color_array - color_ids
            end
          end

          if new_cubes.count + cubes_fix.count < 15 && mean != 0
            cube_divide = new_cubes.max
            new_cubes.delete(new_cubes.max)
            max_r = cube_divide[1][0][1]
            min_r = cube_divide[1][0][0]
            max_g = cube_divide[1][1][1]
            min_g = cube_divide[1][1][0]
            max_b = cube_divide[1][2][1]
            min_b = cube_divide[1][2][0]
            color_array = cube_divide[2]
          end
        end
      end

      color_no = 0
      new_cubes.each do |palette|
        color_no += 1
        final_color = []
        palette[2].each do |color_rp|
          final_color << [original_palettes.where(:color_id => color_rp).count, color_rp]
        end
        color_id = final_color.max[1]
        palette[2].each do |color_ex|
          if color_ex != color_id
            original_palettes.where(:color_id => color_ex).each do |palette_ex|
              palette_ex.color_id = color_id
              palette_ex.palette_no = color_no
              palette_ex.save
            end
          else
            original_palettes.where(:color_id => color_ex).each do |palette_ex|
              palette_ex.palette_no = color_no
              palette_ex.save
            end
          end
        end
      end

      color_no += 1
      cubes_fix.each do |palette|
        original_palettes.where(:color_id => palette[2]).each do |palette_ex|
          palette_ex.palette_no = color_no
          palette_ex.save
        end
      color_no += 1
      end
      redirect_to dotimage_path(@dotimage)
  end

  def edit
  end

  def show
    @dotimage = Dotimage.find(params[:id])
    @palettes_order = @dotimage.palettes.order('palette_no ASC')
    @color_palettes = @palettes_order.map(&:color_id).uniq
  end

  def update
  end

  def destroy
  end

end
