%% Son et. al., Molecular height measurement by cell surface optical profilometry (CSOP)
% 2. CSOP height quantification code
% - input: the root path of CSOP images and the text files generated by CSOP1_process_stack.m
% - output: an array 'output' that contains the radius determined in each fluorescence channel

close all;
clear all;

PathName={
'..\example\CSOP_image_example\CSOP_ex1'
'..\example\CSOP_image_example\CSOP_ex2'
};

% fit parameters
wfit=2;
Nfit=20;
dz=100;

% nm per camera pixel
px2nm=55;   

output=zeros(length(PathName), 16);
output0=[];
i=0;
ifile=0;
ci=1;
c={'.g', '.r'};

fig=figure(1);
set(fig, 'position', [0 550 500 400]);
fig=figure(2);
set(fig, 'position', [0 50 500 400]);

for ipath=1:length(PathName)
    dirinfo = dir(PathName{ipath});
    dirinfo(~[dirinfo.isdir]) = [];  %remove non-directories

    for K =3:length(dirinfo)
        % find tif files in the subfolders
        ifile=ifile+1;
        thisdir = dirinfo(K).name;
        
        % load the list of text files generated by CSOP1_process_stack.m
        filename = sortrows(ls(fullfile(PathName{ipath}, thisdir, '*.txt')),1); 
        nStack=(length(filename(:,1))-1)/2;   

        data_all=zeros(1,4);
        
        % determine the radius of each image in the stack
        for q=2:length(filename(:,1))   
            fprintf('.%s\n', filename(q,:));
            data=load(fullfile(PathName{ipath}, thisdir, filename(q,:)));
            R=data(:,1);
            I=data(:,2);
            p=polyfit([R(10) R(end)], [I(10) I(end)], 0);
            Inew=I-polyval(p, R);
            [pks locs]=findpeaks(Inew, R, 'SortStr', 'descend', 'NPeaks', 1);
            nInew=Inew/pks;
            idxfit=find(R>locs-wfit & R<locs+wfit);
            [f1, g1] = fit(R(idxfit),nInew(idxfit),'gauss1');
            Rfit=linspace(R(1), R(end), 1000)';
            figure(1);
            plot(R, nInew, '.c');
            hold on;
            plot(Rfit, f1(Rfit), '-b');
            axis([R(1) R(end) 0 1.1]);
            hold off;
            i=i+1;
            
            % structure of data_all:
            % [peak location (circle radius), peak width, peak intensity, background intensity]
            data_all(i, :)=[f1.b1 f1.c1 pks I(end)];    
            
            figure(2);
            plot(i, data_all(i,1)*px2nm, c{ci});
            hold on;

            if i==nStack
                % circle fit
                x=1:length(data_all(:,1));
                y=data_all(:,1)*px2nm;

                figure(2);
                idx_x=find(y==max(y));
                fidx=find(y>max(y)-Nfit);
                if fidx(1)==1
                    fidx=fidx(2:end);
                end
                if fidx(1)==2
                    fidx=fidx(2:end);
                end
                
                % fit circle function to the axial radius profile
                % input: axial position in integer, radius of each stack in nm, 
                %   initial guess of the max radius, axial position of the
                %   max radius, axial step size in nm
                [estimates, model] = CircleFitCart(x(fidx)', y(fidx), y(idx_x), idx_x, dz);    
                [rmse, FittedCurve] = model(estimates);
                xfit=linspace(0, x(end), 500);
                yfit=sqrt(estimates(1)^2-(estimates(3)*(xfit-estimates(2))).^2);
                plot(xfit, yfit, '-r');
                
                output0=[output0 ci max(yfit) estimates(1) estimates(2)...
                    estimates(3) rmse mean(data_all(:,3)) mean(data_all(:,4))]; 

                ci=ci+1;
                i=0;
            end
        end
        
        figure(2);
        hold off;

        if sum(imag(output0))>0
            % ignore the measurement when the circle fit gives an imaginary estimate
        else
            % 'output' contains the quantification result of a CSOP image in each row
            % structure of 'output':
            % [channel number, radius, circle fit estimate1, estimate2, estimate3, 
            % error of circle fit, average peak intensity, average background intensity]
            output(ifile, 1:end)=output0;
        end
        
        i=0;
        ci=1;
        output0=[];
    end
end