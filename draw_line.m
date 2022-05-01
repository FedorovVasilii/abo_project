function [output_wlr, coors] = draw_line(start_line, end_line, img_otsu)
% INPUT:
% 1) STARTING COORDINATES OF THE DESIRED LINE (x1,y1)
% 2) ENDING COORDINATES OF THE DESIRED LINE (x2,y2)
% 3) IMAGE, ON WHICH BASIS PROFILE WILL BE CALCULATED
% FUNCTION:
% WILL MAKE n LINES (SCANNING LINES) ALONG THE INPUT LINE
% AND WILL CALCULATE AVERAGE WLR IN COVERING AREA
% OUTPUT:
% 1) outpul_wlr - AVERAGE WALL TO LUMEN RATIO (WLR) IN THE SCANNING REGION
% 2) coors - COORDINATES OF THE PERPENDICULAR LINES (SCANNING LINES)

% Starting line coordinates
p1x = start_line(1);
p1y = start_line(2);
p2x = end_line(1);
p2y = end_line(2);

dist_line = round(sqrt((p2x - p1x)^2 + (p2y - p1y)^2),3);% distance of the line
% disp('DIST LINE: ' + string(dist_line));
% 

% START PARAMETERS TO SET
l = 150; % length of the scanning line
n = round(dist_line) / 3.5; % amount of scanning lines

% CONVERT INTO POS VECTOR
pos(1) = p1x;
pos(2) = p2x;
pos(3) = p1y;
pos(4) = p2y;

% SWAP LINES DIRECTION, THAT IT GOES FROM LEFT TO RIGHT
if pos(1) > pos(2)
    temp = pos(1);
    pos(1) = pos(2);
    pos(2) = temp;
    temp_2 = pos(3);
    pos(3) = pos(4);
    pos(4) = temp_2;
end

% DETERMINE THE ANGLE OF THE LINE
slope_1 = (p2y-p1y) / (p2x-p1x); % slope of the input (normal) line
slope = -1/slope_1;
angle = atand(slope); % angle of the perpendicular line
val = max(abs(sind(angle)), abs(cosd(angle))); % multiply const


% SHOW IMAGE AND NEEDED LINE
% imshow(img_otsu,[])
% line([p1x p2x], [p1y p2y], 'Color', 'blue', 'LineWidth', 2)

%%
% hold on
% imshow(img_otsu,[])
% pause(0.00000001)
% line([p1x p2x], [p1y p2y], 'Color', 'blue', 'LineWidth', 2) %
% Split input line on the n same segments
linX = linspace(p1x, p2x, n); % coordinates of X axis centers along choosen line
linY = linspace(p1y, p2y, n); % coordinates of Y axis centers along choosen line
profiles = {};
coors = {};
centers = {};
% SHOW SCANNING LINES AND CALCULATE THEIR PROFILE
for i = 1:n
    pntX = linX(i); % center X coors of the normal line
    pntY = linY(i); % center Y coors of the normal line
    x3 = pntX + l*cosd(angle); % from the center to the right on the l distance by X
    y3 = pntY + l*sind(angle); % from the center to the right on the l distance by Y
    x4 = pntX + l*cosd(angle+180); % from the center to the left on the l distanceby X
    y4 = pntY + l*sind(angle+180); % from the center to the left on the l distanceby Y
    if x3 > x4 % condition that line going from the left to the right
        temp = x3;
        x3 = x4;
        x4 = temp;
        temp_2 = y3;
        y3 = y4;
        y4 = temp_2;
    end
    st = [x3,y3]; % start points of the scanning line
    e = [x4,y4]; % end points of the scanning line
    line([x3 x4], [y3 y4], 'Color', '#05121c', 'LineWidth', 2) % show scanning line
    hold on
%     plot(pntX, pntY, '.','Color', 'green', 'MarkerSize', 15) % show center of the scan.line
    pause(0.00000001)
    profile = improfile(img_otsu, [x3 x4], [y3 y4]); % take profile of the line covering input image
    centers{i} = [pntX pntY];
    profiles{i} = profile';
    coors{i} = [st e];
end

