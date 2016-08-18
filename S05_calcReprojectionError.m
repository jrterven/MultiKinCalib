function repError = proj05_calcReprojectionError(result)

load('calibParameters.mat');

    X3d = [];
    x2d = [];
    height = 0;
    width = 0;
    
    camNum = result.CamNum;
    camType = result.CamType;
    
    if camNum == 1
        load(dataAcqFile)
    else       
        % Load the point clouds: cam2_1Matches, cam3_1Matches, etc
        load(matchingResultsFile);
    end
    
    if strcmp(camType, 'depth')
        height = 424;
        width = 512;
    elseif strcmp(camType, 'color')
        height = 1080;
        width = 1920;
    end
    
    % Get the 3D points from the matching results
    % 3D points as a 3 x n matrix
    if camNum == 1
        X3d = (cam1.pointcloud(1:100:end,:))';
        
        % 2D points as a 2 x n matrix
        if strcmp(camType, 'depth')
            x2d = double(cam1.depthProj(1:100:end,:))';
        elseif strcmp(camType, 'color')
            x2d = double(cam1.colorProj(1:100:end,:))';
        end
    elseif camNum == 2
        X3d = cam2_1Matches';
        
        % 2D points as a 2 x n matrix
        if strcmp(camType, 'depth')
            x2d = double(cam2_1depthProj)';
        elseif strcmp(camType, 'color')
            x2d = double(cam2_1colorProj)';
        end
    elseif camNum == 3
        X3d = cam3_1Matches';
        
        if strcmp(camType, 'depth')
            x2d = double(cam3_1depthProj)';
        elseif strcmp(camType, 'color')
            x2d = double(cam3_1colorProj)';
        end
    elseif camNum == 4
        X3d = cam4_1Matches';
        
        if strcmp(camType, 'depth')
            x2d = double(cam4_1depthProj)';
        elseif strcmp(camType, 'color')
            x2d = double(cam4_1colorProj)';
        end
    end
    
    % Remove outliers from X3d in both matrices
    % Find columns with invalid values
    x2dValidCols = ~any( isnan( x2d ) | isinf( x2d ) | x2d > width | x2d < 0, 1 );
    x3dValidCols = ~any( isnan( X3d ) | isinf( X3d ) | X3d > 8, 1 );
    validCols = x2dValidCols & x3dValidCols;
    
    x2d = x2d(:,validCols);
    X3d = X3d(:,validCols);
    
    intrinsic = result.Intrinsics;
    f = intrinsic(1,1);
    cx = intrinsic(1,3);
    cy = intrinsic(2,3);

    % Rotation
    R = result.Rot;

    % Translation
    t = result.t;
    
    radDistNumCoeff = size(result.RadDist,2);
    if isempty(result.TanDist)
        distTan =  false;
    else
        distTan = true;
    end
    
    if radDistNumCoeff == 2
        k1 = result.RadDist(1);
        k2 = result.RadDist(2);       
    elseif radDistNumCoeff == 3
        k1 = result.RadDist(1);
        k2 = result.RadDist(2);
        k3 = result.RadDist(3);
    end
    
    if distTan
        p1 = result.TanDist(1);
        p2 = result.TanDist(2);
    end
    
    N = size(X3d,2);

    Xw = X3d;
    xc = x2d;
    xc(2,:) = height - xc(2,:);

    % Apply extrinsic parameters
    proj = R * Xw  + repmat(t,1,size(Xw,2));

    % Apply Intrinsic parameters to get the projection
    proj = intrinsic * proj;
    proj = proj ./ repmat(proj(3,:),3,1);  
    
% Distortion correction
if radDistNumCoeff > 0
    u = proj(1,:);
    v = proj(2,:);
    ud=xc(1,:);
    vd=xc(2,:);        

    r = sqrt((u-cx).^2 + (v-cy).^2);

    if radDistNumCoeff == 2        
        comp(1,:) = (1 + k1*r.^2 + k2*r.^4);
        comp(2,:) = (1 + k1*r.^2 + k2*r.^4);
    elseif radDistNumCoeff == 3
        comp(1,:) = (1 + k1*r.^2 + k2*r.^4 + k3*r.^6);
        comp(2,:) = (1 + k1*r.^2 + k2*r.^4 + k3*r.^6);
    end

    if distTan
        comp(1,:) = comp(1,:) + 2*p1*(u-cx).*(v-cy) + p2*(r.^2+2*(u-cx).^2);
        comp(2,:) = comp(2,:) + p1*(r.^2+2*(v-cy).^2) + 2*p2*(u-cx).*(v-cy);
    end

    % Reprojection error with distortion
    errors(1,:)= (u-cx).*comp(1,:) - (ud-cx);
    errors(2,:)= (v-cy).*comp(2,:) -(vd-cy);
else
    % Reprojection error without distortion
    errors = proj(1:2,:) - xc;
end

% Display the reproyection error
err = errors .* errors;
err = sum(err(:));
repError = sqrt(err/N);

end
