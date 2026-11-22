%% Plane Validation: Point-to-Plane Residuals
plane_residuals = abs(xyz*[a;b;c] + d) / norm(normal);
writematrix(plane_residuals,'plane_residuals_um.csv');

%% Bootstrap Plane Confidence Interval
nBoot=1000;
N=size(xyz,1);
d_vals=zeros(nBoot,1);
angle_vals=zeros(nBoot,1);
normal0 = normal/norm(normal);
for i=1:nBoot
    idx=randsample(N,N,true);
    xyz_b=xyz(idx,:);
    mu_b=mean(xyz_b,1);
    [~,~,Vb]=svd(xyz_b-mu_b,0);
    nb=Vb(:,3)';
    if nb(3)<0, nb=-nb; end
    nb=nb/norm(nb);
    d_vals(i)=-dot(nb,mu_b);
    angle_vals(i)=acosd(dot(normal0,nb));
end
writematrix([d_vals angle_vals], ...
    'bootstrap_plane_offset_and_angle.csv');

%% Plane Sensitivity Analysis ±10 µm (SEPARATE CSVs)
shifts=[-10 0 10];
for s=1:length(shifts)
    d_s = d + shifts(s)*c;
    % --- Glia ---
    z_g = -(a*cells_glia(:,1)+b*cells_glia(:,2)+d_s)/c;
    dist_g=zeros(size(z_g));
    for i=1:length(z_g)
        dist_g(i)=D3(min(max(round(cells_glia(i,2)),1),H), ...
                     min(max(round(cells_glia(i,1)),1),W), ...
                     min(max(round(z_g(i)),1),Z));
    end
    writematrix([cells_glia z_g dist_g], ...
        sprintf('glia_cell_vessel_distances_shift_%+dum.csv',shifts(s)));
    % --- Neuron ---
    z_n = -(a*cells_neuron(:,1)+b*cells_neuron(:,2)+d_s)/c;
    dist_n=zeros(size(z_n));
    for i=1:length(z_n)
        dist_n(i)=D3(min(max(round(cells_neuron(i,2)),1),H), ...
                     min(max(round(cells_neuron(i,1)),1),W), ...
                     min(max(round(z_n(i)),1),Z));
    end
    writematrix([cells_neuron z_n dist_n], ...
        sprintf('neuron_cell_vessel_distances_shift_%+dum.csv',shifts(s)));
end
