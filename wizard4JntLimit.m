function dataCollection_config_customized_str = wizard4JntLimit(ARM_NAME, SN)
    %  Author(s):  Hongbin LIN, Samuel Au
    %  comments: Little wizard program to determine the joint limits for specific dVRK system based on different environment.
    %            The goal is to protect dVRK from hitting environment leading to catastrophic damage.

    % checking if arguments correct
    argument_checking(ARM_NAME,...
        SN);

    % Read 'dataCollection_config.json' file
    if strcmp(ARM_NAME, 'MTML')
        dataCollection_config_str = 'dataCollection_config_MTML.json';
    else
        dataCollection_config_str = 'dataCollection_config_MTMR.json';
    end
    fid = fopen(dataCollection_config_str);
    if fid<3
        error('cannot open file dataCollection_config.json, please check the path');
    end
    raw = fread(fid, inf);
    str = char(raw');
    config = jsondecode(str);
    fclose(fid);


    % Add ARM Info
    config.ARM_NAME = ARM_NAME;
    config.SN = SN;

    % dVRK ARM API
    mtm_arm = mtm(ARM_NAME);
    joint_origin_pose = [0,0,0,0,0,0,0];
    mtm_arm.move_joint(deg2rad(joint_origin_pose));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % prevent hitting front plane of environment
    param_name = 'Joint2 maximum limit';
    if strcmp(ARM_NAME, 'MTML')
        joint_init_pos = [0,0,0,90,0,0,0]; %try to move joint 4 to the pose that is most likely hit the front plane of environment
    else
        joint_init_pos = [0,0,0,-90,0,0,0];
    end
        
    couple_contraint =  0;
    joint_init_pos(2) = couple_contraint-0; %10 degree smaller for saftey reason
    joint_init_pos(3) = 0;
    MovingJointNo = 2;
    FollowJointNo = 3;
    default_value = 8; 

    goal_msg = {'Press [i] to move MTM forward,', 
                'finish when the closest distance between MTM and front panel of environment is around 1 cm'};
    [customize_value, frontest_pos] = wizard_move_two_joint(mtm_arm,...
                                                            joint_init_pos,...
                                                            param_name,...
                                                            ARM_NAME,...
                                                            default_value,...
                                                            goal_msg,...
                                                            couple_contraint,...
                                                            MovingJointNo,...
                                                            FollowJointNo);
    config.joint_pos_upper_limit(2) = customize_value;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % prevent hitting upper panel of cartesian space
    Joint_No = 3;
    joint_init_pos =  frontest_pos;
    joint_init_pos(5) = -90  %try to move joint 5 to the pose that is most likely hit the upper plane of environment
    param_name = 'Maximum Sum Position of Joint2 and Joint3';
    recommend_val = 9;
    goal_msg = {'Press [i] to move MTM upward,', 
                'finish when the closest distance between MTM and upper panel of environment is around 1 cm'};
    [customize_value, ~] = wizard_move_one_joint(mtm_arm,...
        joint_init_pos,...
        Joint_No,...
        param_name,...
        ARM_NAME,...
        recommend_val,...
        goal_msg);
    config.coupling_upper_limit = customize_value; 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % prevent hitting left panel of cartesian space
    Joint_No = 1;
    joint_init_pos =  frontest_pos;
    if strcmp(ARM_NAME, 'MTML')
        joint_init_pos(4) = 0; %try to move joint 4 to the pose that is most likely hit the left plane of environment
    else
        joint_init_pos(4) = 180;
    end
    param_name = 'Minimum of Joint 1';
    if strcmp(ARM_NAME, 'MTML')
        recommend_val = -6;
    else
        recommend_val = -18;
    end
    goal_msg = {'Press [d] to move MTM in the left direction', 
                'finish when the closest distance between MTM and left panel of environment is around 1 cm'};
    [customize_value, ~] = wizard_move_one_joint(mtm_arm,...
        joint_init_pos,...
        Joint_No,...
        param_name,...
        ARM_NAME,...
        recommend_val,...
        goal_msg);
    config.joint_pos_lower_limit(1) = customize_value;  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % prevent hitting right panel of cartesian space
    Joint_No = 1;
    joint_init_pos =  frontest_pos;
    if strcmp(ARM_NAME, 'MTML')
        joint_init_pos(4) = -180; %try to move joint 4 to the pose that is most likely hit the right plane of environment
    else
        joint_init_pos(4) = 0;
    end
    param_name = 'Maximum of Joint 1';
    if strcmp(ARM_NAME, 'MTML')
        recommend_val = 18;
    else
        recommend_val = 6;
    end
    goal_msg = {'Press [i] to move MTM in the right direction', 
                'finish when the closest distance between MTM and front panel of environment is around 1 cm'};
    [customize_value, ~] = wizard_move_one_joint(mtm_arm,...
        joint_init_pos,...
        Joint_No,...
        param_name,...
        ARM_NAME,...
        recommend_val,...
        goal_msg);
    config.joint_pos_upper_limit(1) = customize_value;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % close the draw window
    close(gcf);
    mtm_arm.move_joint(deg2rad(joint_origin_pose));
   
    % store data
    save_path = fullfile('data', [ARM_NAME, '_',SN], 'real');
    if ~exist(save_path, 'dir')
        mkdir(save_path);
    end
    dataCollection_config_customized_str = fullfile(save_path,'dataCollection_config_customized.json');
    fid = fopen(dataCollection_config_customized_str,'w');
    jsonStr = jsonencode(config);
    fwrite(fid, jsonStr);
    fclose(fid);
    fprintf('Save config file for dataCollection to %s\n', dataCollection_config_customized_str);
end

function [customized_value, current_pos] = wizard_move_one_joint(mtm_arm,...
        joint_init_pos,...
        MovingJoint_No,...
        param_name,...
        ARM_NAME,...
        recommend_val,...
        goal_msg)
    input_str = '';
    customized_value = joint_init_pos(MovingJoint_No);
    joint_pos = joint_init_pos;
    fprintf('Instruction: \n');
    for i= 1:size(goal_msg)
        fprintf('%d. %s\n', i, goal_msg{i})
    end
    fprintf('Arm: %s\n', ARM_NAME);
    fprintf('Joint_No: %d\n', MovingJoint_No);
    fprintf('Customized Param Name: %s\n', param_name);
    disp('[i] to increase, [d] to decrease, [r] for recommended, [f] when done');
    fprintf('Recommended value: [%s] = %d degree(s)\n', param_name, recommend_val);
    lastsize = 0;
    while (true)
        joint_pos(MovingJoint_No) = customized_value;
        mtm_arm.move_joint(deg2rad(joint_pos));
        
        while (~strcmp(input_str,'i') && ~strcmp(input_str,'d') && ~strcmp(input_str,'r') && ~strcmp(input_str,'f'))
            fprintf(repmat('\b', 1, lastsize));
            lastsize = fprintf('Current value: [%s] = %d degree(s)', param_name, customized_value);
            w = waitforbuttonpress;
            if w
                input_str = get(gcf, 'CurrentCharacter');
            end
        end
        if (input_str == 'i')
            customized_value = customized_value + 1;
        elseif (input_str == 'd')
            customized_value = customized_value - 1;
        elseif (input_str == 'r')
            customized_value = recommend_val;
        else
            fprintf(repmat('\b', 1, lastsize)); % clear last printed line
            break
        end
        input_str = '';
    end
    
    current_pos = joint_pos;
end


% moving two joint simultaneosly, where the sum of two joint position is contrainted to a constant.
function [customized_value, current_pos] = wizard_move_two_joint(mtm_arm,...
        joint_init_pos,...
        param_name,...
        ARM_NAME,...
        default_value,...
        goal_msg,...
        couple_contraint,...
        MovingJointNo,...
        FollowJointNo)
    % Hard Code
%     Joint3_pos_min_limit = -35;
    input_str = '';
%     fprintf('Setting Hard limit for when collecting data of Joint#%d\n', 3);
    disp('Moving to init pose');
%     mtm_arm.move_joint(deg2rad(joint_init_pos));
    customized_value = joint_init_pos(MovingJointNo);
    joint_pos = joint_init_pos;
    fprintf('Instruction: \n');
    for i= 1:size(goal_msg)
        fprintf('%d. %s\n', i, goal_msg{i})
    end
    fprintf('Arm: %s\n', ARM_NAME);
    fprintf('Joint_No: %d\n', MovingJointNo);
    fprintf('Customized Param Name: %s\n', param_name);
    disp('[i] to increase, [d] to decrease, [r] for recommended, [f] when done');
    fprintf('Recommended value: [%s] = %d degree(s)\n', param_name, default_value);
    lastsize = 0;
    
    while (true)
        joint_pos(MovingJointNo) = customized_value;
        joint_pos(FollowJointNo) = couple_contraint - joint_pos(MovingJointNo);
        mtm_arm.move_joint(deg2rad(joint_pos));
        
        % command dialog
        while (~strcmp(input_str,'i') && ~strcmp(input_str,'d') && ~strcmp(input_str,'r') && ~strcmp(input_str,'f'))
            fprintf(repmat('\b', 1, lastsize));
            lastsize = fprintf('Current value: [%s] = %d degree(s)', param_name, customized_value);
            w = waitforbuttonpress;
            if w
                input_str = get(gcf, 'CurrentCharacter');
            end
        end
        if (input_str == 'i')
            customized_value = customized_value + 1;
        elseif (input_str == 'd')
            customized_value = customized_value - 1;
        elseif (input_str == 'r')
            customized_value = default_value;
        else
            fprintf(repmat('\b', 1, lastsize)); % clear last printed line
            break
        end
        input_str = '';
    end
    
    current_pos =  joint_pos;
end

function argument_checking(ARM_NAME,...
        SN)
    if~strcmp(ARM_NAME, 'MTML') && ~strcmp(ARM_NAME, 'MTMR')
        error(['Input of argument ''ARM_NAME''= %s is error, you should input one of the strings ',...
            '[''MTML'',''MTMR'']'], ARM_NAME);
    end
    if ~ischar(SN)
        error('SN input %s is not char array', SN);
    end
end

function collision_checking(config)
    %  Institute: The Chinese University of Hong Kong
    %  Author(s):  Hongbin LIN, Vincent Hui, Samuel Au
    %  Created on: 2018-10-05

    % General variables
    ARM_NAME = config.ARM_NAME;
    is_collision_checking = true;
    is_collecting_data = false;

    % Vitual path for collision checking
    input_data_path = 'test';

    % create mtm_arm obj and move every arm in home joint position
    mtm_arm = mtm(ARM_NAME);
    mtm_arm.move_joint([0,0,0,0,0,0,0]);

    config_joint_list = setting_dataCollection(config,...
                                               input_data_path);
    tic;
    current_progress = 0.0;
    total_data_sets = 0;
    for j=1:size(config_joint_list, 2)
        total_data_sets = total_data_sets + config_joint_list{j}.data_size; 
    end
    one_data_progress_increment = 100 / total_data_sets;
    for i = 1:size(config_joint_list, 2)
        collect_mtm_one_joint(config_joint_list{i},...
                              mtm_arm,...
                              is_collision_checking,...
                              is_collecting_data,...
                              current_progress,...
                              one_data_progress_increment);
    end
    mtm_arm.move_joint([0,0,0,0,0,0,0]);

end