%% CALCULATE SIGNIFICANT POINTS OF THE PROFILE
% with image profiles provided by scanning lines we're going to calculate where
% will be borders of the vessel lumen and walls on the left part and
% on the right part from the center
points = {};
wlrs = [];
for j = 1:n % for all scanning lines
    act_prof = profiles{j}; % take profile of the line
    % separate profile signal on the 2 parts
    center = round(length(act_prof)/2); % center index
    left = act_prof(1:center);
    right = act_prof(center+1:length(act_prof));
    % if NaN (on the borders of the image) -> replace by the nearest value
    nan_indices_l = find(isnan(left));
    nan_indices_r = find(isnan(right));
    if ~isempty(nan_indices_l)
        left(nan_indices_l) = left(max(nan_indices_l)+1);
    end
    if ~isempty(nan_indices_r)
        right(nan_indices_r) = right(min(nan_indices_r)-1);
    end
    % detect middle reflex on the image
    idx_black_l = find(left == 0, 1, 'last');
    idx_black_r = find(right == 0, 1, 'first');
    if length(idx_black_l:length(left)) + length(1:idx_black_r) > 100
        points{j} = [0 0 0 0];
        WLR = 10;
        wlrs = [wlrs WLR];
        continue
    end

    %threshold middle reflex to the zero
    left(idx_black_l:length(left)) = 0; % vynulovani stredoveho reflexu levy signal
    right(1:idx_black_r) = 0; % vynulovani stredoveho reflexu pravy signal

%     figure(3)
%     subplot 311
%     plot(act_prof)
%     hold on
%     plot(idx_black_l:length(left)+idx_black_r,act_prof(idx_black_l:length(left)+idx_black_r),'red', 'LineWidth',6)
%     title('Actual profile signal and detected middle reflex')
%     subplot 312
%     plot(left)
%     title('left part w/o reflex')
%     subplot 313
%     plot(right)
%     title('right part w/o reflex')

    % Lumen border on the left side from the center
    indices_black_l = zeros(size(left));
    indices_black_l(left == 0) = 1;
    ddl = diff(indices_black_l);
    lli = find(ddl == 1, 1, 'last');

%     figure(4)
%     subplot 311
%     plot(left)
%     hold on
%     plot(lli, left(lli), 'o', 'Color', 'red')
%     title('left signal and detected lumen left index')
%     subplot 312
%     plot(indices_black_l)
%     hold on
%     plot(lli, indices_black_l(lli), 'o', 'Color', 'red')
%     title('indices of black')
%     subplot 313
%     plot(ddl)
%     hold on
%     plot(lli, ddl(lli), 'o', 'Color', 'red')
%     title('derivation indices of black')
    
    %  Lumen border on the right side from the center
    indices_black_r = zeros(size(right));
    indices_black_r(right == 0) = 1;
    ddr = diff(indices_black_r);
    rli = find(ddr == -1, 2, 'last');
    
    % if more borders detected
    if length(rli) > 1
        if (rli(2) - rli(1)) > 25 %  decide if farest one is not big
            rli = rli(1);
        else
            rli = rli(2);
        end
    end

%     figure(5)
%     subplot 311
%     plot(right)
%     hold on
%     plot(rli, right(rli), 'o', 'Color', 'red')
%     title('right signal and detected right index')
%     subplot 312
%     plot(indices_black_r)
%     hold on
%     plot(rli, indices_black_r(rli), 'o', 'Color', 'red')
%     title('indices of black')
%     subplot 313
%     plot(ddr)
%     hold on
%     plot(rli, ddr(rli), 'o', 'Color', 'red')
%     title('derivation indices of black')

    % Wall border on the left side signal from the center
    ss = left;
    ss(lli:length(left)) = 0;
    ss(ss == 2) = 0;
    ddf = diff(ss);
    wil = find(ddf == 1, 1, 'last'); % last

%     figure(6)
%     subplot 311
%     plot(left)
%     hold on
%     plot(wil, left(wil), 'o', 'Color', 'red')
%     title('left signal')
%     subplot 312
%     plot(ss)
%     hold on
%     plot(wil, ss(wil), 'o', 'Color', 'red')
%     title('modified left (expected gray values = 1)')
%     subplot 313
%     plot(ddf)
%     hold on
%     plot(wil, ddf(wil), 'o', 'Color', 'red')
%     title('derivation indices of gray')

    % Wall border on the right side signal from the center
    tt = right;
    tt(1:rli) = 0;
    tt(tt == 2) = 0;
    ddt = diff(tt);
    wir = find(ddt == -1, 2, 'first'); % change from last to first
    
    if length(wir) > 1
        if abs(rli-wir(2)) > 25
            wir = wir(1);
        else
            wir = wir(2);
        end
    end

