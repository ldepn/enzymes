function [ tool_names, task_groundtruth, gt_per_categ ] = ShowGroundTruth( dataset_folder, task )
    [ tool_names, task_groundtruth ] = ReadGroundTruth([dataset_folder 'groundtruth_' task '.csv']);
    figure;
    plot(task_groundtruth);
    ax = gca;
    ax.XTickLabel = tool_names;
    ax.XTickLabelRotation = 90;
    ax.XTick = 1:size(tool_names,2);  
    legend(['Ground Truth: ' task ' n-tools: ' num2str(size(tool_names,2))]);
    figure;
    histogram(task_groundtruth);
    gt_per_categ = zeros(1,4);
    for i=1:4
       gt_per_categ(i) = size(task_groundtruth(task_groundtruth==i),1);  
    end
end
