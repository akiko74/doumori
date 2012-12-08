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
        palette = []
        color_palette = []
        image_palette = @dotimage.palettes.select(:color_id).uniq
          image_palette.each do |color|
            set_color = Color.find(color.color_id)
            palette << [set_color.r, set_color.g, set_color.b]
          end

      if image_palette.count < 16
          color_palette = palette
        #median cut法のためpalette内の最小値/最大値を格納する
      else
        max_r = palette.max_by {|red| red[0]}[0]
        min_r = palette.min_by {|red| red[0]}[0]
        max_g = palette.max_by {|green| green[1]}[1]
        min_g = palette.min_by {|green| green[1]}[1]
        max_b = palette.max_by {|blue| blue[2]}[2]
        min_b = palette.min_by {|blue| blue[2]}[2]
        #最大値を持つ辺の中央で分割し８個のcubeを作る
        length = ([max_r-min_r, max_g-min_g, max_b-min_b].max)/2
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
      end
        #paletteの色毎にcubeを当てはめてどのエリアが一番多いか判定する。
        #色の数順に配列を作る
        cube_array = []
        set_cube.each do |cube|
          cube_count = 0
          palette.each do |count|
            if (cube[0][0]..cube[0][1]).member?(count[0]) && (cube[1][0]..cube[1][1]).member?(count[1]) && (cube[2][0]..cube[2][1]).member?(count[2])
            cube_count += 1
            end
          end
          if cube_array[cube_count].nil?
            cube_array[cube_count] = cube
          else
            while cube_array[cube_count].present?
              cube_count += 1
            end
            cube_array[cube_count] = cube
          end
        end
        cube_array.delete(nil)

      while cube_array.count < (15-color_palette.count)
        cube_array_repeat = cube_array.pop #cube_nが取れる
        cube_array.each do |color|
          color_palette << [(color[0][1]+color[0][0])/2, (color[1][1]+color[1][0])/2, (color[2][1]+color[2][0])/2]
        end
        
        #cube_array_repeatを最大８つのcubeに分割する
        new_palette = []
        palette.each do |color|
          if (cube_array_repeat[0][0]..cube_array_repeat[0][1]).member?(color[0]) && (cube_array_repeat[1][0]..cube_array_repeat[1][1]).member?(color[1]) && (cube_array_repeat[2][0]..cube_array_repeat[2][1]).member?(color[2])
            new_palette << color
          end
        end
#        length = (cube_array_repeat[0][1]-cube_array_repeat[0][0])/2
        #paletteの色毎にcubeを当てはめてどのエリアが一番多いか判定する。
        max_r = new_palette.max_by {|red| red[0]}[0]
        min_r = new_palette.min_by {|red| red[0]}[0]
        max_g = new_palette.max_by {|green| green[1]}[1]
        min_g = new_palette.min_by {|green| green[1]}[1]
        max_b = new_palette.max_by {|blue| blue[2]}[2]
        min_b = new_palette.min_by {|blue| blue[2]}[2]
        #最大値を持つ辺の中央で分割し８個のcubeを作る
        length = ([max_r-min_r, max_g-min_g, max_b-min_b].max)/2
          if ([max_r-min_r, max_g-min_g, max_b-min_b].max) == max_r-min_r
            mean = max_r - length
          elsif ([max_r-min_r, max_g-min_g, max_b-min_b].max) == max_g-min_g
            mean = max_g - length
          else
            mean = max_b - length
          end
        cube_1 = [[min_r, mean], [min_g, mean], [min_b, mean]]
        cube_2 = [[mean+1, max_r], [min_g, mean], [min_b, mean]]
        cube_3 = [[min_r, mean], [mean+1, max_g], [min_b, mean]] 
        cube_4 = [[min_r, mean], [min_g, mean], [mean+1, max_b]]
        cube_5 = [[mean+1, max_r], [mean+1, max_g], [min_b, mean]]
        cube_6 = [[mean+1, max_r], [min_g, mean], [mean+1, max_b]]
        cube_7 = [[min_r, mean], [mean+1, max_g], [mean+1, max_b]]
        cube_8 = [[mean+1, max_r], [mean+1, max_g], [mean+1, max_b]]
        cube_all = [cube_1, cube_2, cube_3, cube_4, cube_5, cube_6, cube_7, cube_8]
        set_cube = []
        cube_all.each do |cube|
          if cube[0][0] > cube[0][1] || cube[1][0] > cube[1][1] || cube[2][0] > cube[2][1]
          else
             set_cube << cube
          end
        end
        cube_array = []
        set_cube.each do |cube|
          cube_count = 0
          palette.each do |count|
            if (cube[0][0]..cube[0][1]).member?(count[0]) && (cube[1][0]..cube[1][1]).member?(count[1]) && (cube[2][0]..cube[2][1]).member?(count[2])
            cube_count += 1
            end
          end
          if cube_array[cube_count].nil?
            cube_array[cube_count] = cube
          else
            while cube_array[cube_count].present?
              cube_count += 1
            end
            cube_array[cube_count] = cube
          end
        end
        cube_array.delete(nil)
      end

        #ループ終了後はset_cubeを多い順に並べてパレットに入れていく
        #cube1-8をset_cubeに入れる
        cube_array = []
        set_cube.each do |cube|
          cube_count = 0
          new_palette.each do |count|
            if (cube[0][0]..cube[0][1]).member?(count[0]) && (cube[1][0]..cube[1][1]).member?(count[1]) && (cube[2][0]..cube[2][1]).member?(count[2])
            cube_count += 1
            end
          end
          if cube_array[cube_count].nil?
            cube_array[cube_count] = cube
          else
            while cube_array[cube_count].present?
              cube_count += 1
            end
            cube_array[cube_count] = cube
          end
        end
        cube_array.delete(nil)
        cube_array.reverse.each do |color|
          if color_palette.count < 15
          color_palette << [(color[0][1] + color[0][0])/2, (color[1][1] + color[1][0])/2, (color[2][1] + color[2][0])/2]
          end
        end

        #color_paletteが15色まで絞れたので、Colorにマッピングする
        final_palette = []
        color_palette.each do |replace|
          distance = []
          palette.each do |color_id|
          distance << Math::sqrt((replace[0]-color_id[0])**2+(replace[1]-color_id[1])**2+(replace[2]-color_id[2])**2)
          end
          final_palette << palette[distance.index(distance.min)]
          
          end

        #final_paletteの色でpalettesを置き換える
        @dotimage.palettes.each do |palette|
          distance = []
          final_palette.each do |replace|
          color = Color.find(palette.color_id)
          distance << Math::sqrt((replace[0]-color.r)**2+(replace[1]-color.g)**2+(replace[2]-color.b)**2)
          end
          color_fix = distance.index(distance.min)
          palette.color_id = Color.where("r = ? AND g = ? AND b = ?", final_palette[color_fix][0], final_palette[color_fix][1], final_palette[color_fix][2]).first.id
          palette.save
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