%     figure(7)
%     subplot 311
%     plot(right)
%     hold on
%     plot(wir, right(wir), 'o', 'Color', 'red')
%     title('right signal')
%     subplot 312
%     plot(tt)
%     hold on
%     plot(wir, tt(wir), 'o', 'Color', 'red')
%     title('modified right (expected gray values = 1)')
%     subplot 313
%     plot(ddt)
%     hold on
%     plot(wir, ddt(wir), 'o', 'Color', 'red')
%     title('derivation indices of gray')
    
    % pokud nenalezli jednu z hodnot
    if (isempty (wir) || isempty(lli) || isempty(wil) || isempty(rli))
        points{j} = [0 0 0 0];
        WLR = 10; % will be deleted after
        wlrs = [wlrs WLR];
        continue
    end
    
%     figure(4)
%     plot(act_prof,'black')
%     hold on
%     plot(wil, act_prof(wil), 'X', 'Color', 'red')
%     hold on
%     plot(lli, act_prof(lli), 'X', 'Color', 'red')
%     hold on
%     plot(rli+length(left), act_prof(rli+length(left)), 'X', 'Color', 'red')
%     hold on
%     plot(wir+length(left), act_prof(wir+length(left)), 'X', 'Color', 'red')
    
    % CALCULATE REAL WIDTH OF THE LUMEN AND WALLS
    lum_1_w = (length(left)-lli) / val;
    lum_2_w = rli / val;
    wall_l = (lli - wil) / val;
    wall_r = (wir - rli) / val;

    if max(wall_r, wall_l) > 25
        points{j} = [0 0 0 0];
        WLR = 10;
        wlrs = [wlrs WLR];
        continue
    end

    avg_wall = wall_l + wall_r; % calculate avg. wall width
    lumen_width = lum_1_w + lum_2_w;
    WLR = avg_wall / lumen_width; % WLR

    wlrs = [wlrs WLR]; % APPEND WLR
    points{j} = [lum_1_w lum_2_w wall_l wall_r]; % SAVE WIDTH OF THE NEEDED LINES

end

%
% WRITE AVG WLR ON THE IMAGE
% osetreni pripadu kdy WLR neni spocitan (=10)
wlrs = wlrs(wlrs ~= 10);
avg_wlr = round(mean(wlrs),3);
% xmin = min(p1x, p2x) - 75; % coordinates for red text
% ymax = min(p1y,p2y) - 75;
% hold on
% text(xmin, ymax,'AVG WLR: ' + string(avg_wlr), 'Color', 'r', 'FontSize', 16)


% PLOT SIGNIFICANT POINTS ON THE IMAGE
for i = 1:n
    % PLOT LUMEN
    pair = centers{i}; 
    c_x = pair(1); % center x
    c_y = pair(2); % center y
    widths = points{i}; % vector with real widths
    l_1 = widths(1); % left lumen length
    l_2 = widths(2); % right lumen length
    w_1 = widths(3); % left wall length
    w_2 = widths(4); % right wall length
%     pause(0.00000001)
    if (l_1 == 0 && l_2 == 0 && w_1 == 0 && w_2 == 0) % case where points are not calculated
%         cor = coors{i};
%         line([cor(1) cor(3)], [cor(2) cor(4)], 'Color', 'blue', 'LineWidth', 4)
        continue
    end

    x3 = c_x + l_2*cosd(angle); % X ending coordinates of the line with the length l_2 (on the right side)
    y3 = c_y + l_2*sind(angle); % Y ending coordinates of the line with the length l_2 (on the right side)
    x4 = c_x + l_1*cosd(angle+180); % X starting coordinates of the line with the length l_1 (on the left side)
    y4 = c_y + l_1*sind(angle+180); % Y starting coordinates of the line with the length l_1 (on the left side)
    if x3 > x4 % if x3 larger, that means it shifted more to the right than x4
        temp = x3;
        x3 = x4;
        x4 = temp;
        temp_2 = y3;
        y3 = y4;
        y4 = temp_2;
    end
    line([x3 x4], [y3 y4], 'Color', '#053c4d', 'LineWidth', 2) % green % plot line
    % PLOT WALLS
    % left wall XY coors
    x5 = x3 + w_1*cosd(angle+180); % calculate coordinates from the ending of the lumen
    y5 = y3 + w_1*sind(angle+180); % calculate coordinates from the ending of the lumen
    line([x3 x5], [y3 y5], 'Color', '#04d9ff', 'LineWidth', 2) % light blue
    % right wall XY coors
    x6 = x4 + w_2*cosd(angle); % calculate coordinates from the ending of the lumen
    y6 = y4 + w_2*sind(angle);  % calculate coordinates from the ending of the lumen
    line([x4 x6], [y4 y6], 'Color', '#04d9ff', 'LineWidth', 2) % light blue

end

line([p1x p2x], [p1y p2y], 'Color', '#9400d3', 'LineWidth', 2) % violet

output_wlr = avg_wlr;


end