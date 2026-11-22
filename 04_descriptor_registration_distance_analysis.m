%% Load Data
bp = readmatrix('Branching_points.csv');
bp = bp(:,1:3); % [x y z]
cells_glia = readmatrix('Glial_centroid.csv');
cells_glia = cells_glia(:,1:2);
cells_neuron = readmatrix('Neuron_centroid.csv');
cells_neuron = cells_neuron(:,1:2);
%% Load 3D Distance Map (COMMON)
info = imfinfo('3D Vessel distance map.tif');
numSlices = numel(info);
D3 = zeros(info(1).Height, info(1).Width, numSlices, 'single');
for k = 1:numSlices
    D3(:,:,k) = imread('3D Vessel distance map.tif', k);
end
%% Load 2D Distance Maps
D2_glia   = imread(2D Glia distance map.tif');
D2_neuron = imread('2D Neuron distance map.tif');
%% Parameters
r_xy  = 20;
r_z   = 4;
nbins = 18;
%% Descriptor Functions
function h = safe_hist_3D(D3,x,y,z,r_xy,r_z,nbins)
    x=round(x); y=round(y); z=round(z);
    [H,W,Z]=size(D3);
    x1=max(1,x-r_xy); x2=min(W,x+r_xy);
    y1=max(1,y-r_xy); y2=min(H,y+r_xy);
    z1=max(1,z-r_z);  z2=min(Z,z+r_z);
    vals=D3(y1:y2,x1:x2,z1:z2);
    vals=vals(vals<80);     % remove outliers > 80
    h=histcounts(vals,nbins,'Normalization','probability');
end
function h = safe_hist_2D(D2,x,y,r_xy,nbins)
    x=round(x); y=round(y);
    [H,W]=size(D2);
    x1=max(1,x-r_xy); x2=min(W,x+r_xy);
    y1=max(1,y-r_xy); y2=min(H,y+r_xy);
    vals=D2(y1:y2,x1:x2);
    vals=vals(vals<80);
    h=histcounts(vals,nbins,'Normalization','probability');
end
%% Compute Vessel Descriptors
bp_desc = zeros(size(bp,1),nbins);
for i=1:size(bp,1)
    bp_desc(i,:) = safe_hist_3D(D3,bp(i,1),bp(i,2),bp(i,3),r_xy,r_z,nbins);
end
%% Compute Cell Descriptors
desc_glia = zeros(size(cells_glia,1),nbins);
for i=1:size(cells_glia,1)
    desc_glia(i,:) = safe_hist_2D(D2_glia,cells_glia(i,1),cells_glia(i,2),r_xy,nbins);
end
desc_neuron = zeros(size(cells_neuron,1),nbins);
for i=1:size(cells_neuron,1)
    desc_neuron(i,:) = safe_hist_2D(D2_neuron,cells_neuron(i,1),cells_neuron(i,2),r_xy,nbins);
end
%% Match Cells to Nearest Vessel Branchpoint
matches_glia = zeros(size(cells_glia,1),4);
for i=1:size(cells_glia,1)
    d = vecnorm(bp_desc - desc_glia(i,:),2,2);
    [v,idx]=min(d);
    matches_glia(i,:)=[cells_glia(i,:) idx v];
end
matches_neuron = zeros(size(cells_neuron,1),4);
for i=1:size(cells_neuron,1)
    d = vecnorm(bp_desc - desc_neuron(i,:),2,2);
    [v,idx]=min(d);
    matches_neuron(i,:)=[cells_neuron(i,:) idx v];
end
writematrix(matches_glia,'glia_bp_matches.csv');
writematrix(matches_neuron,'neuron_bp_matches.csv');
%% Fit COMMON Plane (Glia + Neuron)
bp_idx_all = [matches_glia(:,3); matches_neuron(:,3)];
xyz = bp(bp_idx_all,:);
mu = mean(xyz,1);
[~,~,V] = svd(xyz-mu,0);
normal = V(:,3)';
if normal(3)<0, normal=-normal; end
a=normal(1); b=normal(2); c=normal(3);
d=-dot(normal,mu);
fprintf('Plane: %.4fx + %.4fy + %.4fz + %.4f = 0\n',a,b,c,d);

%% Lift Cells to 3D (SEPARATE OUTPUTS)
cells3D_glia = [cells_glia -(a*cells_glia(:,1)+b*cells_glia(:,2)+d)/c];
cells3D_neuron = [cells_neuron -(a*cells_neuron(:,1)+b*cells_neuron(:,2)+d)/c];
writematrix(cells3D_glia,'glia_cells_3D.csv');
writematrix(cells3D_neuron,'neuron_cells_3D.csv');

%% Cell-to-Vessel Distances (SEPARATE)
[H,W,Z]=size(D3);
dist_glia=zeros(size(cells3D_glia,1),1);
for i=1:size(cells3D_glia,1)
    x=min(max(round(cells3D_glia(i,1)),1),W);
    y=min(max(round(cells3D_glia(i,2)),1),H);
    z=min(max(round(cells3D_glia(i,3)),1),Z);
    dist_glia(i)=D3(y,x,z);
end
dist_neuron=zeros(size(cells3D_neuron,1),1);
for i=1:size(cells3D_neuron,1)
    x=min(max(round(cells3D_neuron(i,1)),1),W);
    y=min(max(round(cells3D_neuron(i,2)),1),H);
    z=min(max(round(cells3D_neuron(i,3)),1),Z);
    dist_neuron(i)=D3(y,x,z);
end
writematrix([cells3D_glia dist_glia],'glia_cell_vessel_distances.csv');
writematrix([cells3D_neuron dist_neuron],'neuron_cell_vessel_distances.csv');
