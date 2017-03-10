% convert a ptool to a pcl
function [ P_out, transf_lists ] = PTool2PCL( ptools, task )
    % define resolution of each segment (grasp and action)
    N_POINTS = 2000;
    % if a task is given, rotate the pcl at the end
    if ~exist('task','var')
        task = '';
    end;    
    P_out = [];
    if size(ptools,1) > 1
        P_out = cell(1,size(ptools,1));
    end        
    transf_lists = cell(1,size(ptools,1));
    for i=1:size(ptools,1)
        ptool = ptools(i,:);        
        % get grasp and action SQs
        [ SQ_grasp, SQ_action ] = GetPToolsSQs( ptool );
        % if paraboloid
        if ptools(i,5) <= 0
            [grasp_pcl, grasp_faces] = ParaboloidFaces(SQ_grasp);
            rev_grasp_faces = [grasp_faces(:,3) grasp_faces(:,2) grasp_faces(:,1)];
            grasp_faces = [grasp_faces; rev_grasp_faces];
            grasp_normals = [];
        else        
            [grasp_pcl,grasp_normals] = UniformSQSampling3D(SQ_grasp,1,N_POINTS);
            grasp_faces = convhull(grasp_pcl);
        end
        % if paraboloid
        if ptools(i,12) <= 0
            [action_pcl, action_faces] = ParaboloidFaces(SQ_action);
            rev_action_faces = [action_faces(:,3) action_faces(:,2) action_faces(:,1)];
            action_faces = [action_faces; rev_action_faces];
            action_normals = [];
        else        
            [action_pcl,action_normals] = UniformSQSampling3D(SQ_action,1,N_POINTS);
            action_faces = convhull(action_pcl);
        end
        pcl = [grasp_pcl; action_pcl];
        if isempty(grasp_normals) || isempty(grasp_normals)
            normals = [];
        else
            normals = [grasp_normals; action_normals];
        end
        % create segments
        grasp_segm.v = grasp_pcl;
        grasp_segm.n = grasp_normals;
        action_segm.v = action_pcl;
        action_segm.n = action_normals;
        % create segmentation indexes for grasping and action
        U = zeros(size(pcl,1),1);
        U(N_POINTS+1:end) = 1;    
        F = [grasp_faces; action_faces+size(grasp_pcl,1)];
        F = F - 1;
        % create point cloud
        P = PointCloud(pcl,normals,F,U,[],{grasp_segm,action_segm});
        % add colour to segments
        P = AddColourToSegms(P);
        % get the task's transformations
        transf_lists{i} = PtoolsTaskTranfs( ptool, task );
        % apply transformations to the ptool pcl
        if ~isempty(transf_lists{i})
            P = Apply3DTransfPCL({P},transf_lists{i});
        end
        if size(ptools,1) > 1
            P_out{i} = P;
        else
            P_out = P;
        end
        
    end
end