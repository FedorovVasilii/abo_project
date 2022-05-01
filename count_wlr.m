%% AUTOMATIC CALCULATION OF AVERAGE WLR AREAS ON RETINA OPTICS IMAGE
%------------------
% OUTPUT: PICTURES OF THE SEGMENTED IMAGES, HEATMAP OF THE AVERAGE AREA WLR
% INPUT: RETINA OPTICS GRAYSCALE IMAGE
%------------------
% CHANGE PLOTTING OF SCANNING LINES ON ANOTHER IMAGE THAN IMG_OTSU -> line 200
% PLOT SCANNING LINE  -> uncomment 83 AND 84 ROWS AT "draw_line.m"
%------------------
% OTHER QUESTIONS TO TEAM ABO No.17
%% LOAD INPUT & COMMON PREPROCESSING
clc; clear all; close all
% load image
gray_image = im2double(imread('1.png')); % LOAD YOUR GRAYSCALE RETINA OPTICS IMAGE
%
% Median filtration
img_med = medfilt2(gray_image,[3,3]); 
% Histogram equalization
img_eq = histeq(img_med); 
% Otsu thresholding
thresholds = multithresh(img_eq,2);
img_otsu_1 = grayslice(img_eq, thresholds);
% Closing gray values
new_img = zeros(size(img_otsu_1));
new_img(img_otsu_1 == 1) = 1;
se = strel('square', 3);
img_close = imclose(new_img,se);
img_otsu_2 = img_otsu_1;
img_otsu_2(img_close == 1) = 1; % replacing values
% Filling all values
img_filled = imfill(img_otsu_2);
img_otsu = img_filled; % sign back to name "img_otsu"
% Smoothing all
img_otsu = imgaussfilt(img_otsu,3);

% figure(1)
% subplot 221
% imshow(img_eq)
% title('1. Median filtering + equalization', 'FontSize', 14)
% subplot 222
% imshow(img_otsu_1,[])
% title('2. Otsu 2 thresholds', 'FontSize', 14)
% subplot 223
% imshow(img_otsu_2,[])
% title('3. Closing', 'FontSize', 14)
% subplot 224
% imshow(img_filled,[])
% title('4. Filling','FontSize', 14)

% SEGMENT CENTERS OF VESSELS

% Blacking borders by 20 pixels from boundaries
[rows, columns, ~] = size(img_otsu);
ind = 20; 
new_img = img_otsu;
new_img(1:rows,1:ind) = 0; % blacking left border
new_img(1:rows,columns-ind:columns) = 0; % blacking right border
new_img(1:ind, 1:columns) = 0; % blacking upper border
new_img(rows-ind:rows, 1:columns) = 0; % blacking down border

% Inverse image
inv_img = zeros(size(new_img));
inv_img(new_img == 0) = 1;

% Closing
se = strel('disk', 40);
img_close = imclose(inv_img,se);

residual = img_close - inv_img; % residual (zustatek po closingu, meli by zustat centry cev)

% Delete small particles
BW2 = bwareaopen(residual, 17000);

% Smooth vessel centers
windowSize = 31;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(BW2), kernel, 'same');
sm_bw = blurryImage > 0.5; % Rethreshold

% figure(2)
% subplot 231
% imshow(img_otsu,[])
% title('1. Preproceed thresholded image')
% subplot 232
% imshow(new_img,[])
% title('2. Blacking borders')
% subplot 233
% imshow(inv_img,[])
% title('3. Inverse image')
% subplot 234
% imshow(img_close)
% title('4. Closing by large value')
% subplot 235
% imshow(residual)
% title('5. Residual image (4. minus 3.)')
% subplot 236
% imshow(sm_bw)
% title('6. Opening by large value + smoothing')

figure(3)
imshowpair(gray_image,sm_bw,'montage');
%%
% title('Input and segmented vessel centers', 'FontSize', 16)
% GET COORDINATES OF VESSEL CENTERS
% Labeling and analysis center objects
[labeledImage, ~] = bwlabel(sm_bw); 
blobMeasurements = regionprops(labeledImage, "PixelList","BoundingBox","Area", "Circularity"); % take needed measurements of objects

