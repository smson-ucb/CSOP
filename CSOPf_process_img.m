function output= CSOPf_process_img(img, c, r, idx, f)
    
    % For each position in an array of potential centers determine the radial fluorescence profile and the peak intensity
    % Determine the real center by interpolating the position that provides the highest radial peak intensity
    Ncircle=144*5;
    theta=linspace(0, 2*pi, Ncircle);
    Ith=zeros(length(theta),1);
    dr=10;
    Ndr=100;
    R1=linspace(r-dr, r+dr, Ndr)';
    I1=zeros(length(R1),1);

    % an array of potential centers
    N=30;
    wd_scan=6;
    xy_scan=linspace(-wd_scan, wd_scan, N); 
    Imax=zeros(N,N);

    for j=1:N
        for k=1:N
            for i=1:length(R1)
                xy=[c(1,1)+xy_scan(j)+R1(i)*cos(theta)' c(1,2)+xy_scan(k)-R1(i)*sin(theta)'];   
                Ith=collectPixels(img, round(xy(:,1)), round(xy(:,2)));
                I1(i)=sum(Ith)/length(xy(:,1)); % radial fluorescence profile
            end
            Imax(k,j)=max(I1);
        end
    end
    fig=figure(2);
    set(fig, 'position', [50 550 500 400]);
    surf(xy_scan, xy_scan, Imax);view(2);alpha 0.6;
    hold on;
    
    % determine the real center by interpolating with the 2D gauss fit 
    [fitresult,resnorm] = fmgaussfit(xy_scan,xy_scan,Imax);
    plot(fitresult(3), fitresult(4), '.k', 'Markersize', 12)
    hold off;
    
    % determine the radial fluorescence profile with respect to the real center
    Nfit=6;
    R2=linspace(0, r*1.5, r*Nfit);
    I2=zeros(length(R2),1);
    w=1;
    
    for i=1:length(R2)
        xy=[c(1,1)+fitresult(3)+R2(i)*cos(theta)' c(1,2)+fitresult(4)-R2(i)*sin(theta)'];   % proper circle in image plane
        Ith=collectPixels(img, round(xy(:,1)), round(xy(:,2)));
        I2(i)=sum(Ith)/length(xy(:,1)); % radial fluorescence profile
    end
    fig=figure(3);
    set(fig, 'position', [50 100 500 400]);
    plot(R2', I2, '.');

    output(1,1)=c(1,1)+fitresult(3);
    output(2,1)=c(1,2)+fitresult(4);
    
    [pathstr,name,ext] = fileparts(f);
    ff=fullfile(pathstr, sprintf('%s_rad_prof_%02.0f.txt', name, idx));
    data=[R2' I2];
    save(ff, 'data', '-ascii');
end