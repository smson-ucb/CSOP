%% Son et. al., Molecular height measurement by cell surface optical profilometry (CSOP)
% CSOP image simulator
% - input: none
% - output: simulated CSOP images
% - major variables: Rv, Npsf, Nbk 

clear all;
close all;

x=zeros(250,250);
b=zeros(250,250);

c0=[125 125];
px2nm=55;           % nm per px
R=3400/px2nm;       % Radius of circle
sigma=130/px2nm;    % PSF width 130nm/2
Ntheta=3000;        % total number of fluorophores
theta=linspace(360/Ntheta, 360, Ntheta);    % angular location of fluorophores
Nstack=25;          % the number of images in a stack

Rv=0;               % lateral vibration 
Npsf=20;            % relative photon number
Nbk=0;              % background noise

for j=1:Nstack
    fprintf('Generating %dth image\n', j);
    % center of circle
    cx=R*cos(theta/180*pi)'+c0(1);
    cy=R*sin(theta/180*pi)'+c0(2);

    for m=1:5
        % add lateral vibration to the center
        A=Rv*randn(1);
        T=rand(1)*2*pi;
        cx=cx+Rv*A*cos(T);
        cy=cy+Rv*A*sin(T);
        c=[cx cy];
        
        for i=1:length(theta)
            bi=Npsf*gauss2d(x, sigma, c(i,:));  % point spread function of a single fluorophore
            bpi=poissrnd(bi);   % simulate shot-noise to each camera pixel
            b=b+bpi;
        end
    end
    % add background noise
    b=b+100+Nbk*randn(250,250);

    if j==1
        Ntot=sum(sum(b))-100*length(x)^2;
        dirname=sprintf('../example/CSOP_simulation_example/CSOP_sim_Ntot%08.0f', Ntot);
        fprintf('Finished CSOP_sim_Ntot%08.0f...\n', Ntot);

        if(~isdir(dirname))
            mkdir(dirname);
        end
        fname=sprintf('../example/CSOP_simulation_example/CSOP_sim_Ntot%08.0f/CSOP_sim_Ntot%08.0f.tif', Ntot, Ntot);
        imwrite(uint16(b), fname);
    else
        imwrite(uint16(b), fname, 'WriteMode', 'append');
    end
    b=zeros(250,250);
end

function mat = gauss2d(mat, sigma, center)
gsize = size(mat);
[R,C] = ndgrid(1:gsize(1), 1:gsize(2));
mat = gaussC(R,C, sigma, center);
end

function val = gaussC(x, y, sigma, center)
xc = center(1);
yc = center(2);
exponent = ((x-xc).^2 + (y-yc).^2)./(2*sigma^2);
amplitude = 1 / (sigma^2*2*pi);  
val       = amplitude  * exp(-exponent);
end
