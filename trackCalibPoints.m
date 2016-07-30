% Function: 
%   trackCalibPoints
%
% Description:
%   Search for three or six red points in a stick of SIZE_AF. It uses color space
%   and camera space to detect the points in the color image and its 3D
%   coordinates as well in order to verify that the points lie in a stick
%   and that the dimensions of the stick are correct.
%
%   a  b  c  d  e  f
%   o--o--o--o--o--o
%   
% Dependencies:
%   Kin2 class
%
% Inputs:
%   kinect: Kin2 object
%   colorFrame: color camera frame
%   a_refw: Infrared marker position. Used to find point A
%   SIZE_AB: Length of the stick
%
% Usage:
%   This function is called during the calibration images acquisition step.
%
% Returns:
%   validBalls: flag indicating a successful detection
%   points: 6x2 vector of 2D position of the balls in color space
%
% Author: 
%   Juan R. Terven
%   Date: 15-Jan-2016

function [validBalls, points] = trackCalibPoints(kinect, colorFrame, ...
    pointsOnStick, a_refw, SIZE_AF)

    points = zeros(pointsOnStick,2);
    validBalls = false;

    % To track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
    diff_im = imsubtract(colorFrame(:,:,1), rgb2gray(colorFrame));

    %Use a median filter to filter out noise
    diff_im = medfilt2(diff_im, [3 3]);
    % Convert the resulting grayscale image into a binary image.
    diff_im = im2bw(diff_im,0.18);

    % Remove all those pixels less than 300px
    diff_im = bwareaopen(diff_im,30);

    % Label all the connected components in the image.
    bw = bwlabel(diff_im, 8);

    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    numObjects = length(stats);                   

    temp = zeros(numObjects,2);

    for i=1:numObjects
        temp(i,:) = stats(i).Centroid;
    end

    if ~isempty(temp)
        hold on
        plot(temp(:,1),temp(:,2),'k*', 'MarkerSize',10)
        hold off
    end

    % Continue if it found at least pointsOnStick objects
    if numObjects >= pointsOnStick
        %disp(['numObjects:' num2str(numObjects)]); 

        % Get these points on camera space from color to camera            
        wtemp = kinect.mapColorPoints2Camera(temp);        

        % Calculate the distance from each point (in camera coordinates)
        % to the reference point (extracted from the infrared image)
        dist_2_Aw = zeros(numObjects,1);

        for i=1:numObjects
            dist_2_Aw(i) = sqrt((a_refw(1)-wtemp(i,1))^2 + ...
                            (a_refw(2)-wtemp(i,2))^2) + ...
                            (a_refw(3)-wtemp(i,3))^2;
        end

        % Find a,b,c,d,e,f in order where a is the closest point to a_ref,
        % then b, and so on
        [~, idx] = sort(dist_2_Aw);
        points = temp(idx,:);
        pointsw = wtemp(idx,:);
        points = points(1:pointsOnStick,:); % select only the first pointsOnStick
        
         % Plot the possible balls in yellow
        hold on
        plot(points(:,1),points(:,2),'y*', 'MarkerSize',15)
        hold off
        
        % Check that all the points are inside a line between a and f   
        ai = double(points(1,:)); % point a in the image (ai)        
        bi = double(points(2,:));
        ci = double(points(3,:));
        
        if pointsOnStick == 6
            di = double(points(4,:));
            ei = double(points(5,:));
            fi = double(points(6,:));
        end
        
        % for this we calculate the slope
        if pointsOnStick == 3
            m = (ci(2)-ai(2))/(ci(1)-ai(1));
        elseif pointsOnStick == 6
            m = (fi(2)-ai(2))/(fi(1)-ai(1));
        end

        % given the point-slope equation of a line
        % y - y1 = m(x - x1)
        % (x1, y1) will be the coordinates of the A extreme of the line
        % and we will calculate the y component of b,c,d,e
        yb = m * (bi(1) - ai(1)) + ai(2);
        
        if pointsOnStick == 6
            yc = m * (ci(1) - ai(1)) + ai(2);
            yd = m * (di(1) - ai(1)) + ai(2);
            ye = m * (ei(1) - ai(1)) + ai(2);
        end

        % The calculated y component of the points (yb, yc, yd, ye) must be 
        % equal (ideally) of the actual y component of points (bi(2),
        % ci(2), di(2) and ei(2)
        % lets give it alpha pixels of error
        alpha = 20;
        if pointsOnStick == 3
            if abs(yb-bi(2)) > alpha
                disp('No points on a line')
                return;
            end
        elseif pointsOnStick == 6
            if abs(yb-bi(2)) > alpha || abs(yc-ci(2)) > alpha || ...
               abs(yd-di(2)) > alpha || abs(ye-ei(2)) > alpha
                disp('No points on a line')
                return;
            end
        end

        % Validate the coordinates of the points by size using its camera
        % space values (X,Y,Z)        
        sizeAB = norm(pointsw(1,:) - pointsw(2,:));
        sizeAC = norm(pointsw(1,:) - pointsw(3,:));
        
        if pointsOnStick == 6
            sizeAD = norm(pointsw(1,:) - pointsw(4,:));
            sizeAE = norm(pointsw(1,:) - pointsw(5,:));
            sizeAF = norm(pointsw(1,:) - pointsw(6,:));
        end

        if pointsOnStick == 3
            if sizeAC > (SIZE_AF - 0.2) && sizeAC < (SIZE_AF + 0.2) && ...
                    sizeAB < sizeAC                                   
                 validBalls = true;
                 disp('VALID balls')
            end
        elseif pointsOnStick == 6
            if sizeAF > (SIZE_AF - 0.2) && sizeAF < (SIZE_AF + 0.2) && ...
                    sizeAB < sizeAF && sizeAC < sizeAF && sizeAD < sizeAF && ...
                    sizeAE < sizeAF                                   
                 validBalls = true;
                 disp('VALID balls')
            end
        end

        %disp(['Distances btw points: ' num2str(sizeAB) ' ' num2str(sizeAC) ' ' num2str(sizeAD) ' ' num2str(sizeAE) ' ' num2str(sizeAF) ' ' ])

    else
        disp(['Not found at least ' num2str(pointsOnStick) ' objects']);
    end % if numObjects >=3
end % end trackBalls function