% idx = find([blobMeasurements.Area] > 5000 & [blobMeasurements.Circularity] < 0.25); % filter by area size and circularity
% labeledImage = ismember(labeledImage,idx);
%
num = length(blobMeasurements); % number of detected objects
obj_cent = {};
for i = 1:num % FOR EACH OBJECT
    img_obj = ismember(labeledImage, i); % take labled one object
    bin_img = img_obj > 0; % binary image of the object
    bbox = [blobMeasurements(i).BoundingBox]; % boundary box of the object
    imshow(bin_img)
    % artificially split the object (vessel center line) on the k objects with black line
    split_img = bin_img; % image to split (vessel center line)
    k = 15; % number of desired splits
    if bbox(3) < bbox(4) % width is lesser than height -> separate by Y axis
        vec = round(linspace(bbox(2),bbox(2)+bbox(4), k)); % places on the object where will be black lines
        y_or_x = 2;
        for j = vec
            split_img(j:j,:) = 0; % splitted object image
        end
    else % height is lesser than width -> separate by X axis
        vec = round(linspace(bbox(1),bbox(1)+bbox(3), k)); % places on the object where will be black lines
        y_or_x = 1;
        for j = vec
            split_img(:,j:j) = 0;
        end
    end
    [split_lbl, ~] = bwlabel(split_img); % define ~k splitted object from one at start
    split_measurements = regionprops(split_lbl, "Centroid"); % calculate centroids
    num_sep_obj = length(split_measurements); % number of separated objects
    centroids = {};
    left_pos_ind = 1;
    vall = Inf;
    
    % save coordinates of centroids for separated objects
    imshow(split_img) % uncomment with hold on downward
    for c = 1:num_sep_obj
        centroid = split_measurements(c).Centroid;
        if centroid(y_or_x) < vall % save information about the heighest or widest place
            vall = centroid(y_or_x);
            left_pos_ind = c;
        end
        pause(0.05)
        hold on
        plot(centroid(1),centroid(2),'.','Color', 'red','MarkerSize', 15)
        centroids{c} = [centroid(1) centroid(2)];
    end
    
    % Restore right direction for curve by the NNS
    all_centroids = centroids;
    new_way = {}; % centroid coordinates will be saved in right order
    try
        cent = all_centroids{left_pos_ind}; % start point centroid
    catch ME % if object is too small for separation, then its not significant
        fprintf("Small centroid were detected, keep going on other objects...\n");
        continue
    end

    % Nearest Neighbor Search
    new_way{1} = cent;
    all_centroids{left_pos_ind} = [Inf Inf];
    ind = 2;
    while length(all_centroids) ~= length(new_way)
        act_cent = new_way{length(new_way)};
        dist_to_all = {};
        act_best = Inf;
        best_ind = 1;
        for j = 1:length(all_centroids)
            to_cent = all_centroids{j};
            dist = sqrt((act_cent(1)-to_cent(1))^2 + (act_cent(2)-to_cent(2))^2);
            if dist < act_best
                act_best = dist;
                best_ind = j;
            end
            dist_to_all{j} = dist;
        end
        new_way{ind} = all_centroids{best_ind};
        all_centroids{best_ind} = [Inf Inf];
        ind = ind + 1;
    end
    
%     TEST CURVE
%     figure(6)
%     imshow(split_img)
%     for ff = 1:length(new_way)-1
%         hold on
%         cc_1 = new_way{ff};
%         cc_2 = new_way{ff+1};
%         line([cc_1(1) cc_2(1)], [cc_1(2) cc_2(2)], 'Color','red','LineWidth', 5)
%         pause(0.15)
%     end
    obj_cent{i} = new_way; % Save right direction of the curves

end

%%
figure(2)
imshow(img_otsu,[]) % open thresholded or raw image to see results of the WLR calculating

vals_c = {}; % values with coordinates of the lines
vals_wlr = {}; % values with WLR
num = 1;
for i = 1:length(obj_cent) % for each object load its curve
    curve = obj_cent{i};
    for j = 1:length(curve)-1
        start_line = curve{j}; % centroid coordinate of the 1st object
        end_line = curve{j+1}; % centroid coordinate of the 2nd object
        dist_line = round(sqrt((end_line(1) - start_line(1))^2 + (end_line(2) - start_line(2))^2),3);% distance of the line
        if dist_line > 200
            continue
        end
        [wlr, heat_coors] = draw_line(start_line,end_line,img_otsu); % take WLR and scanning line coordinates
        vals_c{num} = heat_coors; % append scanning line coordinates
        vals_wlr{num} = wlr; % append WLR values for this scanning line
        num = num + 1;
    end
end


%%
heat_map_img = zeros(size(img_otsu));

for i = 1:length(vals_c) % for each line
    wlrr = vals_wlr{i}; % wlr of the line
    coors = vals_c{i}{1}; % coordinates of the line
    first_line = [coors(1) coors(2) coors(3) coors(4)]; % first perpendicular line to the scanning line
    coors_l = vals_c{i}{length(vals_c{i})};
    last_line = [coors_l(1) coors_l(2) coors_l(3) coors_l(4)]; % last perpendicular line to the scanning line

    wlr_img = zeros(size(img_otsu));
    wlr_img(:) = wlrr; % image with WLR value everywhere
    c = [first_line(1) last_line(1) last_line(3) first_line(3)]; % column coordinates of the rectangle
    r = [first_line(2) last_line(2) last_line(4) first_line(4)]; % rows coordinates of the rectangle
    BW = poly2mask(c,r,size(img_otsu,1),size(img_otsu,2)); % take mask where scanning lines were
    heat_map_img(BW==1) = wlr_img(BW==1); % and put values with WLR on the masked place
end

% c.Label.String = 'WLR [-]';
% c.Label.String = 'My Colorbar Label';
% cb = colorbar;


figure(10)
imshow(heat_map_img,[])
c = colorbar;
c.Label.String = 'WLR [-]';
colormap(jet)
clim([min(heat_map_img(:)) max(heat_map_img(:))])
title('Heatmap')


% rgbImage = cat(3, heat_map_img, heat_map_img, heat_map_img);

% imshow(conn)
% colormap(jet(2))
% figure(3)
% imshow(BW)

Tmap = heat_map_img;
x = img_otsu;

figure(4);
ax1 = axes;
imagesc(x);
title('Heatmap and segmented image')
colormap(ax1,'gray');
ax2 = axes;
imagesc(ax2,Tmap,'alphadata',0.7);
colormap(ax2,'jet');
caxis(ax2,[min(nonzeros(Tmap(:))) max(nonzeros(Tmap(:)))]);
ax2.Visible = 'off';
linkprop([ax1 ax2],'Position');
cb = colorbar;
cb.Label.String = 'WLR [-]';


