function out_RGB = image_maker(layout,data)
    % data = [0.000185322461082283 0.0209811500582442 0.121240601503759 0.0536905644392672 0.0794967171449751 0.0211333792227047 0.0234035793709626 0.0543855236683257 0.0746584771788626 0.0124761728264323;...
    %     0.0893254262416605 0.0582243460764588 0.0493354866038335 0.0234763846235307 0.0161164354548343 0.0785303928836175 0.0033556602774542 0.00686354971936884 0.0357407603515832 0.0146801863814466;...
    %     0.000781001800275336 0.000344170284867097 0.0167716827279466 0.00929921635073599 0.0168974372551096 0.0614145398708038 0.0265209679127396 0.0195912316001271 0.0101066927883088 0.000972942920681987];
    % layout = [  "q"    "w"    "e"    "r"    "t"    "y"    "u"    "i"    "o"    "p"
    %     "a"    "s"    "d"    "f"    "g"    "h"    "j"    "k"    "l"    ";"
    %     "z"    "x"    "c"    "v"    "b"    "n"    "m"    ","    "."    "/"];
    ctlength = 256;
    CT = im2uint8(parula(ctlength));
    ctidx = round(mat2gray(data)*(ctlength-1));
    % values found for the making image, key size, key widths
    key_num_width = 10.80;
    key_num_hieght = 3;
    key_pixel = 30;
    size_multiplier = 10; % mess with this to change resolution probably something close to 10
    % preallocate image
    rgbImage = 255*ones(size_multiplier*key_num_hieght*key_pixel,size_multiplier*key_num_width*key_pixel,3,'uint8');
    key_size = size_multiplier*key_pixel;
    % specify key colors given R, G and B matrixes (all 3x10) that has been
    % extracted from heatmap
    % starts top row (left to right) and then down each row one at a time
    offset = [0 0.25 0.75]; % offset for key rows
    for j = 0:2
        % specifies the boundries in the y directions for the keys
        ywidth = (key_size*j+1):(key_size+key_size*j);
        for i = 0:9
            % specifies the boundries in the x directions for the keys
            % note that there is a offset applied at 0, 0.25 and 0.75 of
            % keywidth
            xwidth = (key_size*i+1+key_size*offset(j+1)):(key_size+key_size*i+key_size*offset(j+1));
            % apply found RGB values from heat map to key at a time
            for c = 1:3
                rgbImage(ywidth,xwidth,c) = CT(ctidx(j+1,i+1)+1,c);
            end
        end
    end
    % enter text for each key 
    RGB = rgbImage;
    font_size_letter = 135;
    shift_up = 50;
    for i = 0:9
        RGB = insertText(RGB,[key_size/2+i*key_size,  key_size/2 - shift_up],layout(1,i+1),'FontSize',font_size_letter,'AnchorPoint','Center','BoxOpacity',0);
        RGB = insertText(RGB,[key_size/2+i*key_size+key_size*0.25,  key_size/2+key_size- shift_up],layout(2,i+1),'FontSize',font_size_letter,'AnchorPoint','Center','BoxOpacity',0);
        RGB = insertText(RGB,[key_size/2+i*key_size+0.75*key_size,  key_size/2+key_size*2- shift_up],layout(3,i+1),'FontSize',font_size_letter,'AnchorPoint','Center','BoxOpacity',0);
    end
    magnitude = floor(log10(min(data,[],'all')))*-1;
    data_percent = data*100;
    font_size_number = 50;
    shift_down = 90;
    % enter percent usage
    for i = 0:9
        RGB = insertText(RGB,[key_size/2+i*key_size,  key_size/2 + shift_down],round(data(1,i+1)*100,magnitude-1),'FontSize',font_size_number,'AnchorPoint','Center','BoxOpacity',0);
        RGB = insertText(RGB,[key_size/2+i*key_size+key_size*0.25,  key_size/2+key_size+ shift_down],round(data(2,i+1)*100,magnitude-1),'FontSize',font_size_number,'AnchorPoint','Center','BoxOpacity',0);
        RGB = insertText(RGB,[key_size/2+i*key_size+0.75*key_size,  key_size/2+key_size*2+ shift_down],round(data(3,i+1)*100,magnitude-1),'FontSize',font_size_number,'AnchorPoint','Center','BoxOpacity',0);
    end
    figure(1);
    % I = imshow(RGB,[]);
    colorbar
    colormap("parula")
    clim([0 data(1,3)*100])
    title('Percent Usage')
    out_RGB = RGB;
end