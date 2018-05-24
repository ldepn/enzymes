% try to rotate the superquadric around its X and Y axes to find other
% possible fits, if the fit is good it is retrned in a list of other
% possible fits
function [ SQs_alt, ERRORS_SQs_alt, ERRORS, ORIG_ERRORS ] = GetRotationSQFits( SQs, Ps, fit_threshold, rmv_empty, parallel )
    %% check if should remove empty alt SQs (bad fits) - default is 0
    if ~exist('rmv_empty','var')
        rmv_empty = 1;
    end
    if ~exist('parallel','var')
        parallel = 1;
    end
    %% check input SQs
    for i=1:numel(SQs)
        CheckNumericArraySize(SQs{i},[1 15]);
    end
    %% get default fit threshold, if not defined
    if ~exist('fit_threshold','var')
        fit_threshold = 0.5;
    end
    %% proportional multiplier for accepting fits worse than orig error
    PROP_THRESHOLD_ORIG_ERROR = 1.5;
    %% define downsampling res for fitting comparison
    N_POINTS = 2000;
    %% initialise variables for parallel loop
    ORIG_ERRORS = zeros(1,numel(SQs));
    ERRORS = zeros(6,size(SQs,2));
    ERRORS_SQs_alt = ERRORS;
    SQs_alt = cell(6,size(SQs,2));
    %% get the alternative SQs   
    if parallel
        parfor i=1:numel(SQs)        
            %% get pcl points in a matrix
            P_v = Ps{i}.v;
            % downsample the pcl for fit error comparison
            P_v = DownsamplePCL( P_v, N_POINTS, 1 );
            % get the pointcloud for the SQ
            P_SQ_pcl = SQ2PCL(SQs{i},N_POINTS);
            SQ_pcl = P_SQ_pcl.v;
            % get the error between orig SQ and the pcl
            E_orig = PCLDist( SQ_pcl, P_v );
            ORIG_ERRORS(i) = E_orig;
            %% get the 5 alternative SQs, accumulate if the fit is good
            % define SQ ix 
            SQs_alt_j = cell(6,1);
            curr_ERRORS = zeros(6,1);
            curr_ERRORS_alt = curr_ERRORS + Inf;
            for j=1:4
                alt_SQ = SQs{i};
                alt_SQ(6:8) = [0 0 0];
                rot = GetRotMtx((j-1)*pi/2,'y');
                alt_SQ = RotateSQWithRotMtx(alt_SQ,rot);
                if mod(j,2) == 0
                    alt_SQ(1) = SQs{i}(3);
                    alt_SQ(3) = SQs{i}(1);
                end
                alt_SQ = RotateSQWithRotMtx(alt_SQ,GetEulRotMtx(SQs{i}(6:8))); 
                P_alt_SQ_pcl = SQ2PCL(alt_SQ,size(P_v,1));
                alt_SQ_pcl = P_alt_SQ_pcl.v;
                curr_ERRORS(j) = PCLDist( alt_SQ_pcl, Ps{i}.v );
                % if fit is good, accumulate SQ
                if curr_ERRORS(j) <= fit_threshold || curr_ERRORS(j) <= (E_orig*PROP_THRESHOLD_ORIG_ERROR) || j == 1
                    SQs_alt_j{j} = alt_SQ;  
                    curr_ERRORS_alt(j) = curr_ERRORS(j);
                end
            end        
            for j=5:6
                alt_SQ = SQs{i};
                alt_SQ(6:8) = [0 0 0];
                if j == 5 
                    theta=pi/2;
                else
                    theta=3*pi/2;
                end
                rot = GetRotMtx(theta,'x');
                alt_SQ = RotateSQWithRotMtx(alt_SQ,rot);
                alt_SQ(2) = SQs{i}(3);
                alt_SQ(3) = SQs{i}(2);
                alt_SQ = RotateSQWithRotMtx(alt_SQ,GetEulRotMtx(SQs{i}(6:8)));
                P_alt_SQ_pcl = SQ2PCL(alt_SQ,size(P_v,1));
                alt_SQ_pcl = P_alt_SQ_pcl.v;
                curr_ERRORS(j) = PCLDist( alt_SQ_pcl,P_v );
                % if fit is good, accumulate SQ
                if curr_ERRORS(j) <= fit_threshold || curr_ERRORS(j) <= (E_orig*PROP_THRESHOLD_ORIG_ERROR)
                    SQs_alt_j{j} = alt_SQ;  
                    curr_ERRORS_alt(j) = curr_ERRORS(j);
                end
            end
            ERRORS_SQs_alt(:,i) = curr_ERRORS_alt;
            ERRORS(:,i) = curr_ERRORS;
            SQs_alt(:,i) = SQs_alt_j;
        end   
    else
        for i=1:numel(SQs)        
            %% get pcl points in a matrix
            P_v = Ps{i}.v;
            % downsample the pcl for fit error comparison
            P_v = DownsamplePCL( P_v, N_POINTS, 1 );
            % get the pointcloud for the SQ
            P_SQ_pcl = SQ2PCL(SQs{i},N_POINTS);
            SQ_pcl = P_SQ_pcl.v;
            % get the error between orig SQ and the pcl
            E_orig = PCLDist( SQ_pcl, P_v );
            ORIG_ERRORS(i) = E_orig;
            %% get the 5 alternative SQs, accumulate if the fit is good
            % define SQ ix 
            SQs_alt_j = cell(6,1);
            curr_ERRORS = zeros(6,1);
            curr_ERRORS_alt = curr_ERRORS + Inf;
            for j=1:4
                alt_SQ = SQs{i};
                alt_SQ(6:8) = [0 0 0];
                rot = GetRotMtx((j-1)*pi/2,'y');
                alt_SQ = RotateSQWithRotMtx(alt_SQ,rot);
                if mod(j,2) == 0
                    alt_SQ(1) = SQs{i}(3);
                    alt_SQ(3) = SQs{i}(1);
                end
                alt_SQ = RotateSQWithRotMtx(alt_SQ,GetEulRotMtx(SQs{i}(6:8))); 
                P_alt_SQ_pcl = SQ2PCL(alt_SQ,size(P_v,1));
                alt_SQ_pcl = P_alt_SQ_pcl.v;
                curr_ERRORS(j) = PCLDist( alt_SQ_pcl, Ps{i}.v );
                % if fit is good, accumulate SQ
                if curr_ERRORS(j) <= fit_threshold || curr_ERRORS(j) <= (E_orig*PROP_THRESHOLD_ORIG_ERROR) || j == 1
                    SQs_alt_j{j} = alt_SQ;  
                    curr_ERRORS_alt(j) = curr_ERRORS(j);
                end
            end        
            for j=5:6
                alt_SQ = SQs{i};
                alt_SQ(6:8) = [0 0 0];
                if j == 5 
                    theta=pi/2;
                else
                    theta=3*pi/2;
                end
                rot = GetRotMtx(theta,'x');
                alt_SQ = RotateSQWithRotMtx(alt_SQ,rot);
                alt_SQ(2) = SQs{i}(3);
                alt_SQ(3) = SQs{i}(2);
                alt_SQ = RotateSQWithRotMtx(alt_SQ,GetEulRotMtx(SQs{i}(6:8)));
                P_alt_SQ_pcl = SQ2PCL(alt_SQ,size(P_v,1));
                alt_SQ_pcl = P_alt_SQ_pcl.v;
                curr_ERRORS(j) = PCLDist( alt_SQ_pcl,P_v );
                % if fit is good, accumulate SQ
                if curr_ERRORS(j) <= fit_threshold || curr_ERRORS(j) <= (E_orig*PROP_THRESHOLD_ORIG_ERROR)
                    SQs_alt_j{j} = alt_SQ;  
                    curr_ERRORS_alt(j) = curr_ERRORS(j);
                end
            end
            ERRORS_SQs_alt(:,i) = curr_ERRORS_alt;
            ERRORS(:,i) = curr_ERRORS;
            SQs_alt(:,i) = SQs_alt_j;
        end
    end   
    %% remove badly fitted alt SQs (if required) - return is flattened
    if rmv_empty
        new_alt_SQs = {};
        new_ERRORS = [];
        for i=1:size(SQs_alt,1)
            for j=1:size(SQs_alt,2)
                if ~isempty(SQs_alt{i,j})
                    new_alt_SQs{end+1} = SQs_alt{i,j};
                    new_ERRORS(end+1) = ERRORS(i,j);
                end
            end
        end
        SQs_alt = new_alt_SQs;
        ERRORS = new_ERRORS;
    end
end