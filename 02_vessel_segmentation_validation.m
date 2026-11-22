%% Validation of Automatic Vessel Branch Points vs Manual Landmarks
%% 1. Load CSV data (branch points only)

% Automatic segmentation skeleton Points
auto_points = readmatrix('Skeleton_Points.csv');

% Manual landmark
manual_branch_points = readmatrix('Manual_Landmark.csv');

% Remove any rows with NaNs (common CSV issue)
auto_points = auto_points(~any(isnan(auto_points),2), :);
manual_branch_points = manual_branch_points(~any(isnan(manual_branch_points),2), :);

% Check data size
assert(size(auto_points,2) == 3, 'Auto points must be Nx3 (X,Y,Z)');
assert(size(manual_branch_points,2) == 3, 'Manual points must be Nx3 (X,Y,Z)');

%% 2. Build KD-tree for nearest-neighbor search
% This allows fast distance computation between points

autoTree   = KDTreeSearcher(auto_points);
manualTree = KDTreeSearcher(manual_branch_points);

%% 3. Distance from MANUAL → AUTOMATIC (localization error)

% For each manual branch point, find nearest automatic branch point
[idx_auto, dist_auto] = knnsearch(autoTree, manual_branch_points);

% dist_auto contains Euclidean distances (in same units as your data)

%% 4. Error Metrics (Accuracy of auto segmentation)
mean_error = mean(dist_auto);
max_error  = max(dist_auto);
percentile_95_error = prctile(dist_auto, 95);

%% 5. Branch Point Recall
% within a tolerance distance (e.g., 5 microns)
distance_threshold = 5; % µm (change if your voxel size differs)
matched_manual = dist_auto <= distance_threshold;
branch_point_recall = sum(matched_manual) / size(manual_branch_points,1);
