
%% Load vessel mask (3D binary / segmented volume)
vessels = tiffreadVolume('SegVessel_stack30.tif');

%% Load 3D cell coordinates for two cell types
glia = readmatrix('glia_cells_3D.csv');       % Nx3 [x y z]
neurons = readmatrix('neuron_cells_3D.csv');   % Mx3 [x y z]

%% Create vessel surface mesh
figure;
p = patch(isosurface(vessels, 0.5)); % adjust threshold if too faint or too thick
p.FaceColor = [0.75 0.75 0.75]; % light gray
p.EdgeColor = 'none';
hold on;

%% Plot glia (e.g., cyan)
scatter3(glia(:,1), glia(:,2), glia(:,3), 15, 'c', 'filled');

%% Plot neurons (e.g., magenta)
scatter3(neurons(:,1), neurons(:,2), neurons(:,3), 15, 'm', 'filled');

%% Visualization settings
daspect([1 1 1]);       % equal axis scaling
view(3);                % 3D orientation
camlight; lighting gouraud;
xlabel('X (µm)');
ylabel('Y (µm)');
zlabel('Z (µm)');
title('3D Vessel Network with Glia and Neurons');

%% Legend
legend({'Vessels','Glia','Neurons'});




