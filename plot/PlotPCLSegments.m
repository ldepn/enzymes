function PlotPCLSegments( P, colour_segm_ix, downsample, colours )
    if isempty(P)
        error('P is empty. Please provide a P struct with at least the vertice (.v) field');
    end
    if ~exist('colour_segm_ix','var') || colour_segm_ix == -1
        colour_segm_ix = ones(size(P.segms,2),1);
    end
    if ~exist('downsample','var') || downsample == -1
        downsample = 0;
    end
    if ~exist('colours','var') || (~iscell(colours) &&  colours == -1)
        colours = {'.r' '.g' '.b' '.y' '.m' '.c' '.r' '.g' '.b' '.y' '.m' '.c'};  
    end      
    %figure;
    hold on;
    for i=1:size(P.segms,2)
        colour = [0.5 0.5 0.5];
        if colour_segm_ix(i)
            colour = colours{i};           
        end
        if ~isempty(P.segms{i}) && ~isempty(P.segms{i}.v)   
            if downsample
                P.segms{i}.v = DownsamplePCL(P.segms{i}.v,downsample);
            end
            scatter3(P.segms{i}.v(:,1),P.segms{i}.v(:,2),P.segms{i}.v(:,3),50,colour);
        end
    end
    axis equal;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    hold off;
end



