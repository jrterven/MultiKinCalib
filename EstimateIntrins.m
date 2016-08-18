function intrinsics = EstimateIntrins(dataAcqFile,matchingResultsFile,preCalibResultsFile,camNum,cameraType)

if camNum == 1
    load(dataAcqFile)
else       
    % Load the point clouds: cam2_1Matches, cam3_1Matches, etc
    load(matchingResultsFile);
    load(preCalibResultsFile);
end

if camNum == 1
        p3d = cam1.pointcloud';
        R = eye(3);
        t = [0 0 0];
        
        % 2D points as a 2 x n matrix
        if strcmp(cameraType, 'depth')
            p2d = cam1.depthProj';
        elseif strcmp(cameraType, 'color')
            p2d = cam1.colorProj';
        end
elseif camNum == 2    
    p3d = cam2_1Matches;
    R = R1_2;
    t = t1_2;
    
    if strcmp(cameraType, 'depth')
        p2d = cam2_1depthProj;
    elseif strcmp(cameraType, 'color')
        p2d = cam2_1colorProj;
    end
elseif camNum == 3  
    p3d = cam3_1Matches;
    R = R1_3;
    t = t1_3;
    
    if strcmp(cameraType, 'depth')
        p2d = cam3_1depthProj;
    elseif strcmp(cameraType, 'color')
        p2d = cam3_1colorProj;
    end
elseif camNum == 4  
    p3d = cam4_1Matches;
    R = R1_4;
    t = t1_4;
    
    if strcmp(cameraType, 'depth')
        p2d = cam4_1depthProj;
    elseif strcmp(cameraType, 'color')
        p2d = cam4_1colorProj;
    end
end


rows = size(p2d,1);
A = zeros(1,2);
w11=R(1,1);
w12=R(1,2);
w13=R(1,3);
w21=R(2,1);
w22=R(2,2);
w23=R(2,3);
w31=R(3,1);
w32=R(3,2);
w33=R(3,3);
Tx=t(1);
Ty=t(2);
Tz=t(3);

ht=[];
At=[];
for i=1:rows    
   ui = p3d(i,1);
   vi = p3d(i,2);
   wi = p3d(i,3);
   
   Xi = p2d(i,1);
   Yi = p2d(i,2);
   
   A=[(w11*ui+w12*vi+w13*wi+Tx)/(w31*ui+w32*vi+w33*wi+Tz) (w21*ui+w22*vi+w23*wi+Tx)/(w31*ui+w32*vi+w33*wi+Tz) 1 0 0;...
       0 0 0 (w21*ui+w22*vi+w23*wi+Ty)/(w31*ui+w32*vi+w33*wi+Tz) 1];

   At=[At; A];
  
  
end

x=[p2d(:,1);p2d(:,2)];

h = At\double(x);

intrinsics = [h(1) h(2) h(3); ...
                0  h(4) h(5);
                0  0    1];
            