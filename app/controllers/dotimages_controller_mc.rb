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
        #@dotimageで使われているカラーを抽出し、RGBの配列をpaletteに格納する
       # palette = []
        color_palettes = []
        image_palettes = @dotimage.palettes.select(:color_id).uniq
        original_palettes = @dotimage.palettes
        cube_array = []

      if image_palettes.count < 16
        #median cut法のためpalette内の最小値/最大値を格納する
      else
        max_r = image_palettes.max_by {|red| red.color.r}.color.r #rの最大値がはいる#
        min_r = image_palettes.min_by {|red| red.color.r}.color.r
        max_g = image_palettes.max_by {|green| green.color.g}.color.g
        min_g = image_palettes.min_by {|green| green.color.g}.color.g
        max_b = image_palettes.max_by {|blue| blue.color.b}.color.b
        min_b = image_palettes.min_by {|blue| blue.color.b}.color.b
        #最大値を持つ辺の中央で分割し８個のcubeを作る

        while cube_array.count < 15 do
          length = ([max_r- min_r, max_g- min_g, max_b-min_b].max)/2
            if ([max_r-min_r, max_g-min_g, max_b-min_b].max) == max_r-min_r
              mean = max_r-length
            elsif ([max_r-min_r, max_g-min_g, max_b-min_b].max) == max_g-min_g
              mean = max_g-length
            else
              mean = max_b-length
            end
      
          cube_1 = [[min_r, mean], [min_g, mean], [min_b, mean]]
          cube_2 = [[mean+1, max_r], [min_g, mean], [min_b, mean]]
          cube_3 = [[min_r, mean], [mean+1, max_g], [min_b, mean]] 
          cube_4 = [[min_r, mean], [min_g, mean], [mean+1, max_b]]
          cube_5 = [[mean+1, max_r], [mean+1, max_g], [min_b, mean]]
          cube_6 = [[mean+1, max_r], [min_g, mean], [mean+1, max_b]]
          cube_7 = [[min_r, mean], [mean+1, max_g], [mean+1, max_b]]
          cube_8 = [[mean+1, max_r], [mean+1, max_g], [mean+1, max_b]]

        #マイナスの辺を持つcubeを除いたcubeの配列を作る
          cube_all = [cube_1, cube_2, cube_3, cube_4, cube_5, cube_6, cube_7, cube_8]
          set_cube = []
            cube_all.each do |cube|
              if cube[0][0] > cube[0][1] || cube[1][0] > cube[1][1] || cube[2][0] > cube[2][1]
              else
                set_cube << cube
              end
            end
              if set_cube.count < 17-cube_array.count && cube_array !=[]
                cube_array.delete(cube_array.max)
              end
        #paletteの色毎にcubeを当てはめてどのエリアが一番多いか判定する。
        #色の数順に配列を作る
            set_cube.each do |cube|
              color_ex = []
                original_palettes.each do |palette|
                  if (cube[0][0]-1..cube[0][1]+1).member?(palette.color.r) && (cube[1][0]-1..cube[1][1]+1).member?(palette.color.g) && (cube[2][0]-1..cube[2][1]+1).member?(palette.color.b)
                    color_ex << palette
                  end
                end
                  if color_ex.count > 0
                    cube_array << [color_ex.count, set_cube.index(cube), color_ex]
                  end
            end
          cube_array_repeat = cube_array.max
          min_r = set_cube[cube_array_repeat[1]][0][0]
          max_r = set_cube[cube_array_repeat[1]][0][1]
          min_g = set_cube[cube_array_repeat[1]][1][0]
          max_g = set_cube[cube_array_repeat[1]][1][1]
          min_b = set_cube[cube_array_repeat[1]][2][0]
          max_b = set_cube[cube_array_repeat[1]][2][1]
        end 
      debugger        
      end

      debugger
      cube_array.each do |array|
        color_r = 0
        color_g = 0
        color_b = 0 
        sum = 0 
          array[2].each do |palette|
            color_r += palette.color.r
            color_g += palette.color.g
            color_b += palette.color.b
            sum += 1
          end
        dist = []
          d_palette.each do |cal|
            dist << ((cal.r-(color_r/sum))**2+(cal.g-(color_g/sum)**2)+(cal.b-(color_b/sum)**2))
          end
          color = Color.find(dist.index(dist.min)+1)
            array[2].each do |palette|
              palette.color_id = color.id
              palette.save
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
